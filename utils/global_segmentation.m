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
		CaSignal = update_cell_score_map(CaSignal, temp_ROI);
	end
end