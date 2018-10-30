function [dst_img] = gray2RGB(src_img)
	p99 = prctile(src_img, 99, 'all');
	image_1 = imadjust(src_img, [0, p99]);
	p97 = prctile(src_img, 97, 'all');
	image_2 = imadjust(src_img, [0, p97]);
	dst_img = cat(3, src_img, image_1, image_2);
	dst_img = uint8(dst_img * 255);
end