function CaSignal = global_segmentation(CaSignal)
	logit = predict(CaSignal.global_FCNModel.net, CaSignal.imageData);
	C = semanticseg(CaSignal.imageData, CaSignal.global_FCNModel.net);
	C_int = uint8(C) - 1;
	se = strel('square',3);
	mask = imerode(C_int, se);
	mask = imerode(mask, se);
	logit = logit(:, :, 2);
	CaSignal.cell_score = double(mask) .* logit;
	CaSignal.cell_score_mask = ones(size(CaSignal.imageData, 1), size(CaSignal.imageData, 2));
	
	for i = 1:CaSignal.ROI_num
		temp_ROI = CaSignal.ROIs{i};
		y_start = temp_ROI{1};
		y_end = temp_ROI{2};
		x_start = temp_ROI{3};
		x_end = temp_ROI{4};
		C_int = temp_ROI{5}
		tempMask = zeros(size(CaSignal.imageData, 1), size(CaSignal.imageData, 2));
		tempMask(y_start:y_end, x_start:x_end) = C_int(1:y_end - y_start + 1, 1:x_end - x_start + 1);
		CaSignal.cell_score_mask = and(CaSignal.cell_score_mask, 1 - tempMask);
	end
end