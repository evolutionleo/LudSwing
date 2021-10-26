
if live_call() return live_result

draw_text(50, 100, "player instances: " + string(instance_number(oPlayer)))
draw_text(50, 50, "fps: " + string(last_fps.sum() / last_fps.size))