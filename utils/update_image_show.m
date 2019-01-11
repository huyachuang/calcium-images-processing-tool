function CaSignal = update_image_show(handles, CaSignal, is_restore_zoom)
	axes(handles.ImageShowAxes);
	L = get(gca,{'xlim','ylim'});
	img = CaSignal.showing_image;
	p_bottom = prctile(img,CaSignal.bottom_percentile, 'all');
	p_top = prctile(img,CaSignal.top_percentile, 'all');
	if p_bottom >= p_top
		temp = p_bottom;
		p_bottom = p_top;
		p_top = temp;
	end
	img = imadjust(img, [p_bottom, p_top]);
	img = imsharpen(img);
	CaSignal.h_image = imshow(img);
	hold on;
	if get(handles.ShowROINoCheckbox, 'Value') == 0
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
				plot(boundary(:,2) + double(ROI{3}) - 1, boundary(:,1) + double(ROI{1}) - 1, linecolor, 'LineWidth', linewidth);
			end
		end
	else
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
				text(min(boundary(:,2)) + double(ROI{3}), min(boundary(:,1)) + double(ROI{1}), num2str(ROI{7}), 'Color', 'r', 'FontSize', 10);
			end
		end
	end
	hold off;
	if is_restore_zoom
		zoom reset
		set(gca,{'xlim','ylim'},L);
	end
end