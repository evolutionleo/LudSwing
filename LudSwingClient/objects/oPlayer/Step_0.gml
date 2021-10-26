#region Live Call

if live_call()
	return live_result

#endregion
#region Controls

if (!remote) {
kup = keyboard_check(ord("W"))
kleft = keyboard_check(ord("A"))
kdown = keyboard_check(ord("S"))
kright = keyboard_check(ord("D"))

kjump = keyboard_check_pressed(vk_space)
kjump_hold = keyboard_check(vk_space)

krope = mouse_check_button_pressed(mb_left)
krope_hold = mouse_check_button(mb_left)
}
else {
//kup = false
//kleft = false
//kdown = false
//kright = false

//kjump = false
//kjump_hold = false
}


jump_buffer = max(jump_buffer-1, 0)
coyote = max(coyote-1, 0)

if (kjump_hold) {
	jump_buffer = max_jump_buffer
}
if (onGround()) {
	coyote = max_coyote
	air_jumps = max_air_jumps
}

#endregion
#region Moving

dir.x = kright - kleft
dir.y = kdown - kup

state()

#endregion
#region Collision

if(place_meeting(x + spd.x, y, oWall)) {
	while(!place_meeting(x + sign(spd.x) , y, oWall)) {
		x += sign(spd.x)
	}
	spd.x = 0
}
x += spd.x


if(place_meeting(x, y + spd.y, oWall)) {
	while(!place_meeting(x , y + sign(spd.y), oWall)) {
		y += sign(spd.y)
	}
	spd.y = 0
}
y += spd.y

#endregion
#region Networking

if !remote {
	sendPlayerPos()
	sendPlayerControls()
}

#endregion