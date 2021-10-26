#macro from  ,


function Module(contents) constructor {
	self.__imported = new Array()
	InheritAllVariables(contents, self)
	
	
	if !variable_global_exists("modules")
		global.modules = new Array()
	
	global.modules.push(self)
}

///@function	import([*modules] *from, obj)
function import() {
	var inst, origin, imports, exports, dependencies, onimport
	#region Resolve `this` scope
	
	if (variable_struct_exists(self, "id"))
		inst = id
	else
		inst = self
	
	#endregion
	#region Resolve the import origin
	
	origin = argument[argument_count-1]
	if (is_real(origin)) { // instance or object
		if (origin) < 100000 { // object
			if (instance_exists(origin))
				origin = instance_find(origin, 0)
			else
				origin = instance_create_depth(0, 0, 0, origin)
		}
		if (!variable_instance_exists(origin, "exports")) {
			throw "Unable to import. Instance id #"+string(origin)+" doesn't have exports"
			return -1
		}
		exports = origin.exports
		if (variable_instance_exists(origin, "dependencies"))
			dependencies = origin.dependencies
		else
			dependencies = []
		if (variable_instance_exists(origin, "onImport"))
			onimport = origin.onImport
		else
			onimport = EMPTY_FUNCTION
		if (variable_instance_exists(origin, "tag")) { // assign the tag
			with(inst) {
				add_tag(origin.tag)
			}
		}
		if (variable_instance_exists(origin, "flag")) { // assign the flag
			with(inst) {
				flag_add(origin.flag)
			}
		}
	}
	else if (is_struct(origin)) {
		exports = origin.exports
		if (variable_struct_exists(origin, "dependencies"))
			dependencies = origin.dependencies
		else
			dependencies = []
		
		if (variable_struct_exists(origin, "onImport"))
			onimport = origin.onImport
		else
			onimport = EMPTY_FUNCTION
		
		if (variable_struct_exists(origin, "tag")) {
			with(inst) {
				add_tag(variable_struct_get(origin, "tag"))
			}
		}
		if (variable_struct_exists(origin, "flag")) { // assign the flag
			with(inst) {
				flag_add(origin.flag)
			}
		}
	}
	
	#endregion
	#region List of importing modules/variables
	
	imports = new Array()
	
	if (argument_count == 2 and is_array(argument[0])) { // import([x, y, z] from X)
		imports = array_to_Array(argument[0])
	}
	else { // import(x, y, z from X)
		for(var i = 0; i < argument_count - 1; i++) {
			imports.add(argument[i])
		}
	}
	#endregion
	#region Import ALL
	// import(X)
	// or
	// import("*" from X)
	if imports.empty() or imports.get(0) == "*"
	{
		if (is_array(exports)) {
			imports = array_to_Array(exports) // yes this is slow
			//imports.content = exports		// this doesnt work for some reason
		}
		else if (is_Array(exports)) {
			imports = exports.copy()
		}
		else if (is_struct(exports)) {
			var keys = variable_struct_get_names(exports)
			//imports.content = keys
			imports = array_to_Array(keys)
		}
	}
	#endregion
	#region Prepare Dependencies
	
	dependencies = array_to_Array(dependencies)
	//dependencies.forEach(function(dependency) {
	for(var i = 0; i < dependencies.size; ++i) {
		var dependency = dependencies.get(i)
		if (!has_imported(dependency)) {
			import(dependency)
		}
	}
	
	#endregion
	#region Actual Importing
	
	if is_Array(exports) { exports = Array_to_array(exports) }
	if is_array(exports) { // for each import check if it exists in module.exports
		exports = array_to_Array(exports)
		
		//imports.forEach(function(module) {
		for(var i = 0; i < imports.size; ++i) {
			var var_name = imports.get(i)
			
			
			if var_name == "__onImport"
				continue
			
			if !exports.exists(var_name) {
				throw "Unable to find the module";
			}
			
			var value = variable_instance_get(origin, var_name)
			
			if is_method(value)
				value = method(inst, value)
			
			variable_instance_set(inst, var_name, value)
		}
		//})
	}
	else if is_struct(exports) { // for each export check if it's in imports
		var keys = variable_struct_get_names(exports)
		
		//array_to_Array(keys).forEach(function(module) {
		for(var i = 0; i < array_length(keys); ++i) {
			var var_name = keys[i]
			
			if var_name == "__onImport"
				continue
			
			if imports.exists(var_name) {
				var value = variable_struct_get(exports, var_name)
				
				if is_method(value)
					value = method(inst, value)
				
				variable_instance_set(inst, var_name, value)
			}
		}
		//})
		
		//if variable_struct_exists(exports, "__onImport") {
		//	with(inst) {
		//		method(self, exports.__onImport)()
		//	}
		//}
	}
	#endregion
	#region onImport() meta function
	
	method(inst, onimport)()
	
	#endregion
	#region Add to __imported
	
	if (!var_exists(origin, "__imported"))
		origin.__imported = new Array()
	origin.__imported.push(inst)
	
	#endregion
}


function has_imported(module, inst) {
	if (is_undefined(argument[1]))
		inst = id
	
	//if (is_struct(module) and !variable_struct_exists(module, "tag"))
	//	return undefined
	//if (is_real(module) and !variable_instance_exists(module, "tag"))
	//	return undefined
	
	//return asset_has_tags(inst.object_index, module.tag, asset_object)
	
	return (var_exists(module, "__imported") and module.__imported.exists(inst))
}



#region Tests

global.test_module = new Module({
	exports: {
		p: "Hello",
		sayHi: function() {
			trace("Hello world!")
		}
	},
	dependencies: [],
	onImport: function() {
		trace(p)
	},
	tag: "test-module"
})


function __testImports() {
	//with(instance_create_depth(0, 0, 0, oEmpty)) {
	//	import(global.test_module)
	//	show_message(stf("imported: %", has_imported(global.test_module)))
	//}
}

//__testImports()

#endregion
