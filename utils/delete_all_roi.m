function CaSignal = delete_all_roi(CaSignal)
	CaSignal.ROIs = {};
	CaSignal.ROI_num = 0;
	CaSignal.ROI_T_num = 0;
	CaSignal.TempROI = {};
	CaSignal.SummarizedMask = zeros(CaSignal.image_height, CaSignal.image_width);
end