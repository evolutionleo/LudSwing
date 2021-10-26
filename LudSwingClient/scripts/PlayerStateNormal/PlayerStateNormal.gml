function PlayerStateNormal() {
	#region Walking
	
	if (abs(spd.x) < walkspd || sign(dir.x) != sign(spd.x)) {
		spd.x += acc * dir.x
	}

	if (dir.x == 0) {
		spd.x -= sign(spd.x) * dec
	}

	if (abs(spd.x) < dec and dir.x == 0) {
		spd.x = 0
	}
	
	#endregion
	#region Jumping
	
	if (
			(onGround() or coyote > 0) and
			(kjump or jump_buffer > 0)
		)
	{
		jump()
	}
	else if (
			!onGround() and
			air_jumps > 0 and kjump
		)
	{
		air_jumps--
		jump()
	}

	if (spd.y < -1 and !kjump_hold and !is_jump_cut) {
		spd.y *= jump_cut
		is_jump_cut = true
	}

	#endregion
	#region Roping
	
	if (krope and !rope_shot) {
		rope_shoot()
	}
	
	if (!krope_hold) {
		detach()
	}
	
	#endregion
	#region Gravity

	spd.y += grv

	#endregion
}