global.paths = {}


#macro PATH_TRAVELLER global.TrackTraveller

// An entity that can travel on tracks/paths
global.TrackTraveller = new Module({
	exports: {
		traveller: undefined,
		pathAttach: function(path) {
			if (is_string(path))
				path = getPath(path)
			
			traveller.changePath(path)
		},
		pathStart: function(spd, dir) {
			if (is_undefined(traveller.path)) {
				trace("Unable to start a path")
				return -1
			}
			if (is_undefined(spd))
				spd = 7
			if (is_undefined(dir))
				dir = 1
			
			
			with(traveller) {
				self.spd = spd
				self.dir = dir
			}
			
			traveller.start()
		},
		pathManualStep: function() { // sets hsp/vsp instead of actually moving
			traveller.manualUpdate()
		},
		pathStep: function() { // dont forget this!!
			traveller.update()
		},
		pathDetach: function() {
			traveller.detach()
		},
		pathPause: function() {
			traveller.pause()
		},
		pathResume: function() {
			traveller.resume()
		},
		pathDraw: function() {
			if isOnPath()
				traveller.path.draw()
		},
		isOnPath: function() {
			return !is_undefined(traveller.path)
		}
	},
	dependencies: [],
	onImport: function() {
		traveller = new PathTraveller(undefined)
		traveller.inst = self
	}
})


function getPath(pathName) {
	return global.paths[$ string(pathName)]
}

function __nextPathID() {
	static path_id = 0
	return path_id++
}

enum PATHEND {
	STOP = 0, // detach
	REVERSE = 1,
	JUNCTION = 2 // switch to a different path
}

///@function Path(*pathName, *temporary) -> Path
///@param {string} *pathName
///@param {bool}   *temporary
function Path(_pathName, _temporary) constructor {
	if is_undefined(argument[0]) // is_undefined(_path_name)
		_pathName = __nextPathID()
	if is_undefined(argument[1])
		_temporary = false
	
	pathName = string(_pathName)
	nodes = new Array()
	temporary = bool(_temporary)
	
	looped = false
	
	global.paths[$ pathName] = self
	
	static addNode = function(node) {
		self.nodes.push(node)
		return self
	}
	
	static loop = function(looped) {
		if (is_undefined(looped))
			looped = true
		self.looped = looped
		return self
	}
	
	static length = function() {
		return self.nodes.size
	}
	
	static firstNode = function() {
		return self.nodes.first()
	}
	
	static lastNode = function() {
		return self.nodes.last()
	}
	
	static getNode = function(idx) {
		return self.nodes.get(idx)
	}
	
	static nextNode = function(idx, dir) {
		idx = wrapIndex(idx+dir)
		return getNode(idx)
	}
	
	static wrapIndex = function(idx) {
		return nodes.wrapIndex(idx)
	}
	
	static destroy = function() {
		variable_struct_remove(global.paths, self.pathName)
	}
	
	static draw = function() {
		draw_get()
		draw_set_color(c_lime)
		
		for(var i = 0; i < nodes.size; ++i) {
			var node = nodes.get(i)
			node.draw()
			
			if (i != nodes.size - 1) {
				var next_node = nodes.get(i+1)
				
				draw_line_width(node.x, node.y, next_node.x, next_node.y, 2)
			}
			else if (looped) {
				var first_node = nodes.first()
				
				draw_line_width(node.x, node.y, first_node.x, first_node.y, 2)
			}
		}
		
		draw_reset()
	}
}

function PathNode(_x, _y) constructor {
	x = _x
	y = _y
	
	endaction = PATHEND.REVERSE
	junc_paths = new Array()
	
	active_junc = -1
	
	static setEndaction = function(endaction) {
		self.endaction = endaction
		
		return self
	}
	
	static createJunction = function(paths) {
		endaction = PATHEND.JUNCTION
		active_junc = 0
		junc_paths.clear()
		
		if is_array(paths) {
			junc_paths = array_to_Array(paths)
			//array_copy(junc_paths.content, 0, paths, 0, array_length(paths))
		}
		else if is_Array(paths) {
			//paths.forEach(function(path) {
			//	junc_paths.append(path)
			//})
			junc_paths = paths.copy()
		}
		else {
			throw "PathNode.createJunction(): expected array or Array, got "+typeof(paths)
		}
		
		return self
	}
	
	static setJunction = function(index) {
		active_junc = index
		
		return self
	}
	
	static switchJunction = function() { // set to next junction
		active_junc++
		if (active_junc >= junc_paths.size)
			active_junc = 0
		
		return self
	}
	
	static removeJunction = function() {
		endaction = PATHEND.REVERSE
		active_junc = -1
		junc_paths.clear()
		
		return self
	}
	
	static draw = function() {
		draw_get()
		
		draw_set_color(c_lime)
		draw_circle(x, y, 7, true)
		
		draw_reset()
	}
}

function PathTraveller(path) constructor {
	self.running = false
	self.pos = 0
	self.spd = 7
	self.dir = 1 // 1 or -1 (or 0 if stopped)
	self.inst = noone
	
	self.carryover = {x: 0, y: 0}
	
	if is_undefined(path) {
		self.path = undefined
		self.node = undefined
	}
	else {
		self.path = path
		self.node = path.firstNode()
	}
	
	
	
	static changePath = function(new_path) {
		self.path = new_path
		self.node = new_path.firstNode()
		self.pos = 0
		self.dir = 1
		return self
	}
	
	static attach = changePath
	
	static detach = function() {
		pause()
		self.path = undefined
		self.node = undefined
	}
	
	static stop = detach
	
	static start = function() {
		self.running = true
		return self
	}
	
	static resume = start
	
	static pause = function() {
		self.running = false
		return self
	}
	
	// moves the instance
	static update = function() {
		if (!running) { return -1 }
		if (is_undefined(path)) { return -1 }
		if (is_undefined(node)) { node = path.firstNode() }
		if (is_undefined(spd))  { spd = 7 }
		
		var _dir = point_direction(inst.x, inst.y, node.x, node.y)
		var dx = lengthdir_x(spd, _dir)
		var dy = lengthdir_y(spd, _dir)
		
		inst.x = approach(inst.x, node.x, dx)
		inst.y = approach(inst.y, node.y, dy)
		
		if (inst.x == node.x and inst.y == node.y) {
			nextNode()
		}
		
		return self
	}
	
	// doesn't directly set x/y, 
	static manualUpdate = function() {
		if (!running) { return -1 }
		if (is_undefined(path)) { return -1 }
		if (is_undefined(node)) { node = path.firstNode() }
		if (is_undefined(spd))  { spd = 7 }
		
		if(inst.x == node.x and inst.y == node.y) {
			nextNode()
		}
		
		var _dir = point_direction(inst.x, inst.y, node.x, node.y)
		var dx = lengthdir_x(spd + carryover.x, _dir)
		var dy = lengthdir_y(spd + carryover.y, _dir)
		
		
		var _x = approach(inst.x, node.x, dx)
		var _y = approach(inst.y, node.y, dy)
		inst.hsp = _x - inst.x
		inst.vsp = _y - inst.y
		
		
		//var _carryx 
		//var _carryy 
		carryover = {x: abs(inst.x + dx - _x), y : abs(inst.y + dy - _y)}
		
		return self
	}
	
	static reverse = function() {
		dir = -dir
		
		return self
	}
	
	static nextNode = function() {
		if (pos + dir >= path.length() or pos + dir < 0) { // end of path
			if (path.looped) {
				node = path.nextNode(pos, dir)
				pos = path.wrapIndex(pos + dir)
			}
			else {
				switch(node.endaction) {
					case PATHEND.REVERSE:
						reverse()
						break
					case PATHEND.STOP:
						detach()
						break
					case PATHEND.JUNCTION:
						handleJunction()
						break
					default:
						throw "undefined path endaction"
						break
				}
			}
		}
		else {
			node = path.nextNode(pos, dir)
			pos = path.wrapIndex(pos + dir)
		}
		
		return self
	}
	
	static handleJunction = function() {
		var new_path = node.junc_paths.get(node.active_junc)
		changePath(new_path)
		
		return self
	}
}


//path = new Path("haha", true)
//	.addNode(new PathNode(0, 0))
//	.addNode(new PathNode(10, 10))