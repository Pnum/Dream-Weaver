/*

	HUB DATUM LIBRARY
	Created by Foomer (2009)

*/

hub_page
	var
		title
		author
		path
		short_desc
		long_desc
		version
		banner
		icon
		small_icon

		list/servers = list()

		// For internal use:
		hub_address = "http://www.byond.com/games/"


// You can specify the path to the hub page in the datum's new proc.
// If it fails to update the datum because the page could not be read
// properly, it will self-delete.
hub_page/New(hub_path)
	if(!src.Update(hub_path))
		del(src)


// Updates the datum with information extracted from the hub page.
// If no path argument is specified, it will attempt to use the datum's
// existing hub path, so that updates to an existing datum do not need
// to include the path address again.
hub_page/proc/Update(hub_path)
	var/savefile/hubpage = src.Import(hub_path)
	if(!hubpage)
		return 0

	// Load the information about the hub entry.
	hubpage.cd = "/general"
	src.title = hubpage["title"]
	src.author = hubpage["author"]
	src.path = hubpage["path"]
	src.short_desc = hubpage["short_desc"]
	src.long_desc = hubpage["long_desc"]
	src.version = hubpage["version"]
	src.banner = hubpage["banner"]
	src.icon = hubpage["icon"]
	src.small_icon = hubpage["small_icon"]

	return 1


// This builds the hub address from the path value. If at some time you
// want to change this library to access something other than BYOND games,
// you may want to alter the return value for this proc.
hub_page/proc/BuildAddress(hub_path)
	return "[src.hub_address][hub_path]?format=text"


// This converts the content of the web page into a savefile and returns
// the newly created savefile containing the hub page's information.
hub_page/proc/Import(hub_path)
	ASSERT(hub_path)

	// Get the hub page for the game.
	var/address = world.Export(src.BuildAddress(hub_path))

	// Web address not found.
	if(!address)
		return

	// No such hub entry on BYOND servers.
	var/content_length = address["CONTENT-LENGTH"]
	if(content_length == "305" || !content_length)
		return

	// Acquire the content of the hub page in text format, and then
	// import the contents of the address into a savefile.
	var/text = file2text(address["CONTENT"])
	var/savefile/savefile = new()
	savefile.ImportText("/", text)
	return savefile
