function CaSignal = find_next_fcn(handles, CaSignal)
	if get(handles.NextROICheckBox,'Value') == 1
		CaSignal.cell_score = CaSignal.cell_score .* CaSignal.cell_score_mask;
		maximum = max(CaSignal.cell_score(:));
		[y, x] = find(CaSignal.cell_score == maximum);
		x_start = x - CaSignal.ROIDiameter;
		if x_start < 1 
			x_start = 1;
		end
		x_end = x + CaSignal.ROIDiameter;
		if x_end > size(CaSignal.imageData, 2)
			x_end = size(CaSignal.imageData, 2);
		end
		y_start = y - CaSignal.ROIDiameter;
		if y_start < 1
			y_start = 1;
		end
		y_end = y + CaSignal.ROIDiameter;
		if y_end > size(CaSignal.imageData, 1)
			y_end = size(CaSignal.imageData, 1);
		end
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
		boundary = B{1};
		CaSignal.TempROI = {y_start, y_end, x_start, x_end, C_int, boundary, CaSignal.ROI_num + 1, 'T'};
		tempMask = zeros(size(CaSignal.imageData, 1), size(CaSignal.imageData, 2));
		tempMask(y_start:y_end, x_start:x_end) = C_int(1:y_end - y_start + 1, 1:x_end - x_start + 1);
		CaSignal.cell_score_mask = and(CaSignal.cell_score_mask, 1 - tempMask);
		CaSignal = update_subimage_show(handles, CaSignal);
	end
end