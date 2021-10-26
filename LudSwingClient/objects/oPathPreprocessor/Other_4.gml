/// @desc

with(oPath) {
	init()
}

var points = new Array()

with(oPathPoint) {
	if (!createJunctionStart)
		continue
	
	if (array_length(junctions)) {
		for(var j = 0; j < array_length(junctions); ++j) {
			var point = instance_create_layer(x, y, layer, oPathPoint)
			point.pathName = junctions[j]
			point.index = -1 // the very first node
		}
	}
}

with(oPathPoint) {
	isLast = false
	init()
	points.append(self)
}

points.sort(function(p1, p2) {
	return p1.index < p2.index
}).forEach(function(p) {
	p.path.addNode(p.node)
	
})


global.paths_initialized = true