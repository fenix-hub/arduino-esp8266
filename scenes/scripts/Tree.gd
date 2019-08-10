extends Tree

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func load_webserver_list():
	clear()
	
	var root = create_item()
	root.set_text(0,"Webserver Ip")
	root.set_text(1,"Webserver Name")
	root.set_text(2,"Last Connection")
	
	
	for webserver in webserver_data.data:
		var nod = create_item()
		nod.set_text(0,webserver_data.data[webserver].webserver_ip)
		nod.set_text_align(0,1)
		nod.set_text(1,webserver_data.data[webserver].webserver_name)
		nod.set_text_align(1,1)
		nod.set_text(2,webserver_data.data[webserver].last_connection)
		nod.set_text_align(2,1)

