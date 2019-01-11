function [mean_images, max_images, max_delta_images] = load_image_data_v2(data_path)
	%read tif data and summarize to mean image stack
	if exist(fullfile(data_path, 'summarized\summarized.mat'), 'file')
		summarized_images = load(fullfile(data_path, 'summarized\summarized.mat'));
		mean_images = summarized_images.mean_images;
		max_images = summarized_images.max_images;
		max_delta_images = summarized_images.max_delta_images;
	else
		d = dir(fullfile(data_path, '*.tif*'));
		mean_images = [];
		max_images = [];
		f = waitbar(0,sprintf('Processing data...%.2f%%', 0.0));
		for i = 1:size(d, 1)
			f = waitbar(i/size(d, 1), f, sprintf('Processing data...%.2f%%', (i/size(d, 1))*100));
			tiff_filename = fullfile(data_path, d(i).name);
			info = imfinfo(tiff_filename);
			numImages = length(info);
			tiff = Tiff(tiff_filename, 'r');
			temp = double(read(tiff));
			image_data = zeros(size(temp, 1), size(temp, 2), numImages);
			image_data(:, :, 1) = temp;
			for j = 2:numImages
				tiff.setDirectory(j);
				temp = double(read(tiff));
				image_data(:, :, j) = temp;
			end
			
			mean_image_data = mean(image_data, 3);
			mean_image_data = mean_image_data - min(mean_image_data(:));
			mean_image_data = mean_image_data / max(mean_image_data(:));
			
			max_image_data = max(image_data, [], 3);
			max_image_data = max_image_data - min(max_image_data(:));
			max_image_data = max_image_data / max(max_image_data(:));
			
			max_delta_image_data = img_max_delta(image_data, 3);
			max_delta_image_data = max_delta_image_data - min(max_delta_image_data(:));
			max_delta_image_data = max_delta_image_data / max(max_delta_image_data(:));
			
			if i == 1
				mean_images = zeros(size(mean_image_data, 1), size(mean_image_data, 2), size(d, 1));
				max_images = zeros(size(max_image_data, 1), size(max_image_data, 2), size(d, 1));
				max_delta_images = zeros(size(max_delta_image_data, 1), size(max_delta_image_data, 2), size(d, 1));
			end
			mean_images(:, :, i) = mean_image_data;
			max_images(:, :, i) = max_image_data;
			max_delta_images(:, :, i) = max_delta_image_data;
		end
		close(f);
		if exist(fullfile(data_path, 'summarized'), 'dir') == 0
			mkdir(fullfile(data_path, 'summarized'));
		end
		save(fullfile(data_path, 'summarized\summarized.mat'), 'mean_images', 'max_images', 'max_delta_images');
	end
end

function max_delts = img_max_delta(img, span)

	% Note, span has to be odd number
	mean_img = mean(img,3);
	
	img = double(img);
	mean_im = mean(img,3);

	pad = zeros(size(img,1),size(img,2), (span-1)/2);
	for i = 1: (span-1)/2
		pad(:,:,i) = mean_im;
	end
	temp = cat(3,pad,img,pad);

	img_smth = zeros(size(img));
	
	for i = 1:size(img,3) % (span-1)/2+1 : size(im,3)+(span-1)/2
		img_smth(:,:,i) = mean(temp(:,:,i:i+span-1), 3);
	end
	max_img = max(img_smth,[],3);
	max_delts = max_img - mean_img;
end