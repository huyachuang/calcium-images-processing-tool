function training_data_path = generate_globalFCN_training_data(src_dir, dst_dir, N)
	img_count = 0;
	if exist(fullfile(dst_dir, 'images'), 'dir') == 0
		mkdir(fullfile(dst_dir, 'images'))
	end
	if exist(fullfile(dst_dir, 'labels'), 'dir') == 0
		mkdir(fullfile(dst_dir, 'labels'))
	end
	for i = 1:size(src_dir, 2)
		temp_dir = src_dir{i};
		[mean_images, ~] = load_image_data(temp_dir);
		trial_nums = size(mean_images, 3);
		loop_num = floor(trial_nums / N);
		d = rdir(fullfile(temp_dir, '\**\ROI*.mat'));
		if numel(d) == 1
			ROI_file = [d.name];
			ROIinfo = load(ROI_file);
		elseif numel(d) < 1
			training_data_path = '';
			errordlg(['Not find any ROIinfo file in ', temp_dir], 'File Error');
			return;
		elseif numel(d) > 1
			training_data_path = '';
			errordlg(['More than one ROIinfo file in ', temp_dir], 'File Error');
			return;
		end
		
		if isfield(ROIinfo, 'ROIinfoBU')
			ROImasks = ROIinfo.ROIinfoBU.ROImask;
		elseif isfield(ROIinfo, 'ROIInfo')
			ROIs = data.ROIInfo;
			ROImasks = cell([1, size(ROIs, 2)]);
			for j = 1:size(ROIs, 2)
				tempMask = zeros(size(img, 1), size(img, 2));
				y_start = ROIs{j}{1};
				y_end = ROIs{j}{2};
				x_start = ROIs{j}{3};
				x_end = ROIs{j}{4};
				tempRoi = ROIs{j}{5};
				tempMask(y_start:y_end, x_start:x_end) = tempRoi(1:y_end - y_start + 1, 1:x_end - x_start + 1);
				ROImasks{j} = tempMask;
			end
		else
			training_data_path = '';
			errordlg(['Not find any ROIinfo file in ', temp_dir], 'File Error');
			return;
		end
		summarized_masks = zeros(size(mean_images, 1), size(mean_images, 2));
		for k = 1:size(ROImasks, 2)
			summarized_masks = or(summarized_masks, ROImasks{k});
		end
		training_data_path = dst_dir;
		for k = 1:loop_num
			img_count = img_count + 1;
			max_mean_image = max(mean_images(:, :, (k-1)*N+1:k*N), [], 3);
			img = gray2RGB(max_mean_image);
			imwrite(img, fullfile(dst_dir, 'images', strcat(num2str(img_count), '.png')));
			imwrite(uint8(summarized_masks), fullfile(dst_dir, 'labels', strcat(num2str(img_count), '.png')));
		end
		img_count = img_count + 1;
		max_max_mean_image = max(mean_images(:, :, end-49:end), [], 3);
		img = gray2RGB(max_mean_image);
		imwrite(img, fullfile(dst_dir, 'images', strcat(num2str(img_count), '.png')));
		imwrite(uint8(summarized_masks), fullfile(dst_dir, 'labels', strcat(num2str(img_count), '.png')));
	end
end