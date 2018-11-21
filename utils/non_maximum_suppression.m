function remain_idx = non_maximum_suppression(boxes, score, overlap_th)
% boxes [N, 4] matrix, with each row of [x, y, windth, height]
% score [N, 1] matrix with socre of each boxes
% overlap_th overlap threshold
	[score_sorted, sorted_score_idx] = sort(score, 'descend');
	boxes_sorted = boxes(sorted_score_idx, :);
	overlapRatio = bboxOverlapRatio(boxes_sorted, boxes_sorted, 'Min');
	overlapRatio_pos = overlapRatio > overlap_th;
	overlapRatio_pos = logical(overlapRatio_pos - diag(diag(overlapRatio_pos)));
	idx = true(size(overlapRatio_pos, 1), 1);
	for i = 1:size(overlapRatio_pos, 1)
		if idx(i)
			idx(overlapRatio_pos(i, :)) = false;
		end
	end
	remain_idx = sorted_score_idx(idx);
end