import(PATH_TRAVELLER)


inited = false

setTimeout(self, function() {
	pathAttach(pathName)
	pathStart(pathSpd, 1)
	inited = true
}, 3)