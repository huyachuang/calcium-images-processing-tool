function CaSignal = update_image_show(handles, CaSignal)
	axes(handles.ImageShowAxes);
	img = CaSignal.showing_image;
	p_bottom = prctile(img,CaSignal.bottom_percentile, 'all');
	p_top = prctile(img,CaSignal.top_percentile, 'all');
	if p_bottom >= p_top
		temp = p_bottom;
		p_bottom = p_top;
		p_top = temp;
	end
	img = imadjust(img, [p_bottom, p_top]);
	CaSignal.h_image = imshow(img);
	handels.CaSignal = CaSignal;
	assignin('base', 'handels', handels);
	CaSignal.h_image.ButtonDownFcn = {@image_buttonDown_fcn, handels};
	hold on;
	for idx = 1:CaSignal.ROI_num
		ROI = CaSignal.ROIs{idx};
		linewidth = 0.5;
		linecolor = 'r';
		if ROI{7} == CaSignal.TempROI{7}
			linewidth = 0.5;
			linecolor = 'g';
		end
		if ROI{8} == 'T'
			boundary = ROI{6};
			plot(boundary(:,2) + double(ROI{3}), boundary(:,1) + double(ROI{1}), linecolor, 'LineWidth', linewidth);
		end
	end
	hold off;
end