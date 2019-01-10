function CaSignal = remove_redundant_roi(CaSignal, use_NMS, use_Diameter)
	
	roi_diameter = CaSignal.ROIDiameter;
	ROI_num = CaSignal.ROI_num;
	ROIs = CaSignal.ROIs;
	assignin('base', 'ROIs_1', ROIs)
	nms_th = 0.3;
	diameter_buttom_th = roi_diameter*1/4;
	diameter_top_th = roi_diameter;
	scores = [];
	bboxes = [];
	idx_1 = true(1, ROI_num);
	for i = 1:ROI_num	
		is_postitive = ROIs{i}{8};
		if is_postitive == 'F'
			idx_1(i) = false;
			continue
		end
		boundary = ROIs{i}{6};
		y_start = ROIs{i}{1};
		x_start = ROIs{i}{3};
		x = boundary(:,2) + x_start;
		y = boundary(:,1) + y_start;
		if use_Diameter
			centre_y = mean(y);
			centre_x = mean(x);
			distance_y = y - centre_y;
			distance_x = x - centre_x;
			distance = sqrt(distance_y.^2 + distance_x.^2);
			if min(distance) < diameter_buttom_th || max(distance) > diameter_top_th
					idx_1(i) = false;
					continue
			end
		end
		w = max(x(:)) - min(x(:));
		h = max(y(:)) - min(y(:));
		bboxes = [bboxes; [min(x(:)), min(y(:)), w, h]];
		scores = [scores, ROIs{i}{9}];
	end
	ROIs = ROIs(idx_1);
	assignin('base', 'ROIs_2', ROIs)
	if use_NMS
		[score_sorted, sorted_score_idx] = sort(scores, 'descend');
		boxes_sorted = bboxes(sorted_score_idx, :);
		overlapRatio = bboxOverlapRatio(boxes_sorted, boxes_sorted, 'Min');
		overlapRatio_pos = overlapRatio > nms_th;
		overlapRatio_pos = logical(overlapRatio_pos - diag(diag(overlapRatio_pos)));
		idx_2 = true(size(overlapRatio_pos, 1), 1);
		for ii = 1:size(overlapRatio_pos, 1)
			if idx_2(ii)
				idx_2(overlapRatio_pos(ii, :)) = false;
			end
		end
		remain_idx = sorted_score_idx(idx_2);	
		ROIs = ROIs(remain_idx);
	end
	for i = 1:numel(ROIs)
		ROIs{i}{7} = i;
	end
	assignin('base', 'ROIs_3', ROIs)
	CaSignal.ROIs = ROIs;
	CaSignal.ROI_num = numel(ROIs);
	CaSignal.ROI_T_num = numel(ROIs);
end