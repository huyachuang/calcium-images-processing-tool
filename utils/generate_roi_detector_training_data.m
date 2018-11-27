function training_data_path = generate_roi_detector_training_data(src_dir, dst_dir, bin_size, step_size)
	training_data_path = '';
	cell_dir = fullfile(dst_dir, 'cell');
	background_dir = fullfile(dst_dir, 'background');
	if exist(cell_dir, 'dir') == 0
		mkdir(cell_dir);
	else
		delete(fullfile(cell_dir, '*.jpg'));
	end
	if exist(background_dir, 'dir') == 0
		mkdir(background_dir);
	else
		delete(fullfile(background_dir, '*.jpg'));
	end
	%%config some parameters
	pos_count = 0;
	neg_count = 0;
	overlap_th = 0.75;
	%go through src+_dirs for original imgs and labels
	for i = 1:numel(src_dir)
		%load image
		data_path = src_dir{i};
		[mean_images, ~] = load_image_data(data_path);
		img = max(mean_images, [], 3);
		img = gray2RGB(img);
		img_patches_boxes = get_square_patches_boxes(img, bin_size, step_size);
		%load label
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
		ROI_boxes = zeros(size(ROImasks, 2), 4);
		for k = 1:size(ROImasks, 2)
			mask = ROImasks{k};
			[row, col] = find(mask);
			ROI_boxes(k, :) = int16([min(row(:)), min(col(:)),...
				max(row(:))-min(row(:))+1, max(col(:))-min(col(:))+1]);
		end
		img_patches_boxes = reshape(img_patches_boxes, size(img_patches_boxes, 1)*size(img_patches_boxes, 2), 4);
		overlapRatio = bboxOverlapRatio(img_patches_boxes, ROI_boxes, 'Min');
		for j = 1:size(overlapRatio, 1)
			if max(overlapRatio(j, :)) > overlap_th
				pos_count = pos_count + 1;
				filenames = [num2str(pos_count) '.jpg'];
				imwrite(img(img_patches_boxes(j, 1):img_patches_boxes(j, 1)+img_patches_boxes(j, 3)-1,...
					img_patches_boxes(j, 2):img_patches_boxes(j, 2)+img_patches_boxes(j, 4)-1, :),...
					fullfile(cell_dir, filenames))
			else
				neg_count = neg_count + 1;
				filenames = [num2str(neg_count) '.jpg'];
				imwrite(img(img_patches_boxes(j, 1):img_patches_boxes(j, 1)+img_patches_boxes(j, 3)-1,...
					img_patches_boxes(j, 2):img_patches_boxes(j, 2)+img_patches_boxes(j, 4)-1, :),...
					fullfile(background_dir, filenames))
			end
		end
	end
	training_data_path = dst_dir;
end