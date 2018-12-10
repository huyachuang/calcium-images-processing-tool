function [img_patch_boxes_survived, img_patch_scores_survived, roi_masks_survived] = remove_redundant_roi(img_patch_boxes, img_patch_scores, roi_masks, img_h, img_w)
	idx = false(size(roi_masks, 3), 1);
	roi_masks_fullsize = zeros(img_h, img_w, size(roi_masks, 3));
	mask_boxes = zeros(size(roi_masks, 3), 4);
	for i = 1:size(roi_masks, 3)
		roi_masks_fullsize(img_patch_boxes(i, 1):img_patch_boxes(i, 1)+img_patch_boxes(i, 3)-1,...
							img_patch_boxes(i, 2):img_patch_boxes(i, 2)+img_patch_boxes(i, 4)-1, i) = roi_masks(:, :, i);
		B = bwboundaries(roi_masks_fullsize(:, :, i), 'noholes');
		if numel(B) == 1
			boundary = B{1};
			x = boundary(:,2);
			y = boundary(:,1);
			w = max(x(:)) - min(x(:));
			h = max(y(:)) - min(y(:));
			if w > 7 && h > 7
				idx(i) = true;
				mask_boxes(i, :) = [min(x(:)), min(y(:)), w, h];
			end
		end
	end
	
	img_patch_scores = img_patch_scores(idx, :);
	img_patch_boxes = img_patch_boxes(idx, :);
	roi_masks = roi_masks(:, :, idx);
	roi_masks_fullsize = roi_masks_fullsize(:, :, idx);
	mask_boxes = mask_boxes(idx, :);
	
	remain_idx = non_maximum_suppression(mask_boxes, img_patch_scores, 0.1);
	
	img_patch_boxes_survived = img_patch_boxes(remain_idx, :);
	img_patch_scores_survived = img_patch_scores(remain_idx, :);
	roi_masks_survived = roi_masks(:, :, remain_idx);
	
end