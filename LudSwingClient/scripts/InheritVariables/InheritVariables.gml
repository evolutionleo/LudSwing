function InheritAllVariables(source, dest) {
	if (is_struct(source)) {
		var _var_get = variable_struct_get
		var _var_get_names = variable_struct_get_names
	}
	else {
		var _var_get = variable_instance_get
		var _var_get_names = variable_instance_get_names
	}
	
	if (is_struct(dest)) {
		var _var_set = variable_struct_set
	}
	else {
		var _var_set = variable_instance_set
	}
	
	
	var _var_names = _var_get_names(source)
	var _var_names_len = array_length(_var_names)
	
	for(var i = 0; i < _var_names_len; ++i) {
		var _var_name = _var_names[i]
		_var_set(dest, _var_name, _var_get(source, _var_name))
	}
}

function testInheritVariables() {
	var source = {a: 10, b: 20}
	var dest = instance_create_depth(0, 0, 0, oEmpty)
	
	InheritAllVariables(source, dest)
	
	trace(dest.a)
	
	var source = {a: 10, b: 20}
	var dest = {}
	
	InheritAllVariables(source, dest)
	
	trace(dest.a)
	
	
	var source = {a: 10, b: 20}
	var dest = {a: 0, b: undefined}
	
	InheritAllVariables(source, dest)
	
	trace(dest.a)
	trace(dest.b)
}