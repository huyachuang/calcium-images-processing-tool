function CaSignal = update_subimage_show(handles, CaSignal)
	x = CaSignal.TempXY(1);
	y = CaSignal.TempXY(2);
	if numel(CaSignal.TempROI) ~= 0 && x >= CaSignal.TempROI{3} && x <= CaSignal.TempROI{4} && y >= CaSignal.TempROI{1} && y <= CaSignal.TempROI{2}
		axes(handles.SubimageShowAxes);
		y_start = CaSignal.TempROI{1};
		y_end = CaSignal.TempROI{2};
		x_start = CaSignal.TempROI{3};
		x_end = CaSignal.TempROI{4};
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

		if CaSignal.TempROI{8} == 'T'
			hold on;     
			boundary = CaSignal.TempROI{6};
			plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
			hold off;
		end
	else
		axes(handles.SubimageShowAxes);
		x_start = x - CaSignal.ROIDiameter;
		if x_start < 1
			x_start = 1;
		end
		x_end = x + CaSignal.ROIDiameter;
		if x_end > size(CaSignal.imageData, 2)
			x_end = size(CaSignal.imageData, 2);
		end

		y_start = y - CaSignal.ROIDiameter;
		if y_start < 1
			y_start = 1;
		end
		y_end = y + CaSignal.ROIDiameter;
		if y_end > size(CaSignal.imageData, 1)
			y_end = size(CaSignal.imageData, 1);
		end
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