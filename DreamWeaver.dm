world
	fps = 5
	icon_size = "32x32"

var/
	rootFolder = "C:\\byond\\"
	tempFolder = "C:\\byond_temp\\"

proc/portInUse(var/port)
	return FALSE

mob/

	Stat()
		statpanel("My available hosting slots")
		for(var/S in src.contents)
			stat(S)

	var/UserView/Screen/viewScreen = new

	verb/GetServerInfo()
		set hidden = TRUE
		src << browse({"Server Information:<br />
		address = [world.internet_address]<br />
		byond_version = [world.byond_version]<br />
		cache_lifespan = [world.cache_lifespan]<br />
		cpu = [world.cpu]<br />
		host = [world.host]<br />
		realtime = [world.realtime]<br />
		system_type = [world.system_type]<br />
		time = [world.time]<br />
		"}, "window=popup")

	Login()
		src.contents += new /HostingSlot/
		src.contents += new /HostingSlot/
		src.contents += new /HostingSlot/
		src.contents += new /HostingSlot/
		src.contents += new /HostingSlot/
		src.contents += new /HostingSlot/

		viewScreen.OpenScreen(src.client)