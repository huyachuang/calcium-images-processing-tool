function img_patches_boxes = get_square_patches_boxes(img, bin_size, step_size)

	img_h = size(img, 1);
	img_w = size(img, 2);
	h_n  = int16((floor(img_h - bin_size + step_size) / step_size));
	w_n  = int16((floor(img_w - bin_size + step_size) / step_size));
	img_patches_boxes = double(zeros(h_n, w_n, 4));
	for i = 1:h_n
		if i == h_n
			start_h = img_h - bin_size + 1;
		else
			start_h = (i - 1) * step_size + 1;
		end
		
		for j  = 1:w_n
			if j == w_n
				start_w = img_w - bin_size + 1;
			else
				start_w = (j - 1) * step_size + 1;
			end
			img_patches_boxes(i, j, :) = [start_h, start_w, bin_size, bin_size];
		end
	end
end