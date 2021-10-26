
x += spd.x
y += spd.y


if (!attached && point_distance(x, y, owner.x, owner.y) > owner.rope_max_length) {
	instance_destroy()
}
else if ((place_meeting(x, y, oWall) || place_meeting(x, y, oAttachableThing)) && !attached) {
	spd.x = 0
	spd.y = 0
	
	attached = true
	owner.attach()
}
else if (attached && place_meeting(x, y, oAttachableThing)) {
	var a = instance_place(x, y, oAttachableThing)
	spd.x = a.spd.x
	spd.y = a.spd.y
}