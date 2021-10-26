/// @desc

initialized = false
visible = false

init = function() {
	node = new PathNode(x, y)
	
	switch(endaction) {
		case "reverse":
			endaction = PATHEND.REVERSE
			break
		case "stop":
			endaction = PATHEND.STOP
			break
		case "junction":
			endaction = PATHEND.JUNCTION
			break
		default:
			throw "invalid endaction for point id#"+string(id)
			break
	}
	
	
	if (array_length(junctions)) {
		for(var j = 0; j < array_length(junctions); ++j) {
			junctions[j] = getPath(junctions[j])
		}
	}
	
	
	node.junc_paths = array_to_Array(junctions)
	node.active_junc = activeJunction
	node.endaction = endaction
	
	
	if (endaction == PATHEND.JUNCTION)
		node.createJunction(junctions).setJunction(activeJunction)
	
	
	path = getPath(pathName)
	//path.addNode(node) // dont uncomment this (or consequences)
	
	
	initialized = true
}


createJunction = function(junctions) {
	if (!is_undefined(argument[0]))
		self.junctions = junctions
	node.createJunction(self.junctions)
}

setJunction = function(index) {
	node.setJunction(index)
}

removeJunction = function() {
	node.removeJunction()
}