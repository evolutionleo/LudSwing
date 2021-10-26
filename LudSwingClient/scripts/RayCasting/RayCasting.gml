#macro RAYCAST_PRECISION 2
#macro RAYCAST_MAX_DIST 128

///@function	RayCast(x, y, dir, *ignore_self, *length, *extended_info)
function RayCast(_x, _y, _dir, ignore_self, _max_length, extended_info) {
	if (is_undefined(argument[3]))
		ignore_self = false
	//if (argument_count < 5)
	if (is_undefined(argument[4]))
		_max_length = RAYCAST_MAX_DIST
	//if (argument_count < 6)
	if (is_undefined(argument[5]))
		extended_info = true
	
	// turns out creating new vectors actually takes resources
	//var _pointer = vec2(0, 0)
	var _pointer = fakeVec2(0, 0)
	static _step = vec2(0, 0) // only runs once
	
	var _self	 = id
	
	var _prec	 = RAYCAST_PRECISION
	_pointer.x = _x
	_pointer.y = _y
	//var _pointer = vec2(_x, _y)
	//var _step	 = vec2(0, 0)
	//var _func	 = RAYCAST_STOP_FUNCTION
	var _inst	 = noone
	var _dist	 = 0
	
	var _hit	 = false
	var _type	 = "solid"
	
	_step.x = lengthdir_x(_prec, _dir)
	_step.y = lengthdir_y(_prec, _dir)
	var _step_length = _step.length()
	
	while(true) {
		//_pointer = add(_pointer, _step)
		//_pointer.add(_step)
		_pointer.x += _step.x
		_pointer.y += _step.y
		
		_dist += _step_length
		
		if (extended_info) {
			_inst = instPointCollision(_pointer.x, _pointer.y)
			_type = "solid"
			
			if (_inst != noone) {
				if (_inst.object_index == oTileCollider and _inst.image_index > 1)
				or (_inst.object_index == oIceSlope)// icy slopes
					_type = "slope"
				else
					_type = "solid"
			
				if(!ignore_self or _inst != _self) {
					_hit = true
					break
				}
			}
		}
		else {
			_inst = undefined
			_type = undefined
			if (positionSolid(_pointer.x, _pointer.y)) {
				_hit = true
				break
			}
		}
		
		if _dist > _max_length {
			break
		}
	}
	
	
	return new RayCastHit(_hit, _type, fakeVec2(_x, _y), _inst, _dist, _pointer)
}


function RayCastHit(hit, type, origin, inst, dist, point) constructor {
	self.type  = type	// {string}
	self.hit   = hit	// {bool}
	self.inst  = inst	// {real/inst_id}
	self.dist  = dist	// {real}
	self.length = dist // just a mirror/wrapper
	self.point = point	// {Vector2}
	self.origin = origin // {Vector2} / {x: .., y: ..}
	
	static draw = function(col) {
		if is_undefined(col)
			col = c_red
		else col = argument[0]
		
		draw_set_color(col)
		
		draw_line(self.origin.x, self.origin.y, self.point.x, self.point.y)
		
		draw_set_color(c_white)
	}
	
	//return self
}

function fakeVec2(_x, _y) {
	return {x: _x, y: _y}
}


// pretty much only for raycasting
function instPointCollision(_x, _y, _self) {
	_self = _self ? argument[2] : id
	
	var inst = instPositionSolid(_x, _y, _self)
	if (inst != noone and inst != _self)
		return inst
	else
		return noone
}