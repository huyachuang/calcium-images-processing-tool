function ROImasks = load_ROImasks(ROI_file)
	[filepath,name,ext] = fileparts(ROI_file);
	if strcmp(ext, '.mat')
		ROImasks = [];
		ROIinfo = load(ROI_file);
		if isfield(ROIinfo, 'ROIinfoBU')
			ROImasks = ROIinfo.ROIinfoBU.ROImask;
		elseif isfield(ROIinfo, 'ROImask')
			ROImasks = ROIinfo.ROImask;
		else
			errordlg(['Not find any ROIinfo field in ', ROI_file], 'File Error');
			return;
		end
	elseif strcmp(ext, '.hdf5')
		masks = h5read(ROI_file, '/masks/raw');
		ROImasks = {};
		for i = 1:size(masks, 3)
			ROImasks{i} = transpose(masks(:, :, i));
% 			ROImasks{i} = masks(:, :, i);
		end
	end
end