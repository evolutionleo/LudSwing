

try {
	var dist = point_distance(cam_x, cam_y, player.x, player.y)
	if dist > 1000 && interp == fast_interpolation {
		interp = ultrafast_interpolation
	}
	else if dist < 800 && interp == ultrafast_interpolation {
		interp = fast_interpolation
	}
	else if dist > 500 && interp == interpolation {
		interp = fast_interpolation
	}
	else if dist < 300 && interp == fast_interpolation {
		interp = interpolation
	}
	
	cam_x = lerp(cam_x, player.x, interp)
	cam_y = lerp(cam_y, player.y, interp)


	camera_set_view_pos(camera, cam_x - cam_w/2, cam_y - cam_h/2)
}
catch(e) {}