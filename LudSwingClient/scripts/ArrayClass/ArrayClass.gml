///!!!
/// For examples see Tests.gml
///!!!

// See type-conversion API at the bottom of this file

globalvar ARRAY_LOOP; // edit this inside forEach, etc. to exit a loop
ARRAY_LOOP = 1;

///@function	Array(*item1, *item2, ...)
///@description	Constructor funcion for Array objects
function Array() constructor {
	content = [];
	size = 0;
	
	// Change these if you want to avoid crashes
	// (it may or may not cause unexpected consequences)
	#macro ARRAY_SHOW_ERROR true
	#macro ARRAY_SHOW_WARNING true
	
	
	static __throw = function(err) {
		if ARRAY_SHOW_ERROR {
			throw err;
		}
		else if ARRAY_SHOW_WARNING {
			show_debug_message("Array error: "+string(err))
		}
		else {
			// nothing
		}
	}
	
	///@function	append(value, value2, ..)
	///@description	Adds (a) value(s) to the end of the array
	///@param		{any} value
	static append = function(value) {
		for(var i = 0; i < argument_count; ++i) {
			var val = argument[i]
			content[size] = val;
			++size;
		}
		
		return self;
	}
	
	///@function	add(value, value2, ..)
	///@description Mirrors append() method
	///@param		{any} value
	static add = function(value) {
		for(var i = 0; i < argument_count; ++i) {
			var val = argument[i]
			content[size] = val;
			++size;
		}
		
		return self;
	}
	
	///@function    bogosort()
	///@description This is just a funny meme, please don't use this in actual projects
	static bogosort = function(func) {
	    var i = 0;
	    while(!self.isSorted(func)) {
	        self.shuffle();
	        i++;
	    }
	    
	    //show_debug_message("bogosort complete in "+string(i)+" iteration(s)");
	    return self;
	}
	
	///@function	concat(other)
	///@description	Adds every element of the second array to this array
	///@param		{Array/array} other
	static concat = function(_other) {
		if(!is_Array(_other)) {
			if is_array(_other) {
				_other = array_to_Array(_other)
			}
			else {
				__throw("TypeError: trying to concat "+typeof(_other)+" with Array");
				return self;
			}
		}
		
		for(var i = 0; i < _other.size; i++) {
			append(_other.get(i));
		}
		
		return self;
	}
	
	///@function	copy()
	///@description	Returns a copy of the array object
	static copy = function() {
		var ans = new Array();
		
		//forEach(function(el) {
		//	ans.append(el);
		//});
		for(var i = 0; i < size; ++i) {
			var el = get(i);
			ans.push(el);
		}
		
		return ans;
	}
	
	///@function	clear()
	///@description	clears an array object
	static clear = function() {
		content = [];
		size = 0;
		
		return self;
	}
	
	///@function	empty()
	///@description	Returns true if the array is empty and false otherwise
	static empty = function() {
		return size == 0;
	}
	
	///@function	equal(other)
	///@description	Returns true if arrays are equal and false otherwise
	static equal = function(_other) {
		if(!is_Array(_other)) {
			__throw( "TypeError: trying to compare "+typeof(_other)+" with Array");
			return false;
		}
		
		if(size != _other.size)
			return false;
		
		for(var i = 0; i < size; i++) {
			var c1 = get(i);
			var c2 = _other.get(i);
			
			
			if(typeof(c1) != typeof(c2))
				return false;
			
			
			if(is_array(c1) and is_array(c2)) {
				if(!array_equals(c1, c2))
					return false;
			}
			else if(is_Array(c1) and is_Array(c2)) {
				if(!c1.equal(c2))
					return false;
			}
			else if c1 != c2
				return false;
		}
		
		return true;
	}
	
	///@function	exists(value)
	///@description	Returns true if the value exists in the array and false otherwise
	static exists = function(val) {
		//val = _val;
		var ans = false;
		
		//forEach(function(x, pos) {
		//	if(x == val) {
		//		ans = true;
		//		return 1; //Break out of forEach()
		//	}
		//});
		for(var i = 0; i < size; ++i) {
			if (get(i) == val) {
				ans = true;
				break;
			}
		}
		
		return ans;
	}
	
	///@function	filter(func)
	///@description	Loops through the array and passes each value into a function.
	///				Filters the array to only include values, that returned true.
	///				Function func gets (x, *pos) as input
	///@param		{function} func
	static filter = function(_func) {
		func = _func;
		var new_content = [];
		
		for(var i = 0; i < size; ++i) {
			var val = get(i);
			if(func(val, i))
				array_push(new_content, val);
		}
		
		self.content = new_content;
		self.size = array_length(new_content);
		return self;
	}
	
	///@function	find(value)
	///@description	finds a value and returns its position. -1 if not found
	///@param		{any} value
	static find = function(_val) {
		val = _val;
		var ans = -1;
		
		ans = findAnswer(function(x, pos, ans) {
			if(x == val) {
				ARRAY_LOOP = 0;
				return pos;
			}
		}, ans);
		
		return ans;
	}
	
	///@function	findAll(value)
	///@description	finds all places a value appears and returns an Array with all the positions. empty set if not found
	///@param		{any} value
	static findAll = function(val) {
		var ans = new Array();
		
		ans = findAnswer(function(x, pos, struct) {
			var val = struct.val;
			var ans = struct.ans;
			
			if(x == val) {
				ans.append(pos);
			}
			
			if (pos == size-1) {
				ARRAY_LOOP = false;
				return ans;
			}
			else {
				return {ans: ans, val: val}
			}
		}, {ans: ans, val: val});
		
		return ans;
	}
	
	///@function	findAnswer(func, def_ans)
	///@description	loops over the Array and returns the value when your function sets ARRAY_LOOP to `false`
	///				works not too unlike forEach(), but uses function format `foo(val, idx, ans)`, on first iteration ans = undefined
	///				alternatively you can provide a default answer, that gets passed into the first iteration
	///				basically this is a customized find() function, that can return anything you want
	///@note		
	///				Note: Loop will stop immediately if you set ARRAY_LOOP globalvar to 0
	///@param		{function} func
	///@param		{any} def_ans
	static findAnswer = function(func, ans) {
		if (argument_count < 2)
			ans = undefined;
		
		ARRAY_LOOP = true;
		
		for(var i = 0; i < size; ++i) {
			ans = func(get(i), i, ans);
			if (!ARRAY_LOOP) {
				break;
			}
		}
		
		return ans;
	}
	
	static findCustom = findAnswer;

	///@function	first()
	///@description	Returns the first value of the array
	static first = function() {
		return get(0);
	}
	
	///@function	forEach(func)
	///@description	Loops through the array and runs the function with each element as an argument
	///				Function format is `foo(val, *pos)` (function takes value and position as arguments)
	///				Note: Loop will stop immediately if you set ARRAY_LOOP globalvar to 0
	///@param		{function} func
	static forEach = function(func) {
		ARRAY_LOOP = true;
		
		for(var i = 0; i < size; i++) {
			//var res = 
			func(get(i), i)
			if(!ARRAY_LOOP) {
				break;
			}
		}
		
		return self;
	}
	
	///@function	get(pos)
	///@description	Returns value at given pos
	///@param		{real} pos
	static get = function(pos) {
		if(pos < 0)
			pos += size; //i.e. Array.get(-1) = Array.last()
		
		if(size == 0) {
			__throw( "Error: trying to achieve value from empty Array");
			return undefined;
		}
		else if(pos < 0 or pos > size-1) {
			__throw( "Error: index "+string(pos)+" is out of range [0, "+string(size-1)+"]");
			return undefined;
		}
		
		
		return content[pos];
	}
	
	///@function	getRandom()
	///@description Returns a random element from the array
	static getRandom = function() {
		var idx = irandom(size-1)
		if empty() {
			var ans = undefined
		}
		else {
			var ans = get(idx)
		}
		
		return ans
	}
	
	///@function	insert(pos, value)
	///@description	inserts a value into the array at given position
	///@param		{real} pos
	///@param		{any} value
	static insert = function(pos, value) {
		if(pos < 0)
			pos += size;
		
		if(pos < 0 or (pos > size-1 and size != 0)) {
			show_debug_message("Warning: trying to insert a value outside of the array. Use Array.set() or Array.append() instead");
			return set(pos, value);
		}
		
		var part1 = slice(0, pos);
		var part2 = slice(pos);
		
		part1.append(value);
		part1.concat(part2);
		
		content = part1.content;
		size++;
		
		return self;
	}
	
	///@function    isSorted(func)
	///@description checks wether the array is sorted or not.
	///             You can provide a function that compares `a` and `b` and returns true if a is "less"
	///             default function: (a, b) => { return a < b; }
	///@param       {function} func
	static isSorted = function(func) {
	    if is_undefined(func) {
	        //func = function(a, b) {
	        //    return a < b;
	        //}
			func = SORT_ASCENDING
	    }
	    
	    for(var i = 1; i < size; ++i) {
	        if !func(content[i-1], content[i])
	            return false;
	    }
	    return true;
	}
	
	///@function	join(separator)
	///@description returns a string, containing all of the array values separated by 'sep'
	///@tip			to join part of the array, use array.slice().join()
	///@param		{string} separator
	///@param		{bool} show_bounds
	static join = function(sep, show_bounds) {
		if is_undefined(sep)
			sep = ", "
		if is_undefined(show_bounds)
			show_bounds = true
		
		_sep = sep
		
		if show_bounds
			str = "["
		else
			str = ""
		
		forEach(function(el, i) {
			str += string(el)
			if(i < size-1)
				str += _sep
		})
		
		if show_bounds
			str += "]"
		
		return str
	}
	
	///@function	lambda(func)
	///@description	Loops through the array and applies the function to each element
	///@param		{function} func(x, *pos)
	///				Note: Loop will stop immediately if you set ARRAY_LOOP globalvar to 0
	static lambda = function(func) {
		ARRAY_LOOP = true;
		
		for(var i = 0; i < size; i++) {
			set(i, func(get(i),i) );
			if(!ARRAY_LOOP)
				break;
		}
		
		return self;
	}
	
	///@function	last()
	///@description	Returns the last value of the array
	static last = function() {
		return get(-1);
	}
	
	///@function	_max()
	///@description	Returns a maximum of the array. Only works with numbers
	static _max = function() {
		var ans = get(0);
		
		ans = findAnswer(function(x, ans) {
			if(!is_numeric(x)) {
				__throw( "TypeError: Trying to calculate maximum of "+typeof(x)+"");
				return undefined; // Break out of the loop
			}
			
			if(x > ans)
				return x;
		}, ans);
		
		return ans;
	}
	
	///@function	_min()
	///@description	Returns a minimum of the array. Only works with numbers
	static _min = function() {
		var ans = get(0);
		
		forEach(function(x, ans) {
			if(!is_numeric(x)) {
				__throw( "TypeError: Trying to calculate minimum of "+typeof(x)+"");
				ARRAY_LOOP = false;
				return undefined;
			}
			
			if(x < ans)
				return x;
		}, ans);
		
		return ans;
	}
	
	///@function    merge(other)
	///@description Merges this array with another
	static merge = function(_other) {
	    for(var i = 0; i < _other.size; ++i) {
	        self.append(_other.get(i));
	    }
	    
	    return self;
	}
	
	///@function    merged(other)
	///@description like merge() method, but without modifying the original array
	static merged = function(_other) {
	    var ans = self.copy();
	    _other.forEach(function(item) {
	        ans.append(item);
	    })
	    
	    return ans;
	}
	
	///@function    __merge(other)
	///@description an internal function, used for MergeSorting.
	///				Not for you to use. (unless you know what you're doing) :]
	static __merge = function(func, _other) {
	    var ans = array_create(size + _other.size);
	    var i = 0;
	    var j = 0;
	    var k = 0;
	    while(i < size && j < _other.size) {
	        //if self.get(i) < _other.get(j) {
			if func(self.get(i), _other.get(j)) {
	            ans[k] = self.get(i);
	            i++;
	        }
	        else {
	            ans[k] = _other.get(j);
	            j++;
	        }
	        
	        k++
	    }
	    
	    while(i < size) {
	        ans[k] = self.get(i);
	        i++;
	        k++;
	    }
	    
	    while(j < _other.size) {
	        ans[k] = _other.get(j);
	        j++;
	        k++;
	    }
	    
	    return array_to_Array(ans);
	}
	
	///@note		Does not affect the original array!! (due to the internal recursive way it works)
	///				!!! This is an internal function! You probably want to use the version without '__' !!!
	///				(unless you know what you're doing)
	static __mergeSort = function(func, l, r) {
		if is_undefined(func)
			func = SORT_ASCENDING
	    if is_undefined(l)
	        l = 0;
	    if is_undefined(r)
	        r = size;
		
		
		if (r - l <= 1) || size <= 1
			return slice(l, r);
	        //return self;
		
	    var mid = (l + r - 1) / 2;
		
		if (size % 2 == 0) {
			var L = slice(l, mid).__mergeSort(func);
			var R = slice(mid+1, r).__mergeSort(func);
		}
		else {
			var L = slice(l, mid).__mergeSort(func);
			var R = slice(mid, r).__mergeSort(func);
		}
		
	    var _merged = L.__merge(func, R);
	    
        return _merged;
	}
	
	///@function    __mergeSort(l, r, func)
	///@description Sorts the array using merge sort algorithm
	///				In theory this should be fast, but my implementation is slower than bubble sort :)
	///				So actually there's no reason to use this...
	///@param		{function} func - a function, used to compare values. See .sort() for explanation
	///@param		{real} l - the index to start the sort from. Defaults to 0
	///@param		{real} r - the index to end the sort on (including). Defaults to array.size
	static mergeSort = function(func, l, r) {
		return __mergeSort(func, l, r)
	}
	
	///@function	number(value)
	///@description	Returns the amount of elements equal to given value in the array
	///@note		IMPORTANT! Don't try to use this with data structures, as results may be unpredictable
	///				(Use forEach() with your own logic instead)
	///@param		{any} value
	static number = function(_val) {
		val = _val;
		ans = 0;
		
		forEach(function(x, pos) {
			if(x == val)
				ans++;
		});
		
		return ans;
	}
	
	///@function	pop()
	///@description	removes a value from the end of the array and returns it
	static pop = function() {
		var ans = last();
		if(empty()) {
			__throw( "Error: trying to pop value from empty Array");
			return undefined;
		}
		
		remove(-1);
		
		return ans;
	}
	
	///@function	popBack()
	///@description	removes a value from the beginning of the array and returns it
	static popBack = function() {
		var ans = first();
		remove(0);
		
		return ans;
	}
	
	///@function	push(value, value2, ..)
	///@description Mirrors append() method
	///@param		{any} value
	static push = function(value) {
		for(var i = 0; i < argument_count; ++i) {
			var val = argument[i]
			content[size] = val;
			++size;
		}
		
		return self;
	}
	
	///@function	pushBack(value)
	///@description	inserts a value to the beginning of the array
	///@param		{any} value
	static pushBack = function(val) {
		insert(0, val);
	}
	
	// An internal function, used for QuickSort
	static __partition = function(func, l, r) {
		//show_debug_message(slice(l, r-1))
		var i = l-1;
		var j = l;
		var piv = get(r);
		
		for(j = l; j < r; ++j) {
			//if get(j) <= piv {
			if func(get(j), piv) {
				i++;
				swap(i, j);
			}
		}
		
		swap(i+1, j);
		
		return i;
	}
	
	///@function	quickSort(func, l, r)
	///@param		{function} func
	///@param		{int} l
	///@param		{int} r
	static quickSort = function(func, l, r) { // including r
		if is_undefined(func)
			func = SORT_ASCENDING
		if is_undefined(l)
			l = 0
		if is_undefined(r)
			r = size-1
		
		if (l < r-1) {
			var pivot = __partition(func, l, r);
			
			quickSort(func, l, pivot);
			quickSort(func, pivot+1, r);
		}
		
		return self;
	}
	
	///@function    radixSort()
	///@description sorts the array using radix sort algorithm
	static radixSort = function(digits) {
	    
	    static getDigit = function(num, digit) { // digit from right to left
	        repeat(digit) {
	            num = num div 10;
	        }
	        return (num % 10);
	    }
	    
	    for(var digit = 0; digit < digits; ++digit) {
	        // 0-9 indexies representing each possible digit
	        static counters = array_create(10, 0);
	        static output = array_create(size, -1);
			
			for(var i = 9; i >= 0; --i)
				counters[i] = 0;
			
			for(var i = size-1; i >= 0; --i)
				output[i] = -1;
	        
	        for(var i = 0; i < size; ++i) {
	            var dig = getDigit(content[i], digit);
	            counters[dig]++;
	        }
	        
	        // sum
			var len = array_length(counters)
	        for(var i = 1; i < len; ++i) {
	            counters[i] += counters[i - 1]; // get positions
	        }
	        
	        for(var i = size - 1; i >= 0; --i) {
	            var dig = getDigit(content[i], digit);
	            var pos = counters[dig];
	            
	            if pos != 0
	                pos--;
	            
	            while(output[pos] != -1)
	                pos--;
	            
	            output[pos] = content[i];
	        }
	        
	        //array_copy(content, 0, output, 0, array_length(output));
			content = output;
	    }
	    
	    return self;
	}
	
	///@function	remove(pos)
	///@description	removes the value at given position
	///@param		{real} pos
	static remove = function(pos) {
		if(pos < 0)
			pos += size;
		
		if(size == 0) {
			__throw("Error: trying to remove value from an empty Array");
			return self;
		}
		else if(pos < 0 or pos > size - 1) {
			__throw( "Error: index "+string(pos)+" is out of range [0, "+string(size-1)+"]");
			return self;
		}
		
		var part1 = slice(0, pos);
		var part2 = slice(pos+1);
		
		part1.concat(part2);
		
		content = part1.content;
		size--;
		
		return self;
	}
	
	///@function	removeValue(value)
	///@description	removes a selected value from the array
	///@param		{any} value
	static removeValue = function(value) {
		var idx = find(value);
		if (idx > -1)
			remove(idx);
		
		return self;
	}
	
	///@function	resize(size)
	///@description	resizes the array. Sizing up leads to filling the empty spots with zeros
	///@param		{real} size
	static resize = function(size) {
		if(size < 0) {
			__throw( "Error: array size cannot be negative");
			return self;
		}
		
		while(size < size) {
			append(0);
		}
		while(size > size) {
			pop();
		}
		
		return self;
	}
	
	///@function	reverse()
	///@description	reverses the array (overrides its contents)
	static reverse = function() {
		var ans = new Array();
		//forEach(function(element, pos) {
		//	ans.set(size-pos-1, element);
		//});
		findAnswer()
		
		content = ans.content;
		return self;
	}
	
	///@function	reversed()
	///@description	Returns reversed version of the array, without affecting the original
	static reversed = function() {
		var ans = new Array();
		//forEach(function(element, pos) {
		//	ans.set(size-pos-1, element);
		//});
		for(var i = 0; i < size; ++i) {
			var element = get(i)
			ans.set(size-i-1, element)
		}
		
		return ans;
	}
	
	///@function	set(pos, value)
	///@description	sets value in the array at given index
	///@param		{real} pos
	///@param		{any} item
	static set = function(pos, value) {
		if(pos < 0)
			pos += size;
		
		if(pos > size-1)
			size = pos+1;
		
		
		content[pos] = value;
		
		return self;
	}
	
	///@function	slice(begin, end)
	///@description	Returns a slice from the array with given boundaries. If begin > end - returns reversed version
	///@param		{real} begin
	///@param		{real} end
	static slice = function(_begin, _end) {
		if(is_undefined(_begin))
			_begin = 0;
		
		if(is_undefined(_end))
			_end = size;
		
		var ans = new Array();
		
		
		if(_begin > _end) {
			for(var i = _end; i < _begin; i++) {
				ans.pushBack(content[i]);
			}
		}
		else {
			for(var i = _begin; i < _end; i++) {
				ans.append(content[i]);
			}
		}
		
		return ans;
	}
	
	///@function	some(predicate)
	///@description	Returns whether there's an element in the Array that matches the predicate function
	///@param		{function} predicate
	static some = function(predicate) {
		for(var i = 0; i < size; i++) {
			var val = get(i)
			if (predicate(val, i))
				return true;
		}
		return false;
	}
	
	///@function	sort(func, *startpos, *endpos)
	///@description	Bubble sorts through the array in given range, comparing values using provided function. 
	///Function gets (a, b) as input and must return True if A has more priority than B and False otherwise.
	///@example myarray.sort(function(a, b) { return a > b }) will sort 'myarray' in descending order
	///@param		{function} func
	///@param		{real} *startpos	Default - 0
	///@param		{real} *endpos		Default - size
	static sort = function(compare, _begin, _end) {
	    if (is_undefined(compare))
	        compare = SORT_ASCENDING;
	    
		if(is_undefined(_begin))
			_begin = 0;
		
		if(is_undefined(_end))
			_end = size;
		
		
		if(!is_numeric(_begin) or round(_begin) != _begin or !is_numeric(_end) or round(_end) != _end) {
			__throw( "TypeError: sort boundaries must be integers");
			return self;
		}
		
		for(var i = _begin; i < _end; i++) {	// Bubble sort LUL
			for(var j = i; j > _begin; j--) {
				if(j > 0 and compare(get(j), get(j-1))) {
					swap(j, j-1);
				}
			}
		}
		
		return self;
	}
	
	#macro SORT_ASCENDING  (function(a, b) { return a < b })
	#macro SORT_DESCENDING (function(a, b) { return a > b })
	
	
	///@function	sorted(func, *startpos, *endpos)
	///@description Mirrors .sort() function, but doesn't affect the original Array
	static sorted = function(compare, _begin, _end) {
		var ans = copy() // self.copy()
		return ans.sort(compare, _begin, _end)
	}
	
	///@function	shuffle()
	///@description shuffles the array (randomly replaces every element)
	static shuffle = function() {
		// Knuth shuffle implementation
		for(var i = size-1; i > 0; --i) {
			var j = irandom_range(0, i)
			swap(i, j)
		}
		
		
		return self
	}
	
	///@function	shuffled()
	///@description	clean version of .shuffle()
	static shuffled = function() {
		var ans = copy();
		return ans.shuffle();
	}
	
	///@function	sum()
	///@description	Returns the sum of all the elements of the array. concats strings.
	///NOTE: Works only with strings or numbars and only if all the elements are the same type.
	static sum = function() {
		if(is_string(get(0)))
			var ans = "";
		else if(is_numeric(get(0)))
			var ans = 0;
		else {
			__throw( "TypeError: trying to sum up elements, that aren't strings or reals");
			return undefined;
		}
		
		//forEach(function(el) {
		//	if(typeof(el) != typeof(ans))
		//		__throw( "TypeError: Array elements aren't the same type: got "+typeof(el)+", "+typeof(ans)+" expected.");
			
		//	ans += el;
		//});
		for(var i = 0; i < size; ++i) {
			var el = get(i);
			if (typeof(el) != typeof(ans))
				__throw( "TypeError: Array elements aren't the same type: got "+typeof(el)+", "+typeof(ans)+" expected.");
			
			ans += el;
		}
		
		return ans;
	}
	
	///@function	swap(pos1, pos2)
	///@description	swaps 2 values at given positions
	///@param		{real} pos1
	///@param		{real} pos2
	static swap = function(pos1, pos2) {
		var temp = get(pos1);
		set(pos1, get(pos2));
		set(pos2, temp);
		
		return self;
	}
	
	///@function	unique()
	///@description	Returns a copy of this Array object, deleting all duplicates
	static unique = function() {
		var ans = new Array();
		
		//forEach(function(x) {
		//	if(!ans.exists(x))
		//		ans.append(x);
		//});
		for(var i = 0; i < size; ++i) {
			if (!ans.exists(get(i)))
				ans.push(get(i));
		}
		
		return ans;
	}
	
	
	///@function	filter(func)
	///@description	Loops through the array and passes each value into a function.
	///				Returns a new array with only values, that returned true.
	///				Function func gets (x, *pos) as input
	///				Note: Clean function. Does not affect the original array!
	///@param		{function} func
	static where = function(_func) {
		func = _func;
		var ans = new Array();
		
		for(var i = 0; i < size; ++i) {
			if(func(get(i), i))
				ans.append(get(i));
		}
		
		return ans;
	}
	
	static wrapIndex = function(idx) {
		if (size == 0)
			return idx
		
		while(idx >= size) {
			idx -= size
		}
		
		while (idx < 0) {
			idx += size
		}
		
		return idx
	}
	

	for(var i = 0; i < argument_count; i++)
		append(argument[i])
	
	
	static toString = function() {
		return self.join()
	}
}


///@function	Range(min, max, step)
///@function	Range(min, max)
///@function	Range(max)
///@description Returns a new Array object, containing numbers in certain range
function Range() : Array() constructor {
	
	if argument_count > 1 {
		var mi = argument[0];
		var ma = argument[1];
	}
	else {
		var mi = 0;
		var ma = argument[0];
	}
	
	if argument_count > 2 {
		var step = argument[2];
	}
	else {
		var step = 1;
	}

	
	// Iterate!
	if mi < ma // Normal
	{
		for(var i = mi; i <= ma; i += step) {
			append(i);
		}
	}
	else { // Reversed
		for(var i = mi; i >= ma; i += step) {
			append(i);
		}
	}
	
	return self
}


///@function	RandomArray(size, pool)
///@param		{real} size
///@param		{Array} pool
///@description	Creates an array and fills it with random contents from the pool.
///				If pool is not provided, Range(100) is used
///				If pool is numeric, Range(pool) is used
function RandomArray(_size, pool) : Array() constructor {
	if is_undefined(_size)
		_size = 0;
	if is_undefined(pool)
		pool = new Range(100);
	else if is_numeric(pool)
		pool = new Range(pool);
	else if is_array(pool)
		pool = array_to_Array(pool);
	
	
	repeat(_size) {
		self.append(pool.getRandom());
	}
	
	return self;
}


///@function	Iterator(arr)
///@description	Constructs an iterator object to allow easier iteration through Array's
// actually i have no idea why you would use these
function Iterator(arr) constructor {
	self.index = -1;
	self.value = undefined;
	self.array = arr
	self.loop = false
	
	///@function	next()
	static next = function() {
		index++;
		if (index > array.size) {
			value = array.get(index);
		}
		else {
			if (loop) {
				index = 0
				value = array.get(index)
			}
			else {
				value = undefined;
			}
		}
		
		return value;
	}
	
	static get = function() {
		return value;
	}
	
	return self;
}

// Helper functions to convert between data types

///@function	array_to_Array(array)
///@description	Returns an instance of Array object with all the contents of an array
///@param		{array}	array
function array_to_Array(array) {
	if(!is_array(array)) {
		__throw( "TypeError: expected array, got "+typeof(array));
		return undefined;
	}
	
	var ans = new Array();
	
	for(var i = 0; i < array_length(array); i++) {
		ans.append(array[i]);
	}
	
	return ans;
}

///@function	array_from_Array(Arr)
///@description	Mirrors function Array_to_array()
///@param		{Array} Arr
function array_from_Array(Arr) {
	return Array_to_array(Arr)
}

///@function	ds_list_to_Array(list)
///@description	Returns an instance of Array object with all the contents of an array
///@param		{real} list
function ds_list_to_Array(list) {
	if(!ds_exists(list, ds_type_list)) {
		__throw( "Error: ds_list with given index does not exist");
		return undefined;
	}
	
	var ans = new Array();
	
	for(var i = 0; i < ds_list_size(list); i++) {
		ans.append(list[| i]);
	}
	
	return ans;
}

///@function	is_Array(Arr)
///@description	Checks if a variable holds reference to an Array object
///@param		{any} arr
function is_Array(Arr) {
	return is_struct(Arr) and (instanceof(Arr) == "Array" or instanceof(Arr) == "Range");
}

///@function	Array_to_array(Arr)
///@description	Returns contents of an Array object in format of regular array
///@param		{Array} Arr
function Array_to_array(Arr) {
	if !is_Array(Arr) {
		__throw("Error in function Array_to_array(): expected Array(), got "+typeof(Arr))
		return undefined;
	}
	return Arr.content
}

///@function	ds_list_from_Array(Arr)
///@description	Returns contents of an Array object in format of ds_list
///@param		{Array} Arr
function ds_list_from_Array(Arr) {
	if !is_Array(Arr) {
		__throw("Error in function ds_list_from_Array(): expected Array(), got "+typeof(Arr))
		return undefined;
	}
	
	_list = ds_list_create()
	Arr.forEach(function(item) {
		//if (is_Array(item)) {
		//	item = ds_list_from_Array(item)
		//	ds_list_add(_list, item)
		//	ds_list_mark_as_list(_list, ds_list_size(_list)-1)
		//}
		//else {
			ds_list_add(_list, item)
		//}
	})
	return _list
}

///@function	Array_to_ds_list(Arr)
///@description	Mirrors function ds_list_from_Array()
///@param		{Array} Arr
function Array_to_ds_list(Arr) {
	return ds_list_from_Array(Arr)
}

///@function	ds_list_to_array(ds_list)
///@description	IMPORTANT: Used for native gm arrays, not Array Class!!!
//				use ds_list_to_Array() for Array Class support
///@param		{real} ds_list
function ds_list_to_array(_list) {
	var arr = []
	
	// ah yes, performance
	for(var i = ds_list_size(_list) - 1; i >= 0; --i) {
		arr[i] = _list[| i]
	}
	
	return arr
}

///@function	ds_list_from_array(gm_array)
///@description	IMPORTANT: Used for native gm arrays, not Array Class!!!
//				use ds_list_from_Array() for Array Class support
///@param		{array} arr
function ds_list_from_array(arr) {
	var _list = ds_list_create()
	
	for(var i = array_length(arr) - 1; i >= 0; --i) {
		_list[| i] = arr[i]
	}
	
	return _list
}

///@function	array_to_ds_list(gm_array)
///@description	IMPORTANT: Used for native gm arrays, not Array Class!!!
//				use ds_list_from_Array() for Array Class support
///@param		{array} arr
function array_to_ds_list(arr) {
	return ds_list_from_array(arr)
}


// for nerds who care about optimization and use native arrays
#region non-OO arrays functions

///@function	array_exists(array, val)
///@description	IMPORTANT: Used for native gm arrays, not Array Class!!!
function array_exists(array, val) {
	var _len = array_length(array)
	for(var i = 0; i < _len; ++i) {
		if (array[i] == val)
			return true
	}
	
	return false
}

///@function	array_find(array, val)
///@description	IMPORTANT: Used for native gm arrays, not Array Class!!!
function array_find(array, val) {
	var _len = array_length(array)
	for(var i = 0; i < _len; ++i) {
		if (array[i] == val)
			return i
	}
	
	return -1
}

///@function	array_foreach(array, func)
///@description	IMPORTANT: Used for native gm arrays, not Array Class!!!
function array_foreach(array, func) {
	var _len = array_length(array)
	for(var i = 0; i < _len; ++i) {
		func(array[i], i)
	}
}

///@function	array_push(array, val)
///@description	IMPORTANT: Used for native gm arrays, not Array Class!!!
function array_push(array, val) {
	array[@ array_length(array)] = val
}


#endregion