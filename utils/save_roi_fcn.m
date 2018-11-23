function CaSignal = save_roi_fcn(CaSignal, handles)
	if ~isempty(CaSignal.TempROI) && CaSignal.TempROI{7} > CaSignal.ROI_num
		CaSignal.ROI_num = CaSignal.ROI_num + 1;
		CaSignal.ROI_T_num = CaSignal.ROI_T_num + 1;
		CaSignal.ROIs{CaSignal.ROI_num} = CaSignal.TempROI;
		tempMask = zeros(size(CaSignal.imageData, 1), size(CaSignal.imageData, 2));
		y_start = CaSignal.TempROI{1};
		y_end = CaSignal.TempROI{2};
		x_start = CaSignal.TempROI{3};
		x_end = CaSignal.TempROI{4};
		tempRoi = CaSignal.TempROI{5};
		tempMask(y_start:y_end, x_start:x_end) = tempRoi(1:y_end - y_start + 1, 1:x_end - x_start + 1);
		idx = find(tempMask);
		CaSignal.SummarizedMask(idx) = CaSignal.TempROI{7};
		set(handles.ROINumShowText, 'String', num2str(CaSignal.ROI_T_num));
		sprintf('save ROI %d', CaSignal.ROI_T_num)
	elseif ~isempty(CaSignal.TempROI) && CaSignal.TempROI{7} <= CaSignal.ROI_num
		y_start = CaSignal.TempROI{1};
		y_end = CaSignal.TempROI{2};
		x_start = CaSignal.TempROI{3};
		x_end = CaSignal.TempROI{4};
		tempRoi = CaSignal.TempROI{5};
		CaSignal.SummarizedMask(CaSignal.SummarizedMask == CaSignal.TempROI{7}) = 0;
		tempMask = zeros(size(CaSignal.imageData, 1), size(CaSignal.imageData, 2));
		tempMask(y_start:y_end, x_start:x_end) = tempRoi(1:y_end - y_start + 1, 1:x_end - x_start + 1);
		idx = find(tempMask);
		CaSignal.SummarizedMask(idx) = CaSignal.TempROI{7};
	end
end