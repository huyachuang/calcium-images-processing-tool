function CaSignal = detect_roi(CaSignal)

	ROIDiameter = CaSignal.ROIDiameter;
	imageData = gray2RGB(CaSignal.showing_image);
	localFCNModel = CaSignal.localFCNModel.net;
	ROIDetector = CaSignal.ROIDetector.net;
	localFCNModelPathName = CaSignal.localFCNModelPathName;
	
	% config image patch size and step size
	bin_size = 2 * ROIDiameter + 1;
	step_size = floor(ROIDiameter / 2);
	% prepare data
	lgraph = layerGraph(ROIDetector);
	inputSize = lgraph.Layers(1).InputSize;
	img_patches_boxes = get_square_patches_boxes(imageData, bin_size, step_size);
	img_patches_boxes = reshape(img_patches_boxes, size(img_patches_boxes, 1)*size(img_patches_boxes, 2), size(img_patches_boxes, 3));
	img_patches = zeros([bin_size, bin_size, size(imageData, 3), size(img_patches_boxes, 1)]);
	for i = 1:size(img_patches_boxes, 1)
		img_patches(:, :, :, i) = imageData(img_patches_boxes(i, 1):img_patches_boxes(i, 1)+img_patches_boxes(i, 3)-1,...
				img_patches_boxes(i, 2):img_patches_boxes(i, 2)+img_patches_boxes(i, 4)-1, :);
	end
	% detect
	[YPred_patches, probs_patches] = classify(ROIDetector,imresize(img_patches, inputSize(1:2)));
	% find roi patches used to do segmentation
	roi_probs = probs_patches(YPred_patches == categorical({'cell'}), :);
	roi_probs = max(roi_probs, [], 2);
	roi_boxes = img_patches_boxes(YPred_patches == categorical({'cell'}), :);
	roi_patches = img_patches(:, :, :, YPred_patches == categorical({'cell'}));
	% resize and do segmentation
	fcn_lgraph = layerGraph(localFCNModel);
	fcn_inputSize = fcn_lgraph.Layers(1).InputSize;
	roi_mask = semanticseg(imresize(roi_patches, fcn_inputSize(1:2)), localFCNModel, ...
								'MiniBatchSize',16, ...
								'WriteLocation',fullfile(localFCNModelPathName, 'result'), ...
								'Verbose',false);
	
	roi_mask = uint8(roi_mask) - 1;
	roi_mask = imresize(roi_mask, [bin_size, bin_size], 'Method', 'nearest');
	roi_mask = imbinarize(roi_mask);
% 	remove redundant rois base on some rules
% 	[roi_patch_boxes_remain, roi_patch_scores_remain, roi_masks_remain] = ...
% 		remove_redundant_roi(roi_boxes, roi_probs, roi_mask,...
% 		size(CaSignal.imageData, 1), size(CaSignal.imageData, 2), CaSignal.ROIDiameter);
	
	ROI_num = CaSignal.ROI_num;
	ROIs = CaSignal.ROIs;
	for i = 1:size(roi_mask, 3)
		B = bwboundaries(roi_mask(:, :, i), 'noholes');
		if numel(B) >= 1
			boundary = B{1};
			mask = uint8(poly2mask(boundary(:,2), boundary(:,1),...
				double(roi_boxes(i, 3)), double(roi_boxes(i, 4))));
			ROI_num = ROI_num + 1;
			ROIs{ROI_num} = ...
				{roi_boxes(i, 1), roi_boxes(i, 1)+roi_boxes(i, 3)-1,...
				roi_boxes(i, 2), roi_boxes(i, 2)+roi_boxes(i, 4)-1,...
				mask, boundary, ROI_num, 'T',...
				roi_probs(i)};
		end
	end
	
	CaSignal.ROIs = ROIs;
	CaSignal.ROI_num = ROI_num;
	CaSignal.ROI_T_num = ROI_num;
	if CaSignal.ROI_num > 0
		CaSignal.TempROI = CaSignal.ROIs{1};
	end
	CaSignal = remove_redundant_roi(CaSignal, true, true);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [img_patch_boxes_survived, img_patch_scores_survived, roi_masks_survived] = remove_redundant_roi(img_patch_boxes, img_patch_scores, roi_masks, img_h, img_w, roi_diameter)
% 	idx = false(size(roi_masks, 3), 1);
% 	roi_masks_fullsize = zeros(img_h, img_w, size(roi_masks, 3));
% 	mask_boxes = zeros(size(roi_masks, 3), 4);
% 	for i = 1:size(roi_masks, 3)
% 		roi_masks_fullsize(img_patch_boxes(i, 1):img_patch_boxes(i, 1)+img_patch_boxes(i, 3)-1,...
% 							img_patch_boxes(i, 2):img_patch_boxes(i, 2)+img_patch_boxes(i, 4)-1, i) = roi_masks(:, :, i);
% 		B = bwboundaries(roi_masks_fullsize(:, :, i), 'noholes');
% 		if numel(B) == 1
% 			boundary = B{1};
% 			x = boundary(:,2);
% 			y = boundary(:,1);
% 			w = max(x(:)) - min(x(:));
% 			h = max(y(:)) - min(y(:));
% 			centre_y = mean(y);
% 			centre_x = mean(x);
% 			distance_y = y - centre_y;
% 			distance_x = x - centre_x;
% 			distance = sqrt(distance_y.^2 + distance_x.^2);
% 			if min(distance) > roi_diameter*0.25 %&& max(distance) < roi_diameter*0.8
% 				idx(i) = true;
% 				mask_boxes(i, :) = [min(x(:)), min(y(:)), w, h];
% 			end
% 		end
% 	end
% 	
% 	img_patch_scores = img_patch_scores(idx, :);
% 	img_patch_boxes = img_patch_boxes(idx, :);
% 	roi_masks = roi_masks(:, :, idx);
% 	roi_masks_fullsize = roi_masks_fullsize(:, :, idx);
% 	mask_boxes = mask_boxes(idx, :);
% 	
% 	remain_idx = non_maximum_suppression(mask_boxes, img_patch_scores, 0.1);
% 	
% 	img_patch_boxes_survived = img_patch_boxes(remain_idx, :);
% 	img_patch_scores_survived = img_patch_scores(remain_idx, :);
% 	roi_masks_survived = roi_masks(:, :, remain_idx);
% 	
% end