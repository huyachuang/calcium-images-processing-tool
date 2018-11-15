function CaSignal = Image_buttonDown_fcn(hObject,eventdata, handles, CaSignal)

	x = uint16(eventdata.IntersectionPoint(1));
	y = uint16(eventdata.IntersectionPoint(2));
	CaSignal.TempXY = [x, y];
	
	if get(handles.DrawROICheckbox,'Value') == 1 && CaSignal.SummarizedMask(y, x) == 0
		[x_start, x_end, y_start, y_end] = generate_loaction_boxes(CaSignal, x, y);
		I = uint8(zeros(2 * CaSignal.ROIDiameter + 1,  2 * CaSignal.ROIDiameter + 1, size(CaSignal.imageData, 3)));
		I(1:y_end - y_start + 1, 1:x_end - x_start + 1,:) = CaSignal.imageData(y_start:y_end, x_start:x_end,:);
		C = semanticseg(I, CaSignal.localFCNModel.net);
		C_int = uint8(C) - 1;
		BW = imbinarize(C_int);
		B = bwboundaries(BW, 'noholes');
		if numel(B) >= 1
			boundary = B{1};
			CaSignal.TempROI = {y_start, y_end, x_start, x_end, C_int, boundary, CaSignal.ROI_num + 1, 'T'};
			CaSignal = update_subimage_show(handles, CaSignal);
		end
	elseif ~isequal(CaSignal.SummarizedMask, []) && CaSignal.SummarizedMask(y, x) > 0
		CaSignal.TempROI = CaSignal.ROIs{CaSignal.SummarizedMask(y, x)};
		CaSignal = update_subimage_show(handles, CaSignal);
	else
		CaSignal = update_subimage_show(handles, CaSignal);
	end
end