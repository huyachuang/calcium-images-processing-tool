function CaSignal = retrain_globalFCN(CaSignal, datapath)

	train_dir = fullfile(CaSignal.globalFCNModelPathName, 'global_fcn_temp_training_dataset');
	disp('generating training data');
	train_dir = generate_globalFCN_training_data(datapath, train_dir, 50);
	if isequal(train_dir, '')
		return
	end
	imdsTrain = imageDatastore(fullfile(train_dir, 'images'));
	pxdsTrain = pixelLabelDatastore(fullfile(train_dir, 'labels'), ["background", "cell"], [0, 1]);
	checkpoint_path = fullfile(CaSignal.globalFCNModelPathName, 'logs');
	if ~exist(checkpoint_path, 'dir')
		mkdir(checkpoint_path)
	end
	lgraph = layerGraph(CaSignal.global_FCNModel.net);
	options = trainingOptions('sgdm', ...
		'Momentum',0.9, ...
		'InitialLearnRate',1e-3, ...
		'L2Regularization',0.0005, ...
		'MaxEpochs',20, ...  
		'MiniBatchSize',2, ...
		'Shuffle','every-epoch', ...
		'CheckpointPath', checkpoint_path, ...
		'Plots','training-progress', ...
		'ExecutionEnvironment', 'cpu', ...
		'VerboseFrequency',2);
	augmenter = imageDataAugmenter('RandXReflection',true);
	pximds = pixelLabelImageDatastore(imdsTrain,pxdsTrain, 'DataAugmentation',augmenter);
	tbl = countEachLabel(pxdsTrain);
	imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
	classWeights = median(imageFreq) ./ imageFreq;
	pxLayer = pixelClassificationLayer('Name','labels','Classes',tbl.Name,'ClassWeights',classWeights);
	lgraph = removeLayers(lgraph,'labels');
	lgraph = addLayers(lgraph, pxLayer);
	lgraph = connectLayers(lgraph,'softmax','labels');
	[net, info] = trainNetwork(pximds,lgraph,options);
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
	CaSignal.global_FCNModel.net = net;
	CaSignal.globalFCNModelFilename = file;
	CaSignal.globalFCNModelPathName = path;
	save(fullfile(path, file), 'net');
end