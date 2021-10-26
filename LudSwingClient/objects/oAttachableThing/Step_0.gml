if (!inited)
	exit

pathStep()
//pathManualStep()

with(instance_place(x, y, oRopeHook)) {
	if (attached) {
		//x += other.hsp
		//y += other.vsp
		x += other.x - other.xprevious
		y += other.y - other.yprevious
	}
}


//x += hsp
//y += vsp