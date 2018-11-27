function ROImasks = load_ROImasks(ROI_file)
	ROImasks = [];
	ROIinfo = load(ROI_file);
	if isfield(ROIinfo, 'ROIinfoBU')
		ROImasks = ROIinfo.ROIinfoBU.ROImask;
	elseif isfield(ROIinfo, 'ROIInfo')
		ROIs = data.ROIInfo;
		ROImasks = cell([1, size(ROIs, 2)]);
		for j = 1:size(ROIs, 2)
			tempMask = zeros(size(img, 1), size(img, 2));
			y_start = ROIs{j}{1};
			y_end = ROIs{j}{2};
			x_start = ROIs{j}{3};
			x_end = ROIs{j}{4};
			tempRoi = ROIs{j}{5};
			tempMask(y_start:y_end, x_start:x_end) = tempRoi(1:y_end - y_start + 1, 1:x_end - x_start + 1);
			ROImasks{j} = tempMask;
		end
	else
		errordlg(['Not find any ROIinfo file in ', temp_dir], 'File Error');
		return;
	end
end