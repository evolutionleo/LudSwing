#region Networking Setup

use_uuid()
remote = false

last_updated = -1

max_ping_interval = 120
alarm[0] = max_ping_interval

#endregion
#region Reset controls

kup = false
kleft = false
kdown = false
kright = false

kjump = false
kjump_hold = false

krope = false
krope_hold = false

krest = false

rest_timer = 0
max_rest_timer = 12

#endregion
#region Physics

state = PlayerStateNormal


spd = {x: 0, y: 0}
dir = {x: 0, y: 0}

walkspd = 7
jumph = 13.5

acc = .5
dec = .7
grv = .4


coyote = 0
max_coyote = 10

jump_buffer = 0
max_jump_buffer = 6


jump_cut = .5
is_jump_cut = false

//max_air_jumps = 1
max_air_jumps = 0 // nvm fuck this
air_jumps = max_air_jumps

function onGround() {
	return place_meeting(x, y+1, oWall)
}

function jump() {
	spd.y = -jumph
	coyote = 0
	jump_buffer = 0
	is_jump_cut = false
}

#endregion
#region Roping

//rope_attached = false // represented by state
rope_shot = false
rope_length = -1
rope_max_length = 500
rope_angle = 0
rope_hook = noone
rope_angle_spd = 0
rope_reverse_rot = 0

function attach() {
	rope_reverse_rot = 0
	rope_shot = false
	rope_length = point_distance(rope_hook.x, rope_hook.y, x, y)
	rope_angle = point_direction(rope_hook.x, rope_hook.y, x, y)
	var next_x = x + spd.x
	var next_y = y + spd.y
	var next_rope_angle = point_direction(rope_hook.x, rope_hook.y, next_x, next_y)
	rope_angle_spd = angle_difference(next_rope_angle, rope_angle)
	
	state = PlayerStateRope
}

function detach() {
	rope_shot = false
	//rope_attached = false
	instance_destroy(rope_hook)
	state = PlayerStateNormal
}

function rope_shoot() {
	var mdir = point_direction(x, y, mouse_x, mouse_y)
	var dx = lengthdir_x(64, mdir)
	var dy = lengthdir_y(64, mdir)
	//var randir = mdir + random_range(10, 10)
	var randir = mdir // whatever it's a bad mechanic
	rope_hook = instance_create_layer(x + dx, y + dy, "Bullets", oRopeHook)
	rope_hook.image_angle = randir
	rope_hook.owner = id
	rope_hook.spd.x = lengthdir_x(rope_hook.flyspd, randir)
	rope_hook.spd.y = lengthdir_y(rope_hook.flyspd, randir)
}

function respawn() {
	//x = xstart
	//y = ystart
	//spd.x = 0
	//spd.y = 0
	room_restart()
}

function knock() {
	state = PlayerStateKnocked
}

#endregion