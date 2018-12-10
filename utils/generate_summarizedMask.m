function CaSignal = generate_summarizedMask(CaSignal)
	ROIs = CaSignal.ROIs;
% 	assignin('base','ROIs',ROIs)
	CaSignal.SummarizedMask = zeros(size(CaSignal.imageData, 1), size(CaSignal.imageData, 2));
	for i = 1:CaSignal.ROI_num
		tempMask = zeros(size(CaSignal.imageData, 1), size(CaSignal.imageData, 2));
		y_start = CaSignal.ROIs{i}{1};
		y_end = CaSignal.ROIs{i}{2};
		x_start = CaSignal.ROIs{i}{3};
		x_end = CaSignal.ROIs{i}{4};
		tempRoi = CaSignal.ROIs{i}{5};
		tempMask(y_start:y_end, x_start:x_end) = tempRoi(1:y_end - y_start + 1, 1:x_end - x_start + 1);
		CaSignal.SummarizedMask(tempMask == 1) = CaSignal.ROIs{i}{7};
	end
end