function CaSignal = faster_rcnn_detect(CaSignal)
	
	detector = CaSignal.FasterRCNNDetector;
	imageData = gray2RGB(CaSignal.showing_image);
	FasterRCNNDetectorPathName = CaSignal.FasterRCNNDetectorPathName;
	FasterRCNNDetectorFilename = CaSignal.FasterRCNNDetectorFilename;
	ROIDiameter = CaSignal.ROIDiameter;
	ROI_num = CaSignal.ROI_num;
	localFCNModel = CaSignal.localFCNModel.net;
% 	using faster rcnn detect roi
	
	faster_rcnn_inputSize = detector.Network.Layers(1).InputSize;
	scale_h = faster_rcnn_inputSize(1) / size(imageData, 1);
	scale_w = faster_rcnn_inputSize(2) / size(imageData, 2);
	resized_imageData = imresize(imageData, faster_rcnn_inputSize(1:2));
	[resized_bboxes,scores] = detect(detector, resized_imageData,...
		'ExecutionEnvironment', 'cpu', 'Threshold', 0.6);
% 	remain_idx = non_maximum_suppression(resized_bboxes, scores, 0.1);
% 	resized_bboxes = resized_bboxes(remain_idx, :);
	bboxes = zeros(size(resized_bboxes));
	bboxes(:, 1) = ceil(resized_bboxes(:, 1) / scale_w);
	bboxes(:, 3) = ceil(resized_bboxes(:, 3) / scale_w);
	bboxes(:, 2) = ceil(resized_bboxes(:, 2) / scale_h);
	bboxes(:, 4) = ceil(resized_bboxes(:, 4) / scale_h);
	assignin('base', 'imageData', imageData);
	assignin('base', 'resized_imageData', resized_imageData);
	assignin('base', 'bboxes', bboxes);
	assignin('base', 'resized_bboxes', resized_bboxes);
	
	fcn_faster_rcnn_filename = fullfile(FasterRCNNDetectorPathName,...
		strcat('fcn_', FasterRCNNDetectorFilename));
	fcn_model = load(fcn_faster_rcnn_filename);
	fcn_lgraph = layerGraph(fcn_model.net);
	fcn_inputSize = fcn_lgraph.Layers(1).InputSize;
%  using fcn do segmentation	
	img_patches = zeros([fcn_inputSize(1), fcn_inputSize(2), fcn_inputSize(3), size(bboxes, 1)]);
% 	img_pathces_boxes = zeros([size(bboxes, 1), 4]);
	for i = 1:size(bboxes, 1)
		img_patches(:, :, :, i) = ...
			imresize(...
			imcrop(imageData, ...
			[bboxes(i,1), bboxes(i,2), bboxes(i,3), bboxes(i,4)]),...
			fcn_inputSize(1:2));
	end	
	roi_masks_resized = semanticseg(imresize(img_patches, fcn_inputSize(1:2)), fcn_model.net, ...
								'MiniBatchSize',16, ...
								'WriteLocation',fullfile(pwd, 'result'), ...
								'Verbose',false);
	roi_masks_resized = uint8(roi_masks_resized) - 1;
	roi_masks = {};
	for i = 1:size(bboxes, 1)
		roi_masks{i} = ...
			imbinarize(imresize(roi_masks_resized(:, :, i), [bboxes(i, 4), bboxes(i, 3)], 'Method', 'nearest'));
	end	
	assignin('base', 'roi_masks', roi_masks);
% 	filter roi

	bin_size = 2 * ROIDiameter + 1;
	ROIs = CaSignal.ROIs;
	for i = 1:numel(roi_masks)
		B = bwboundaries(roi_masks{i}, 'noholes');
		if numel(B) >= 1
			boundary = B{1};
			centre_y = round(mean(boundary(:, 1)));
			centre_x = round(mean(boundary(:, 2)));
			y = centre_y + bboxes(i, 2);
			x = centre_x + bboxes(i, 1);
			[x_start, x_end, y_start, y_end] = generate_loaction_boxes(CaSignal, x, y);
			I = zeros([bin_size, bin_size, size(imageData, 3)]);
			I(1:(y_end - y_start + 1), 1:(x_end - x_start + 1),:) = imageData(y_start:y_end, x_start:x_end,:);
			% resize image patch based on localFCNModel input size
			lgraph= layerGraph(localFCNModel);
			inputSize = lgraph.Layers(1).InputSize;
			I_resize = imresize(I, inputSize(1:2));
			% run segmentation
			C = semanticseg(I_resize, localFCNModel, 'OutputType', 'uint8');
			C = C - 1;
			% resize back
			C = imresize(C, [bin_size, bin_size], 'Method', 'nearest');
			BW = imbinarize(C);
			B = bwboundaries(BW, 'noholes');
			if numel(B) >= 1
				boundary = B{1};
				mask = uint8(poly2mask(boundary(:,2), boundary(:,1), double(y_end - y_start + 1), double(x_end - x_start + 1)));
				ROI_num = ROI_num + 1;
				ROIs{ROI_num} = ...
					{y_start, y_end, x_start, x_end,...
					mask, boundary, ROI_num, 'T', scores(i)};
% 				end
			end
		end
	end
	CaSignal.ROIs = ROIs;
	CaSignal.ROI_T_num = CaSignal.ROI_T_num + (ROI_num - CaSignal.ROI_num);
	CaSignal.ROI_num = ROI_num;
	if CaSignal.ROI_num > 0
		CaSignal.TempROI = CaSignal.ROIs{1};
	end
	CaSignal = remove_redundant_roi(CaSignal, true, true);
end