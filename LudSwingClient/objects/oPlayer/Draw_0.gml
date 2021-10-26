if live_call() return live_result

if instance_exists(rope_hook) {
	draw_line_width(x, y, rope_hook.x, rope_hook.y, 2)
}

draw_self()

if (!remote)
	draw_text(x, bbox_top - 10, "You")

//draw_text(x, bbox_top, uuid)
