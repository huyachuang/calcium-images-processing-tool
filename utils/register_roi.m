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
		[x_start, x_end, y_start, y_end] = generate_loaction_boxes(CaSignal, x, y);
		I = uint8(zeros(2 * ROIDiameter + 1,  2 * ROIDiameter + 1, size(CaSignal.imageData, 3)));
		I(1:y_end - y_start + 1, 1:x_end - x_start + 1,:) = CaSignal.imageData(y_start:y_end, x_start:x_end,:);
		mask = semanticseg(I, CaSignal.localFCNModel.net);
		mask = uint8(mask) - 1;
		BW = imbinarize(mask);
		B = bwboundaries(BW, 'noholes');
		B_original = bwboundaries(registered_masks{i}, 'noholes');
		boundary = B_original{1};
		if numel(B) == 1
			boundary_temp = B{1};
			x = boundary_temp(:,2);
			y = boundary_temp(:,1);
			w = max(x(:)) - min(x(:));
			h = max(y(:)) - min(y(:));
			if w > 7 && h > 7
				boundary = boundary_temp;
			end
		end
		registered_ROIs{i} = {y_start, y_end, x_start, x_end, mask, boundary, i, 'T'};	
	end
end