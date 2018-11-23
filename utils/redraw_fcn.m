function CaSignal = redraw_fcn(handles, CaSignal)
	x = CaSignal.TempXY(1);
	y = CaSignal.TempXY(2);
	if numel(CaSignal.TempROI) ~= 0 ...
		&& (x >= CaSignal.TempROI{3} && x <= CaSignal.TempROI{4} && y >= CaSignal.TempROI{1} && y <= CaSignal.TempROI{2})
		CaSignal.TempROI{8} = 'F';
		CaSignal = update_subimage_show(handles, CaSignal, true);
% 		roi_idx = CaSignal.TempROI{7};
		y_start = CaSignal.TempROI{1};
		y_end = CaSignal.TempROI{2};
		x_start = CaSignal.TempROI{3};
		x_end = CaSignal.TempROI{4};
		h_draw = imfreehand;
		if numel(h_draw) == 0
			return;
		end
		% pos = h_draw.getPosition;
		BW = createMask(h_draw);
		B = bwboundaries(BW, 'noholes');
		if numel(B) > 0
			boundary = B{1};
			CaSignal.TempROI = {y_start, y_end, x_start, x_end, BW, boundary, CaSignal.TempROI{7}, 'T'};

			if CaSignal.TempROI{7} <= CaSignal.ROI_num
				CaSignal.ROIs{CaSignal.TempROI{7}} = CaSignal.TempROI;
			end
			CaSignal = update_subimage_show(handles, CaSignal, true);
		end
	else
		axes(handles.SubimageShowAxes);
		[x_start, x_end, y_start, y_end] = generate_loaction_boxes(CaSignal, x, y);
		h_draw = imfreehand;
		if numel(h_draw) == 0
			return;
		end
		% pos = h_draw.getPosition;
		BW = createMask(h_draw);
		B = bwboundaries(BW, 'noholes');
		boundary = B{1};
		if numel(B) > 0
			CaSignal.TempROI = {y_start, y_end, x_start, x_end, BW, boundary, CaSignal.ROI_num + 1, 'T'};
			CaSignal = update_subimage_show(handles, CaSignal, true);
		end
	end
end
