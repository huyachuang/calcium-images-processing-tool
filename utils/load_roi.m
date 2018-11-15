function ROIs = load_roi(filename, CaSignal)
	data = load(filename);
	if isfield(data, 'ROIInfo')
		ROIs = data.ROIInfo;
	elseif isfield(data, 'ROIinfoBU')
		ROIs = {};
		ROImask = data.ROIinfoBU.ROImask;
		for i = 1:length(ROImask)
			tempROI = {};
			mask = ROImask{i};
			[ys, xs] = find(mask);
			x = uint16(median(xs, 'all'));
			y = uint16(median(ys, 'all'));
			[x_start, x_end, y_start, y_end] = generate_loaction_boxes(CaSignal, x, y);
			tempROI{1} = y_start;
			tempROI{2} = y_end;
			tempROI{3} = x_start;
			tempROI{4} = x_end;
			sub_mask = uint8(zeros(2 * CaSignal.ROIDiameter + 1,  2 * CaSignal.ROIDiameter + 1));
			sub_mask(1:y_end - y_start + 1, 1:x_end - x_start + 1) = mask(y_start:y_end, x_start:x_end);
			tempROI{5} = sub_mask;
			B = bwboundaries(sub_mask, 'noholes');
			tempROI{6} = B{1};
			tempROI{7} = i;
			tempROI{8} = 'T';
			ROIs{i} = tempROI;
		end
	else
		ROIs = {};
		f = msgbox('load ROI file failed! check if you chose the correct file.', 'Error', 'error');
	end
end