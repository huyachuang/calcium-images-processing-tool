function CaSignal = detect_roi(CaSignal)
	% config image patch size and step size
	bin_size = 2 * CaSignal.ROIDiameter + 1;
	step_size = floor(CaSignal.ROIDiameter / 2);
	% prepare data
	net = CaSignal.ROIDetector.net;
	lgraph = layerGraph(net);
	inputSize = lgraph.Layers(1).InputSize;
	img_patches_boxes = get_square_patches_boxes(CaSignal.imageData, bin_size, step_size);
	img_patches_boxes = reshape(img_patches_boxes, size(img_patches_boxes, 1)*size(img_patches_boxes, 2), size(img_patches_boxes, 3));
	img_patches = zeros([bin_size, bin_size, size(CaSignal.imageData, 3), size(img_patches_boxes, 1)]);
	for i = 1:size(img_patches_boxes, 1)
		img_patches(:, :, :, i) = CaSignal.imageData(img_patches_boxes(i, 1):img_patches_boxes(i, 1)+img_patches_boxes(i, 3)-1,...
				img_patches_boxes(i, 2):img_patches_boxes(i, 2)+img_patches_boxes(i, 4)-1, :);
	end
	% detect
	[YPred_patches, probs_patches] = classify(net,imresize(img_patches, inputSize(1:2)));
	% find roi patches used to do segmentation
	roi_probs = probs_patches(YPred_patches == categorical({'cell'}), :);
	roi_probs = max(roi_probs, [], 2);
	roi_boxes = img_patches_boxes(YPred_patches == categorical({'cell'}), :);
	roi_patches = img_patches(:, :, :, YPred_patches == categorical({'cell'}));
	% resize and do segmentation
	fcn_lgraph = layerGraph(CaSignal.localFCNModel.net);
	fcn_inputSize = fcn_lgraph.Layers(1).InputSize;
	roi_mask = semanticseg(imresize(roi_patches, fcn_inputSize(1:2)), CaSignal.localFCNModel.net, ...
								'MiniBatchSize',16, ...
								'WriteLocation',fullfile(pwd, 'result'), ...
								'Verbose',false);
	roi_mask = uint8(roi_mask) - 1;
	roi_mask = imresize(roi_mask, [bin_size, bin_size], 'Method', 'nearest');
	roi_mask = imbinarize(roi_mask);
% 	remove redundant rois base on some rules
	[roi_patch_boxes_remain, roi_patch_scores_remain, roi_masks_remain] = ...
		remove_redundant_roi(roi_boxes, roi_probs, roi_mask,...
		size(CaSignal.imageData, 1), size(CaSignal.imageData, 2));
	
	ROI_num = 0;
	for i = 1:size(roi_masks_remain, 3)
		B = bwboundaries(roi_masks_remain(:, :, i), 'noholes');
		if numel(B) >= 1
			boundary = B{1};
			centre_y = mean(boundary(:, 1));
			centre_x = mean(boundary(:, 2));
			distance_y = boundary(:, 1) - centre_y;
			distance_x = boundary(:, 2) - centre_x;
			distance = sqrt(distance_y.^2 + distance_x.^2);
			if min(distance) > CaSignal.ROIDiameter*(1/4) && max(distance) < CaSignal.ROIDiameter*(3/3)
				ROI_num = ROI_num + 1;
				CaSignal.ROIs{ROI_num} = ...
					{roi_patch_boxes_remain(i, 1), roi_patch_boxes_remain(i, 1)+roi_patch_boxes_remain(i, 3)-1,...
					roi_patch_boxes_remain(i, 2), roi_patch_boxes_remain(i, 2)+roi_patch_boxes_remain(i, 4)-1,...
					uint8(roi_masks_remain(:, :, i)), boundary, ROI_num, 'T'};
			end
		end
	end
	CaSignal.ROI_num = ROI_num;
	CaSignal.ROI_T_num = ROI_num;
	if CaSignal.ROI_num > 0
		CaSignal.TempROI = CaSignal.ROIs{1};
	end
end