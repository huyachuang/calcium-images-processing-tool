function training_data_path = generate_localFCN_training_data(src_dir, dst_dir, ROI_diameter, random_sample_num)
	
	training_data_path = '';
	img_count = 0;
	
	if exist(fullfile(dst_dir, 'images'), 'dir') == 0
		mkdir(fullfile(dst_dir, 'images'))
	else
		delete(fullfile(dst_dir, 'images', '*.png'));
	end
	if exist(fullfile(dst_dir, 'labels'), 'dir') == 0
		mkdir(fullfile(dst_dir, 'labels'))
	else
		delete(fullfile(dst_dir, 'labels', '*.png'));
	end
	
	for i = 1:size(src_dir, 2)
		temp_dir = src_dir{i};
		d = rdir(fullfile(temp_dir, '\**\ROI*.mat'));
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
		
		[mean_images, ~] = load_image_data(temp_dir);
% 		max_mean_image = max(mean_images, [], 3);
		
		for img_idx = 1:1%size(mean_images, 3)
			max_mean_image = max(mean_images, [], 3);
% 			img = gray2RGB(mean_images(:, :, img_idx));
			img = gray2RGB(max_mean_image);
			for k = 1:size(ROImasks, 2)
				mask = ROImasks{k};
				[rId, cId] = find(mask);
				idx = randsample(size(rId, 1), random_sample_num);
				rId = rId(idx);
				cId = cId(idx);		
				for n = 1:random_sample_num
					r = rId(n);
					c = cId(n);
					img_count = img_count + 1;
					r_start = r - ROI_diameter;
					if r_start < 1
						r_start = 1;
					end
					r_end = r_start + 2*ROI_diameter;
					if r_end > size(mask, 1)
						r_end = size(mask, 1);
					end
					c_start = c - ROI_diameter;
					if c_start < 1
						c_start = 1;
					end
					c_end = c_start + 2*ROI_diameter;
					if c_end > size(mask, 2)
						c_end = size(mask, 2);
					end
					sample_image = uint8(zeros(2 * ROI_diameter + 1,  2 * ROI_diameter + 1, size(img, 3)));
					sample_image(1:r_end - r_start + 1, 1:c_end - c_start + 1,:) = img(r_start:r_end, c_start:c_end,:);
					imwrite(sample_image, fullfile(dst_dir, 'images', strcat(num2str(img_count), '.png')));
					sample_mask = zeros(2 * ROI_diameter + 1,  2 * ROI_diameter + 1);
					sample_mask(1:r_end - r_start + 1, 1:c_end - c_start + 1) = mask(r_start:r_end, c_start:c_end);
					imwrite(uint8(sample_mask), fullfile(dst_dir, 'labels', strcat(num2str(img_count), '.png')));
				end
			end
		end
	end
	training_data_path = dst_dir;
end