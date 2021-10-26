///@desc call things

todelete.clear()

callstack.forEach(function(call, pos) {
	var inst, func, time, props
	
	inst = call._inst
	func = call._func
	time = call._time
	props = call._props
	
	if (time <= 0)
	{
		if inst == noone
			inst = oCallstack
		
		with(inst) { func(props) }
		
		if !call._props.cycle
			todelete.append(call._id)
		else
			call._time = call._max_time
	}
	
	call._time -= 1
	
	callstack.set(pos, call)
})

callstack.filter(function(call) {
	if todelete.exists(call._id)
		return 0
	else
		return 1
})