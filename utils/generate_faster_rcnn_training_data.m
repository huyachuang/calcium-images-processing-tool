function [training_dataset, traing_dir] = generate_faster_rcnn_training_data(src_dir, dst_dir, roi_diameter)

	% generate faster rcnn training data and faster-rcnn's fcn
	training_dataset = [];
	traing_dir = '';
	dest_size = 512;
	sample_count = 0;
	fcn_sample_count = 0;
	filenames = {};
	boxes = {};
	% for fcn
	shift_x = [-1*round(roi_diameter/3) 0];
	shift_y = [-1*round(roi_diameter/3) 0];
	shift_w = [0 round(roi_diameter/3)];
	shift_h = [0 round(roi_diameter/3)];
	
	if exist(dst_dir, 'dir') == 0
		mkdir(dst_dir);
	else
		delete(fullfile(dst_dir, '*.jpg'));
	end
	if exist(fullfile(dst_dir, 'images'), 'dir') == 0
		mkdir(fullfile(dst_dir, 'images'));
	else
		delete(fullfile(dst_dir, 'images', '*.png'));
	end
	
	if exist(fullfile(dst_dir, 'labels'), 'dir') == 0
		mkdir(fullfile(dst_dir, 'labels'));
	else
		delete(fullfile(dst_dir, 'labels', '*.png'));
	end
	
	for i = 1:numel(src_dir)
		data_path = src_dir{i};
		d = rdir(fullfile(data_path, '\**\ROI*.mat'));
		if numel(d) == 1
			ROI_file = [d.name];
		elseif numel(d) < 1
			errordlg(['Not find any ROIinfo file in ', src_dir], 'File Error');
			return;
		elseif numel(d) > 1
			errordlg(['More than one ROIinfo file in ', src_dir], 'File Error');
			return;
		end
		ROImasks = load_ROImasks(ROI_file);
		if numel(ROImasks) == 0
			return
		end
			% resize image
		[mean_images, ~] = load_image_data(data_path);
% 		img = max(mean_images, [], 3);
% 		img = gray2RGB(img);
		for img_idx = 1:size(mean_image, 3)
			img = gray2RGB(mean_image(:, :, 3));
			summarized_pos = zeros(size(ROImasks, 2), 4);
			if size(ROImasks, 1) ~= dest_size || size(ROImasks, 2) ~= dest_size
				img = imresize(img, [dest_size dest_size]);
				for k = 1:size(ROImasks, 2)
					mask = ROImasks{k};
					mask = imresize(mask,[dest_size dest_size], 'nearest');
					[row, col] = find(mask);
					pos = int16([min(col(:)), min(row(:)),...
								max(col(:))-min(col(:))+1, max(row(:))-min(row(:))+1]);
					summarized_pos(k, :) = pos;

					for shift_x_i = 1:numel(shift_x)
						x = pos(1) + shift_x(shift_x_i);
						for shift_w_i = 1:numel(shift_w)
							w = pos(3) + shift_w(shift_w_i);
							for shift_y_i = 1:numel(shift_y)
								y = pos(2) + shift_y(shift_y_i);
								for shift_h_i = 1:numel(shift_h)
									h = pos(4) + shift_h(shift_h_i);
									croped_img = imcrop(img, [x, y, w, h]);
									cropped_mask = imcrop(mask, [x, y, w, h]);
									fcn_sample_count = fcn_sample_count + 1;
									imwrite(croped_img, fullfile(dst_dir, 'images', strcat(num2str(fcn_sample_count), '.png')));
									imwrite(cropped_mask, fullfile(dst_dir, 'labels', strcat(num2str(fcn_sample_count), '.png')));	
								end
							end
						end
					end

				end
			else
				for k = 1:size(ROImasks, 2)
					mask = ROImasks{k};
					[row, col] = find(mask);
					pos = int16([min(col(:)), min(row(:)),...
								max(col(:))-min(col(:))+1, max(row(:))-min(row(:))+1]);
					summarized_pos(k, :) = pos;
					for shift_x_i = 1:numel(shift_x)
						x = pos(1) + shift_x(shift_x_i);
						for shift_w_i = 1:numel(shift_w)
							w = pos(3) + shift_w(shift_w_i);
							for shift_y_i = 1:numel(shift_y)
								y = pos(2) + shift_y(shift_y_i);
								for shift_h_i = 1:numel(shift_h)
									h = pos(4) + shift_h(shift_h_i);
									croped_img = imcrop(img, [x, y, w, h]);
									cropped_mask = imcrop(mask, [x, y, w, h]);
									fcn_sample_count = fcn_sample_count + 1;
									imwrite(croped_img, fullfile(dst_dir, 'images', strcat(num2str(fcn_sample_count), '.png')));
									imwrite(cropped_mask, fullfile(dst_dir, 'labels', strcat(num2str(fcn_sample_count), '.png')));	
								end
							end
						end
					end
				end
			end		
			sample_count = sample_count + 1;
			boxes{sample_count, 1} = summarized_pos;
			filenames{sample_count, 1} = [num2str(sample_count) '.jpg'];
			imwrite(uint8(img), fullfile(dst_dir, filenames{sample_count}));
		end
	end
	training_dataset = table(filenames, boxes);
	traing_dir = dst_dir;
end