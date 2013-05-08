#define SLOT_RUNNING 1
#define SLOT_STOPPED 2
#define SLOT_CRASHED 3
#define SLOT_NOT_SETUP 4

/HostingSlot/
	parent_type = /obj/

	var/slotName = ""
	var/tmp/myAddress = ""
	var/hostedPort = 1337
	var/hub_page/hub = null
	var/owner = null
	var/currentHubVersion = null
	var/currentStatus = null

	var/isSetup = FALSE
	var/isStopped = FALSE

	verb/Start()
		set name = "1) Start Server"
		set category = null
		if(portInUse(src.hostedPort))
			startupWorld()
			src.checkStatus()

	verb/Stop()
		set name = "1) Stop Server"
		set category = null
		if(!portInUse(src.hostedPort))
			shutdownWorld()
			src.checkStatus()

	verb/Download()
		set name = "2) Download Files"
		set category = null

	verb/Upload()
		set name = "3) Upload Files"
		set category = null
		updateServer()

	verb/ViewLog()
		set name = "4) View World Log"
		set category = null

	verb/Ban()
		set name = "5) Ban a Key"
		set category = null

	verb/UnBan()
		set name = "6) Unban a Key"
		set category = null

	verb/Setup()
		set name = "1) Setup"
		set category = null

		// Agree to terms of service.

/* Temporarily Disabled
		switch(alert("Will this slot be connected to the hub or a standalone?", "[world.name]", "Hub", "Standalone"))
			if("Hub")
				var/hubPath = null
				while(!hubPath)
					hubPath = input("Please input the hub path\nFORMAT: ckey/hubpath\nEXAMPLE: exadv1/SpaceStation13")
					var/hub_page/H = new(hubPath)
					if(!H)
						// There was an error, doesn't exist or doesn't have a ZIP.
						hubPath = null
						alert("Error setting up hub, does not exist or does not have a valid download.")
					else
						src.hub = H
				src.name = src.hub.title
			else */
		src.owner = usr.ckey
		var/nameInput = null
		while(!nameInput)
			nameInput = input("What will you name this slot?")
			src.slotName = nameInput
		src.name = slotName
		runPython("setupFolders", list(myFolder()))

		updateServer()

		switch(alert("Server is now setup.\nWould you like to start the server now?", "[world.name]", "Yes", "No"))
			if("Yes")
				src.isSetup = TRUE
				src.isStopped = FALSE
			else
				src.isSetup = TRUE
				src.isStopped = TRUE
		checkStatus()

	New()
		..()
		spawn()
			statusLoop()


	proc/myFolder() return "[rootFolder]hosted\\users\\[owner]\\[src.slotName]\\"
	proc/myDMB()
		for(var/f in flist(myFolder()))
			var/fileExt = lowertext(copytext(f, max(length(f)-3,1)))
			if(fileExt == ".dmb") return "[f]"
		return null
	proc/updateFile() return "[tempFolder][src.owner]_[src.slotName]_[time2text(world.realtime, "MMMDD_hhmmss")]\\update.zip"


	/*  #################################################
		##                  STATUS CHECK             ####
		################################################# */

	proc/statusLoop()
		while(src)
			src.checkStatus()
			sleep(600)

	proc/checkStatus()
		if(!src.isSetup)
			src.currentStatus = SLOT_NOT_SETUP
			name = "Unused Slot"
		else if(src.isStopped)
			name = leftPad(src.slotName, 44)
			src.currentStatus = SLOT_STOPPED
		else if(portInUse(src.hostedPort) && !src.isStopped)
			name = leftPad(src.slotName, 44) + "byond://[world.address]:[src.hostedPort]"
			src.currentStatus = SLOT_RUNNING
		else
			src.currentStatus = SLOT_CRASHED
			src.startupWorld()

		src.icon = icon('status.dmi', "[src.currentStatus]")
		src.setVerbs()
		return src.currentStatus

	proc/setVerbs()
		src.verbs -= typesof(/HostingSlot/verb/)
		sleep(1)
		if (src.currentStatus == SLOT_RUNNING)
			src.verbs += /HostingSlot/verb/Stop
			src.verbs += /HostingSlot/verb/UnBan
			src.verbs += /HostingSlot/verb/Ban
			src.verbs += /HostingSlot/verb/Download
			src.verbs += /HostingSlot/verb/Upload
			src.verbs += /HostingSlot/verb/ViewLog
		else if (src.currentStatus == SLOT_STOPPED  || src.currentStatus == SLOT_CRASHED)
			src.verbs += /HostingSlot/verb/Start
			src.verbs += /HostingSlot/verb/Download
			src.verbs += /HostingSlot/verb/Upload
			src.verbs += /HostingSlot/verb/ViewLog
		else if (src.currentStatus == SLOT_NOT_SETUP)
			src.verbs += /HostingSlot/verb/Setup



	/*  #################################################
		##               WORLD MANAGEMENT            ####
		################################################# */
	proc/startupWorld()
		if(myDMB() && !portInUse(src.hostedPort))
			myAddress = startup(myDMB(), src.hostedPort, "-logself", "-safe")
			if(myAddress)
				src.currentStatus = SLOT_RUNNING
			return TRUE
	proc/shutdownWorld()
		if(portInUse(src.hostedPort))
			shutdown(myAddress)





	/*  #################################################
		##                     PYTHON                ####
		################################################# */
	proc/runPython()
		return 1


	/*  #################################################
		##                  UPDATING                 ####
		################################################# */
	proc/updateServer()
		if(src.hub)
			fetchFromHub()
		else
			fetchFromZip()
		runPython("extractZip", list(src.myFolder()))


	proc/fetchFromHub()
		..()

	proc/fetchFromZip()
		var/F = null
		while(!F)
			F = input("Please upload your zip containing a dmb and rsc.\n*.zip or *.rar") as file

			var/filename = "[F]"
			var/fileExt = lowertext(copytext(filename, max(length(filename)-3,1)))
			//var/fileSize = length(F)

			if(fileExt != ".zip")
				alert("Invalid file extension.")
				F = null
			else
				fcopy(F, src.updateFile())