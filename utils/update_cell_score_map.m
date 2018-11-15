function CaSignal = update_cell_score_map(CaSignal, ROIs)
	if isfield(CaSignal, 'cell_score_mask')
		y_start = ROIs{1};
		y_end = ROIs{2};
		x_start = ROIs{3};
		x_end = ROIs{4};
		tempMask = zeros(size(CaSignal.imageData, 1), size(CaSignal.imageData, 2));
		tempRoi = ROIs{5};
		tempMask(y_start:y_end, x_start:x_end) = tempRoi(1:y_end - y_start + 1, 1:x_end - x_start + 1);
		se = strel('square',3);
		tempMask = imdilate(tempMask, se);
		tempMask = imdilate(tempMask, se);
		CaSignal.cell_score_mask = and(CaSignal.cell_score_mask, 1 - tempMask);
	end
end