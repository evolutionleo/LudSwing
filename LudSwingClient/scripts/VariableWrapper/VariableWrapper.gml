function var_get(scope, varname) {
	if (is_undefined(argument[1])) {
		varname = argument[0]
		scope = other
	}
	
	if (scope == global) {
		return variable_global_get(varname)
	}
	else if is_struct(scope) {
		return variable_struct_get(scope, varname)
	}
	else {
		return variable_instance_get(scope, varname)
	}
}

function var_set(scope, varname, value) {
	if (is_undefined(argument[1])) {
		varname = argument[0]
		value = argument[1]
		scope = other
	}
	
	if (scope == global) {
		variable_global_set(varname, value)
	}
	else {
		with(scope) {
			if (is_struct(self)) {
				variable_struct_set(self, varname, value)
			}
			else {
				variable_instance_set(self, varname, value)
			}
		}
	}
}

function var_exists(scope, varname) {
	if (is_undefined(argument[1])) {
		varname = argument[0]
		scope = other
	}
	
	if (scope == global) {
		return variable_global_exists(varname)
	}
	else if is_struct(scope) {
		return variable_struct_exists(scope, varname)
	}
	else {
		return variable_instance_exists(scope, varname)
	}
}

///@function struct_copy(stc, dest, *ignore)
///@param	{struct} src
///@param	{struct} dest
///@param	{array} *ignore
function struct_copy(src, dest, ignore_props) {
	if (is_undefined(argument[2]))
		ignore_props = []
	
	var prop_names = variable_struct_get_names(src)
	var prop_len   = variable_struct_names_count(src)
	
	for(var i = 0; i < prop_len; ++i) {
		var prop = prop_names[i]
		if (array_exists(ignore_props, prop))
			continue
		
		var value	   = src[$ prop]
		dest[$ prop] = value
	}
}

///@function struct_clear(struct)
///@param	 {struct} struct
function struct_clear(struct) {
	var prop_names = variable_struct_get_names(struct)
	var prop_len   = variable_struct_names_count(struct)
	
	for(var i = 0; i < prop_len; ++i) {
		var prop = prop_names[i]
		variable_struct_remove(struct, prop)
	}
}

function struct_names(struct) {
	return variable_struct_get_names(struct)
}