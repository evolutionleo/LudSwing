function approach(a, b, val) {
	if (a < b)
	    return min(a + val, b); 
	else
	    return max(a - val, b);
}