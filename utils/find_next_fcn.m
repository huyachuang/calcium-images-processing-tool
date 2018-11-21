function CaSignal = find_next_fcn(handles, CaSignal)
	if get(handles.NextROICheckBox,'Value') == 1
		CaSignal.cell_score = CaSignal.cell_score .* CaSignal.cell_score_mask;
		maximum = max(CaSignal.cell_score(:));
		[y, x] = find(CaSignal.cell_score == maximum);
		[x_start, x_end, y_start, y_end] = generate_loaction_boxes(CaSignal, x, y);
		axes(handles.ImageShowAxes);
		hold on
		plot(x, y, 'r*', 'LineWidth', 3);
		rectangle('Position',[x_start, y_start, 2*CaSignal.ROIDiameter+1, 2*CaSignal.ROIDiameter+1], 'EdgeColor','g');
		hold off
		I = uint8(zeros(2 * CaSignal.ROIDiameter + 1,  2 * CaSignal.ROIDiameter + 1, size(CaSignal.imageData, 3)));
		I(1:y_end - y_start + 1, 1:x_end - x_start + 1,:) = CaSignal.imageData(y_start:y_end, x_start:x_end,:);
		C = semanticseg(I, CaSignal.localFCNModel.net);
		C_int = uint8(C) - 1;
		BW = imbinarize(C_int);
		B = bwboundaries(BW, 'noholes');
		if numel(B) > 0
			boundary = B{1};
			CaSignal.TempROI = {y_start, y_end, x_start, x_end, C_int, boundary, CaSignal.ROI_num + 1, 'T'};
			CaSignal = update_cell_score_map(CaSignal, CaSignal.TempROI);
			CaSignal = update_subimage_show(handles, CaSignal, true);
		end
	end
end