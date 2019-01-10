%% 
%把想要处理的数据目录填到下面tif_datapaths里， 
%对应的存储ROI information的mat文件填到roi_filepaths里
tif_datapaths = {'E:/data_of_different_brian_area/xinyu/20180910_b55a0706'};
roi_filepaths = {'E:/data_of_different_brian_area/xinyu/20180910_b55a0706/ROIinfoBU_b55a07_test06_2x_2afc_160um_20180910_dftReg_.mat'};

%%
for i = 1:numel(tif_datapaths)
	% load ROI mask
	roi_filepath = roi_filepaths{i};
	ROIinfo = load(roi_filepath);
	if isfield(ROIinfo, 'ROImask')
		ROImasks = ROIinfo.ROImask;
	elseif isfield(ROIinfo, 'ROIinfoBU')
		ROImasks = ROIinfo.ROIinfoBU.ROImask;
	else
		error('error when loading %s, please check the mat file!', roi_filepath);
	end
	temp_mask = [];
	for k = 1:numel(ROImasks)
		ROImask = double(ROImasks{k} > 0);
		ROImask = ROImask / sum(ROImask, 'all');
		temp_mask(k, :) = reshape(ROImask, [1, size(ROImask, 1)*size(ROImask, 2)]);
	end
	% load image data
	tif_data = [];
	cal_signal = [];
	count = 0;
	tif_datapath = tif_datapaths{i};
	d = dir(fullfile(tif_datapath, '*.tif*'));
	for j = 1:size(d, 1)
		tiff_filename = fullfile(tif_datapath, d(j).name);
		info = imfinfo(tiff_filename);
		numImages = length(info);
		tiff = Tiff(tiff_filename, 'r');
		for k = 1:numImages
			count = count + 1;
			tiff.setDirectory(k);
			tif_data(:, :, count) = double(read(tiff));
		end
		% 每读取5000帧图像提取一次钙信号， 根据自己内存大小调节，数值越大内存要求越大
		if count >5000 || j == size(d, 1)
			count = 0;
			tif_data = reshape(tif_data, [size(tif_data, 1)*size(tif_data, 2), size(tif_data, 3)]);
			cal_signal = [cal_signal, temp_mask*tif_data];
			tif_data = [];
		end
	end
	save(fullfile(tif_datapath, 'CalSignal.mat'), 'cal_signal');
	% 最后的的钙信号存储在cal_signal这个矩阵里，
	% 矩阵的高是ROI的数量，宽是数据的帧数。可以通过plot(cal_signal(1,:))查看第一条钙信号
end