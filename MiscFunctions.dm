//Pads msg by length in spaces.
proc/leftPad(msg, length)
	var size = length - lentext(msg)
	do{msg+=" ";size--}
	while(size)
	return msg