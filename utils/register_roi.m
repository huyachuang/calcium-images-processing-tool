function registered_ROIs = register_roi(ROIs, moving_image, fixed_image, CaSignal)
	[optimizer, metric] = imregconfig('multimodal');
	ref2d = imref2d(size(moving_image));
	tform_r = imregtform(moving_image, fixed_image, 'rigid', optimizer, metric, 'PyramidLevels', 3);
	
	moving_summarized_mask = zeros(size(moving_image));
	for i = 1:size(ROIs, 2)
		tempMask = zeros(size(moving_image, 1), size(moving_image, 2));
		y_start = ROIs{i}{1};
		y_end = ROIs{i}{2};
		x_start = ROIs{i}{3};
		x_end = ROIs{i}{4};
		tempRoi = ROIs{i}{5};
		tempMask(y_start:y_end, x_start:x_end) = tempRoi(1:y_end - y_start + 1, 1:x_end - x_start + 1);
		moving_summarized_mask(tempMask == 1) = ROIs{i}{7};
	end
	
	registered_summarized_mask = imwarp(moving_summarized_mask, tform_r, 'OutputView', ref2d);
	
	registered_masks = cell(size(ROIs));
	for i = 1:size(ROIs, 2)
		registered_masks{i} = registered_summarized_mask == i;
	end
	
	registered_ROIs = {};
	ROIDiameter = CaSignal.ROIDiameter;
	for i = 1:size(registered_masks, 2)
		[ys, xs] = find(registered_masks{i});
		x = uint16(median(xs, 'all'));
		y = uint16(median(ys, 'all'));
		x_start = x - ROIDiameter;
		if x_start < 1
			x_start = 1;
		end
		x_end = x + ROIDiameter;
		if x_end > size(moving_image, 2)
			x_end = size(moving_image, 2);
		end
		
		y_start = y - ROIDiameter;
		if y_start < 1
			y_start = 1;
		end
		y_end = y + ROIDiameter;
		if y_end > size(moving_image, 1)
			y_end = size(moving_image, 1);
		end
		I = uint8(zeros(2 * ROIDiameter + 1,  2 * ROIDiameter + 1, size(CaSignal.imageData, 3)));
		I(1:y_end - y_start + 1, 1:x_end - x_start + 1,:) = CaSignal.imageData(y_start:y_end, x_start:x_end,:);
		mask = semanticseg(I, CaSignal.model.net);
		mask = uint8(mask) - 1;
		BW = imbinarize(mask);
		B = bwboundaries(BW, 'noholes');
		boundary = B{1};
		registered_ROIs{i} = {y_start, y_end, x_start, x_end, mask, boundary, i, 'T'};
	end
end