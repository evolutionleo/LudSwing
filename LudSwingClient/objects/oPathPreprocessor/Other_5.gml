/// @desc

var _pathNames = variable_struct_get_names(global.paths)

for(var i = 0; i < variable_struct_names_count(global.paths); ++i) {
	var pname = _pathNames[i]
	var p = global.paths[$ pname]
	
	if (p.temporary)
		p.destroy()
}


global.paths_initialized = false