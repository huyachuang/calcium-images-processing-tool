function CaSignal = Image_buttonDown_fcn(hObject,eventdata, handles, CaSignal)

	x = uint16(eventdata.IntersectionPoint(1));
	y = uint16(eventdata.IntersectionPoint(2));
	CaSignal.TempXY = [x, y];
	if get(handles.DrawROICheckbox,'Value') == 1 && CaSignal.SummarizedMask(y, x) == 0
		% get image patch for segmentation
		[x_start, x_end, y_start, y_end] = generate_loaction_boxes(CaSignal, x, y);
		sub_image_size = 2 * CaSignal.ROIDiameter + 1;
		I = uint8(zeros(sub_image_size,  sub_image_size, size(CaSignal.imageData, 3)));
		I(1:y_end - y_start + 1, 1:x_end - x_start + 1,:) = CaSignal.imageData(y_start:y_end, x_start:x_end,:);
		% resize image patch based on localFCNModel input size
		lgraph= layerGraph(CaSignal.localFCNModel.net);
		inputSize = lgraph.Layers(1).InputSize;
		I_resize = imresize(I, inputSize(1:2));
		% run segmentation
		C = semanticseg(I_resize, CaSignal.localFCNModel.net);
		C_int = uint8(C) - 1;
		% resize back
		C_int = imresize(C_int, [sub_image_size, sub_image_size], 'Method', 'nearest');
		BW = imbinarize(C_int);
		B = bwboundaries(BW, 'noholes');
		if numel(B) >= 1
			boundary = B{1};
			CaSignal.TempROI = {y_start, y_end, x_start, x_end, C_int, boundary, CaSignal.ROI_num + 1, 'T'};
			CaSignal = update_subimage_show(handles, CaSignal, true);
		end
		CaSignal.RedrawBasedOnTempROI = true;
	elseif ~isequal(CaSignal.SummarizedMask, []) && CaSignal.SummarizedMask(y, x) > 0
		CaSignal.TempROI = CaSignal.ROIs{CaSignal.SummarizedMask(y, x)};
		set(handles.CurrentROINoEdit, 'String', num2str(CaSignal.TempROI{7}));
		CaSignal = update_subimage_show(handles, CaSignal, true);
		CaSignal.RedrawBasedOnTempROI = true;
	else
		CaSignal = update_subimage_show(handles, CaSignal, false);
		CaSignal.RedrawBasedOnTempROI = false;
	end
end