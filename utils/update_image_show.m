function CaSignal = updata_image_show(handles, CaSignal)
	axes(handles.ImageShowAxes);
	img = CaSignal.showing_image;
% 	assignin('base','img',img)
	p_bottom = prctile(img,CaSignal.bottom_percentile, 'all');
	p_top = prctile(img,CaSignal.top_percentile, 'all');
	if p_bottom >= p_top
		temp = p_bottom;
		p_bottom = p_top;
		p_top = temp;
	end
	img = imadjust(img, [p_bottom, p_top]);
	CaSignal.h_image = imshow(img);
	hold on;
	for idx = 1:CaSignal.ROI_num
		ROI = CaSignal.ROIs{idx};
		linewidth = 1;
		if ROI{7} == CaSignal.TempROI{7}
			linewidth = 2;
		end
		if ROI{8} == 'T'
			boundary = ROI{6};
			plot(boundary(:,2) + double(ROI{3}), boundary(:,1) + double(ROI{1}), 'r', 'LineWidth', linewidth)
		end
	end
	CaSignal.h_image = imshow(img);
	hold off;
	
end