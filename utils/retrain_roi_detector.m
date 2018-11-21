function CaSignal = retrain_roi_detector(CaSignal, datapath)
	%prepare training data
	train_dir = fullfile(CaSignal.ROIDetectorPathName, 'roi_detector_temp_training_dataset');
	disp('Generating training data');
	bin_size = CaSignal.ROIDiameter*2+1;
	step_size = 10;
	train_dir = generate_roi_detector_training_data(datapath, train_dir, bin_size, step_size);
	disp('Done');
	%load and organize traning data
	categories = {'cell', 'background'};
	imds = imageDatastore(fullfile(train_dir, categories), 'LabelSource', 'foldernames');
	tb1= countEachLabel(imds);
	background_num = tb1.Count(1);
	cell_num = tb1.Count(2);
	if background_num > 2*cell_num
		del_num = background_num - 2*cell_num;
	end
	background_filenames = dir(fullfile(train_dir, 'background\*.jpg'));
	del_filenames = randsample(background_filenames, del_num);
	for i = 1:del_num
		delete(fullfile(train_dir, 'background', del_filenames(i).name))
	end
	imds = imageDatastore(fullfile(train_dir, categories), 'LabelSource', 'foldernames');
	[trainingSet, valSet] = splitEachLabel(imds, 0.9, 'randomize');
	%prepare network
	lgraph = layerGraph(CaSignal.ROIDetector.net);
	layers = lgraph.Layers;
	connections = lgraph.Connections;
	layers(1:36) = freezeWeights(layers(1:36));
	lgraph = createLgraphUsingConnections(layers,connections);
	%use augmentation to enlarge dataset
	inputSize = lgraph.Layers(1).InputSize;
	imageAugmenter = imageDataAugmenter('RandXReflection',true);
	augimdsTrain = augmentedImageDatastore(inputSize(1:2),trainingSet, ...
		'DataAugmentation',imageAugmenter);
	augimdsValidation = augmentedImageDatastore(inputSize(1:2),valSet);
	% start training
	options = trainingOptions('sgdm', ...
		'MiniBatchSize',16, ...
		'MaxEpochs',6, ...
		'InitialLearnRate',3e-4, ...
		'Shuffle','every-epoch', ...
		'ValidationData',augimdsValidation, ...
		'ValidationFrequency',10, ...
		'Verbose',false, ...
		'Plots','training-progress');
	net = trainNetwork(augimdsTrain,lgraph,options);
	%save train model
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
	CaSignal.ROIDetector.net = net;
	CaSignal.ROIDetectorFilename = file;
	CaSignal.ROIDetectorPathName = path;
	save(fullfile(path, file), 'net');
end