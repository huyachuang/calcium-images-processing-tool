function CaSignal = update_subimage_show(handles, CaSignal, with_TempROI)
	
	if numel(CaSignal.TempROI) ~= 0 && with_TempROI
% 		&& ((get(handles.NextROICheckBox,'Value') == 1) || ...
% 			(x >= CaSignal.TempROI{3} && x <= CaSignal.TempROI{4} && y >= CaSignal.TempROI{1} && y <= CaSignal.TempROI{2}))
		axes(handles.SubimageShowAxes);
		y_start = CaSignal.TempROI{1};
		y_end = CaSignal.TempROI{2};
		x_start = CaSignal.TempROI{3};
		x_end = CaSignal.TempROI{4};
% 		img = zeros(2 * CaSignal.ROIDiameter + 1,  2 * CaSignal.ROIDiameter + 1);
% 		disp([y_start, y_end, x_start, x_end])
% 		img(1:y_end - y_start + 1, 1:x_end - x_start + 1,:) = CaSignal.showing_image(y_start:y_end, x_start:x_end);
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
		
		if get(handles.ShowROINoCheckbox, 'Value') == 0
			if CaSignal.TempROI{8} == 'T'
				hold on;     
				boundary = CaSignal.TempROI{6};
				plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 1)
				hold off;
			end
		else
			if CaSignal.TempROI{8} == 'T'
				hold on;     
				boundary = CaSignal.TempROI{6};
				plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 1)
				text(min(boundary(:,2)), min(boundary(:,1)), num2str(CaSignal.TempROI{7}), 'Color', 'r', 'FontSize', 10);
				hold off;
			end
		end
	else
		x = CaSignal.TempXY(1);
		y = CaSignal.TempXY(2);
		axes(handles.SubimageShowAxes);
		[x_start, x_end, y_start, y_end] = generate_loaction_boxes(CaSignal, x, y);
		img = zeros(2 * CaSignal.ROIDiameter + 1,  2 * CaSignal.ROIDiameter + 1);
		img(1:y_end - y_start + 1, 1:x_end - x_start + 1,:) = CaSignal.showing_image(y_start:y_end, x_start:x_end);
		p_bottom = prctile(img,CaSignal.bottom_percentile, 'all');
		p_top = prctile(img,CaSignal.top_percentile, 'all');
		if p_bottom >= p_top
			temp = p_bottom;
			p_bottom = p_top;
			p_top = temp;
		end
		img = imadjust(img, [p_bottom, p_top]);
		CaSignal.h_subimage = imshow(img);
	end
end