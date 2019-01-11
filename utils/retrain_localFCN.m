function CaSignal = retrain_localFCN(CaSignal, datapath)

	lgraph = layerGraph(CaSignal.localFCNModel.net);
	initial_inputSize = lgraph.Layers(1).InputSize;
	% set training parameter
	title = 'Set Training Parameter';
	inputSize = initial_inputSize;
	InitialLearnRate = 1e-3;
	MaxEpochs = 10;
	MiniBatchSize = 16;
	RandomSampleNum = 10;
	prompt = {'InputSize:', 'InitialLearnRate:', 'MaxEpochs:', 'MiniBatchSize:', 'RandomSampleNum:'};
	definput = {mat2str(inputSize),num2str(InitialLearnRate), num2str(MaxEpochs), num2str(MiniBatchSize), num2str(RandomSampleNum)};
	dims = [1 100];
	answer = inputdlg(prompt,title,dims,definput);
	if numel(answer) > 0
		inputSize = str2num(answer{1});
		InitialLearnRate = str2double(answer{2});
		MaxEpochs = str2double(answer{3});
		MiniBatchSize = str2double(answer{4});
		RandomSampleNum = str2double(answer{4});
	end
	if ~isequal(inputSize, initial_inputSize)
		new_inputlayer = imageInputLayer([inputSize(1), inputSize(2), inputSize(3)],...
			'Name', 'inputImage');
		lgraph = replaceLayer(lgraph, 'inputImage', new_inputlayer);
	end
	%generate image patch used to train
	train_dir = fullfile(CaSignal.localFCNModelPathName, 'local_fcn_temp_training_dataset');
	disp('generating training data');
	train_dir = generate_localFCN_training_data(datapath, train_dir, CaSignal.ROIDiameter, RandomSampleNum);
	if isequal(train_dir, '')
		return
	end
	% load training data
	imdsTrain = imageDatastore(fullfile(train_dir, 'images'));
	pxdsTrain = pixelLabelDatastore(fullfile(train_dir, 'labels'), ["background", "cell"], [0, 1]);
	augmenter = imageDataAugmenter('RandXReflection',true);
	pximds = pixelLabelImageDatastore(imdsTrain,pxdsTrain,...
		'DataAugmentation',augmenter, 'OutputSize', inputSize);
	
	% config and train
	checkpoint_path = fullfile(CaSignal.localFCNModelPathName, 'logs/fcn');
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
	[net, info] = trainNetwork(pximds,lgraph,options);
	
	% save trained model
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
	CaSignal.localFCNModel.net = net;
	CaSignal.localFCNModelFilename = file;
	CaSignal.localFCNModelPathName = path;
	save(fullfile(path, file), 'net');
	
	
	
end