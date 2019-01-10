function CaSignal = retrain_faster_rcnn_detector(CaSignal, datapath)
	%set parameter
	InitialLearnRate = 1e-3;
	MaxEpochs = 300;
	MiniBatchSize = 1;
	ExecutionEnvironment = 'cpu';
	title = 'Set Training Parameter';
	prompt = {'InitialLearnRate:', 'MaxEpochs:', 'MiniBatchSize:', 'ExecutionEnvironment'};
	definput = {num2str(InitialLearnRate), num2str(MaxEpochs), num2str(MiniBatchSize), 'cpu'};
	dims = [1 100];
	answer = inputdlg(prompt, title, dims, definput);
	if numel(answer) > 0
		InitialLearnRate = str2double(answer{1});
		MaxEpochs = str2double(answer{2});
		MiniBatchSize = str2double(answer{3});
		ExecutionEnvironment = answer{4};
	end
	%prepare training data
	dst_dir = fullfile(CaSignal.FasterRCNNDetectorPathName, 'faster_rcnn_temp_training_dataset');
	disp('Generating training data');
	[training_dataset, fcn_training_data_dir] = generate_faster_rcnn_training_data(datapath, dst_dir, CaSignal.ROIDiameter);
	disp('Done');
	training_dataset.filenames = fullfile(dst_dir, training_dataset.filenames);
	% Options for step 1.
	checkpoint_path = fullfile(CaSignal.FasterRCNNDetectorPathName, 'logs/faster_rcnn');
	if ~exist(checkpoint_path, 'dir')
		mkdir(checkpoint_path)
	end
	optionsStage1 = trainingOptions('sgdm', ...
    'MaxEpochs', MaxEpochs, ...
    'MiniBatchSize', MiniBatchSize, ...
    'InitialLearnRate', InitialLearnRate, ...
	'ExecutionEnvironment', ExecutionEnvironment, ...
    'CheckpointPath', checkpoint_path);

	% Options for step 2.
	optionsStage2 = trainingOptions('sgdm', ...
	'MaxEpochs', MaxEpochs, ...
	'MiniBatchSize', MiniBatchSize, ...
	'InitialLearnRate', InitialLearnRate, ...
	'ExecutionEnvironment', ExecutionEnvironment, ...
	'CheckpointPath', checkpoint_path);

	% Options for step 3.
	optionsStage3 = trainingOptions('sgdm', ...
	'MaxEpochs', MaxEpochs, ...
	'MiniBatchSize', MiniBatchSize, ...
	'InitialLearnRate', InitialLearnRate*0.1, ...
	'ExecutionEnvironment', ExecutionEnvironment, ...
	'CheckpointPath', checkpoint_path);

	% Options for step 4.
	optionsStage4 = trainingOptions('sgdm', ...
	'MaxEpochs', MaxEpochs, ...
	'MiniBatchSize', MiniBatchSize, ...
	'InitialLearnRate', InitialLearnRate*0.1, ...
	'ExecutionEnvironment', ExecutionEnvironment, ...
	'CheckpointPath', checkpoint_path);

	options = [
	optionsStage1
	optionsStage2
	optionsStage3
	optionsStage4
	];
	
	%freeze layer weight
	lgraph = layerGraph(CaSignal.FasterRCNNDetector.Network);
	layers = lgraph.Layers;
	connections = lgraph.Connections;
	for ii = 1:36
		props = properties(layers(ii));
		for p = 1:numel(props)
			propName = props{p};
			if ~isempty(regexp(propName, 'LearnRateFactor$', 'once'))
				layers(ii).(propName) = 0.5;
			end
		end
	end
	lgraph = createLgraphUsingConnections(layers,connections);
	
	detector = trainFasterRCNNObjectDetector(training_dataset,...
		lgraph, options, ...
		'NegativeOverlapRange', [0 0.3], ...
		'PositiveOverlapRange', [0.3 1], ...
		'NumRegionsToSample', 1000, ...
		'SmallestImageDimension', 512);
	
	[file, path] = uiputfile('*.mat', 'Save trained model file');
	if isequal(file,0) || isequal(path,0)
		answer = questdlg('Sure you do NOT want save trained model ?', 'Alert query');
		switch answer
			case 'Yes'
				return;
			case 'No'
				[file, path] = uiputfile('*.mat', 'Save trained model file');
				if isequal(file,0) || isequal(path,0)
					return
				end
			case 'Cancel'
				[file, path] = uiputfile('*.mat', 'Save trained model file');
				if isequal(file,0) || isequal(path,0)
					return
				end
		end
	end
	CaSignal.FasterRCNNDetector = detector;
	CaSignal.FasterRCNNDetectorFilename = file;
	CaSignal.FasterRCNNDetectorPathName = path;
	save(fullfile(path, file), 'detector');
	
	% prepare model
	fcn_faster_rcnn_filename = fullfile(CaSignal.FasterRCNNDetectorPathName,...
		strcat('fcn_', CaSignal.FasterRCNNDetectorFilename));
	if exist(fcn_faster_rcnn_filename, 'file') == 0
		copyfile(fullfile(CaSignal.localFCNModelPathName, CaSignal.localFCNModelFilename),...
		fcn_faster_rcnn_filename);
	end
	fcn_model = load(fcn_faster_rcnn_filename);
	lgraph = layerGraph(fcn_model.net);
	assignin('base', 'lgraph', lgraph)
	initial_inputSize = lgraph.Layers(1).InputSize;
	%get training data
	disp('resizing training data')
	imdsTrain = imageDatastore(fullfile(fcn_training_data_dir, 'images'));
	imageFolder = fullfile(fcn_training_data_dir, 'imagesResized', filesep);
	imdsTrain = resizeImages(imdsTrain, imageFolder, initial_inputSize(1:2));
	pxdsTrain = pixelLabelDatastore(fullfile(fcn_training_data_dir, 'labels'), ["background", "cell"], [0, 1]);
	labelFolder = fullfile(fcn_training_data_dir,'labelsResized',filesep);
	pxdsTrain = resizeLabels(pxdsTrain,labelFolder, initial_inputSize(1:2));
	augmenter = imageDataAugmenter('RandXReflection',true);
	pximds = pixelLabelImageDatastore(imdsTrain,pxdsTrain,...
		'DataAugmentation',augmenter, 'OutputSize', initial_inputSize(1:2));
	disp('Done')
	% model classifer layer replace
% 	tbl = countEachLabel(pxdsTrain);
% 	imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
% 	classWeights = median(imageFreq) ./ imageFreq;
% 	pxLayer = pixelClassificationLayer('Name','pixelLabels','Classes',tbl.Name,'ClassWeights',classWeights);
% 	lgraph = removeLayers(lgraph,'pixelLabels');
% 	lgraph = addLayers(lgraph, pxLayer);
% 	lgraph = connectLayers(lgraph,'softmax','pixelLabels');
	% config and train
	InitialLearnRate = 1e-3;
	MaxEpochs = 10;
	MiniBatchSize = 16;
	checkpoint_path = fullfile(CaSignal.localFCNModelPathName, 'logs/fcn_faster-rcnn');
	if ~exist(checkpoint_path, 'dir')
		mkdir(checkpoint_path)
	end
	options = trainingOptions('sgdm', ...
    'Momentum',0.9, ...
    'InitialLearnRate',InitialLearnRate, ...
    'L2Regularization',0.0005, ...
    'MaxEpochs',MaxEpochs, ...  
    'MiniBatchSize',MiniBatchSize, ...
    'Shuffle','every-epoch', ...
    'CheckpointPath', checkpoint_path, ...
	'Plots','training-progress', ...
    'VerboseFrequency',2);
	[net, info] = trainNetwork(pximds, lgraph, options);
	save(fcn_faster_rcnn_filename, 'net');
end



function imds = resizeImages(imds, imageFolder, size)
	% Resize images to [360 480].

	if ~exist(imageFolder,'dir') 
		mkdir(imageFolder)
	else
		delete(fullfile(imageFolder, '*'));
	end

	reset(imds)
	while hasdata(imds)
		% Read an image.
		[I,info] = read(imds);     

		% Resize image.
		I = imresize(I,size);    

		% Write to disk.
		[~, filename, ext] = fileparts(info.Filename);
		imwrite(I,[imageFolder filename ext])
	end
	imds = imageDatastore(imageFolder);
end

function pxds = resizeLabels(pxds, labelFolder, size)
	% Resize pixel label data to [360 480].

	
	if ~exist(labelFolder,'dir')
		mkdir(labelFolder)
	else
		delete(fullfile(labelFolder, '*'));
	end

	reset(pxds)
	while hasdata(pxds)
		% Read the pixel data.
		[C,info] = read(pxds);
		% Convert from categorical to uint8.
		L = uint8(C);  
		% Resize the data. Use 'nearest' interpolation to
		% preserve label IDs.
		L = imresize(L,size,'nearest');

		% Write the data to disk.
		[~, filename, ext] = fileparts(info.Filename);
		imwrite(L,[labelFolder filename ext])
	end
	classes = pxds.ClassNames;
	labelIDs = 1:numel(classes);
	pxds = pixelLabelDatastore(labelFolder,classes,labelIDs);
end