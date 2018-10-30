function CaSignal = Image_buttonDown_fcn(hObject,eventdata, handles, CaSignal)
	x = uint16(eventdata.IntersectionPoint(1));
	y = uint16(eventdata.IntersectionPoint(2));
	if get(handles.DrawROICheckbox,'Value') == 1
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
		I = uint8(zeros(2 * CaSignal.ROIDiameter + 1,  2 * CaSignal.ROIDiameter + 1, size(CaSignal.imageData, 3)));
		I(1:y_end - y_start + 1, 1:x_end - x_start + 1,:) = CaSignal.imageData(y_start:y_end, x_start:x_end,:);
		C = semanticseg(I, CaSignal.model.net);
		C_int = uint8(C) - 1;
		BW = imbinarize(C_int);
		B = bwboundaries(BW, 'noholes');
		boundary = B{1};
		CaSignal.TempROI = {y_start, y_end, x_start, x_end, C_int, boundary, CaSignal.ROI_num + 1, 'T'};
		CaSignal = update_subimage_show(handles, CaSignal);
	else
		if CaSignal.SummarizedMask(y, x) > 0
			CaSignal.TempROI = CaSignal.ROIs{CaSignal.SummarizedMask(y, x)};
			CaSignal = update_subimage_show(handles, CaSignal);
		end
end