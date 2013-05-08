/UserView/Screen/

	var/client/myClient = null

	OpenScreen(var/client/C)
		src.myClient = C
		UpdateServerInfo()

	proc/UpdateServerInfo()
		..()
		while(isOpen)
			winset(src.myClient, "screen.lblServerName", "text=\"[world.address]\"")
			sleep(600)