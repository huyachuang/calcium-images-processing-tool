function CaSignal = retrain_localFCN(CaSignal, datapath)

	train_dir = fullfile(CaSignal.localFCNModelPathName, 'local_fcn_temp_training_dataset');
	disp('generating training data');
	train_dir = generate_localFCN_training_data(datapath, train_dir, CaSignal.ROIDiameter, 10);
	if isequal(train_dir, '')
		return
	end
	imdsTrain = imageDatastore(fullfile(train_dir, 'images'));
	pxdsTrain = pixelLabelDatastore(fullfile(train_dir, 'labels'), ["background", "cell"], [0, 1]);
	checkpoint_path = fullfile(CaSignal.localFCNModelPathName, 'logs');
	if ~exist(checkpoint_path, 'dir')
		mkdir(checkpoint_path)
	end
	lgraph = layerGraph(CaSignal.localFCNModel.net);
	options = trainingOptions('sgdm', ...
    'Momentum',0.9, ...
    'InitialLearnRate',1e-3, ...
    'L2Regularization',0.0005, ...
    'MaxEpochs',10, ...  
    'MiniBatchSize',8, ...
    'Shuffle','every-epoch', ...
    'CheckpointPath', checkpoint_path, ...
	'Plots','training-progress', ...
    'VerboseFrequency',2);
	augmenter = imageDataAugmenter('RandXReflection',true);
	pximds = pixelLabelImageDatastore(imdsTrain,pxdsTrain, 'DataAugmentation',augmenter);
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
	CaSignal.localFCNModel.net = net;
	CaSignal.localFCNModelFilename = file;
	CaSignal.localFCNModelPathName = path;
	save(fullfile(path, file), 'net');
	
	
	
end