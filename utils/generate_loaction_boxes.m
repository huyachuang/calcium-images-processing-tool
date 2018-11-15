function [x_start, x_end, y_start, y_end] = generate_loaction_boxes(CaSignal, x, y)
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
end