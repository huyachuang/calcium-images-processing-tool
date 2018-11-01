function CaSignal = update_subimage_show(handles, CaSignal)
	if numel(CaSignal.TempROI) ~= 0
		axes(handles.SubimageShowAxes);
		y_start = CaSignal.TempROI{1};
		y_end = CaSignal.TempROI{2};
		x_start = CaSignal.TempROI{3};
		x_end = CaSignal.TempROI{4};
		img = CaSignal.showing_image(y_start:y_end, x_start:x_end);
		p_bottom = prctile(img,CaSignal.bottom_percentile, 'all');
		p_top = prctile(img,CaSignal.top_percentile, 'all');
		if p_bottom >= p_top
			temp = p_bottom;
			p_bottom = p_top;
			p_top = temp;
		end
		img = imadjust(img, [p_bottom, p_top]);
		CaSignal.h_subimage = imshow(img);

		if CaSignal.TempROI{8} == 'T'
			hold on;     
			boundary = CaSignal.TempROI{6};
			plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
			hold off;
		end
	end
end