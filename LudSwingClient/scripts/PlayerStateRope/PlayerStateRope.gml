function PlayerStateRope() {
	live_name = "PlayerStateRope"
	if live_call() return live_result
	
	rope_angle = point_direction(rope_hook.x, rope_hook.y, x, y)
	rope_length = point_distance(rope_hook.x, rope_hook.y, x, y)
	
	// if we start swinging from top - swap right and left
	if (rope_reverse_rot == 0 and dir.x != 0) {
		if (0 < rope_angle and rope_angle < 180)
			rope_reverse_rot = -1
		else
			rope_reverse_rot = 1
	}
	
	if (dir.x == 0)
		rope_reverse_rot = 0
	
	var rope_angle_acc = -0.2 * dcos(rope_angle)
	rope_angle_acc += dir.x * 0.08 * rope_reverse_rot
	rope_angle_acc /= sqrt(max(0, rope_length) / 256)
	rope_length += dir.y * 8
	rope_length = clamp(0, rope_length, rope_max_length)
	
	rope_angle_spd += rope_angle_acc
	rope_angle += rope_angle_spd
	rope_angle_spd *= .99
	
	target_x = rope_hook.x + lengthdir_x(rope_length, rope_angle)
	target_y = rope_hook.y + lengthdir_y(rope_length, rope_angle)
	
	spd.x = target_x - x
	spd.y = target_y - y
	
	
	if (kjump) {
		detach()
		jump()
	}
	else if (!krope_hold) { // you have to hold
		detach()
	}
}