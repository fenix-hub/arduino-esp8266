extends Node

var webserver_ip : String = "" setget set_webserver_ip, get_webserver_ip
var webserver_name : String = "" setget set_webserver_name, get_webserver_name
var data_file : String = "user://webservers.json" 
var log_file : String = "user://log.txt" 
var data : Dictionary = {} setget set_data,get_data
var webserver_state : String = "" setget set_webserver_state, get_webserver_state
var log_ : String = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.




# setget part # --------------------------------------------------------------------------------------------------------

func set_webserver_ip(ip : String) -> void:
	webserver_ip = ip

func get_webserver_ip() -> String:
	return webserver_ip

func set_webserver_name(name_n : String) -> void:
	webserver_name = name_n

func get_webserver_name() -> String:
	return webserver_name

func set_data_file(path : String) -> void:
	data_file = path

func get_data_file() -> String:
	return data_file

func set_data(d : Dictionary) -> void:
	data = d

func get_data() -> Dictionary:
	return data

func set_webserver_state(state : String) -> void:
	webserver_state = state

func get_webserver_state() -> String:
	return webserver_state

# save / load file part # -------------------------------------------------------------------------------------------------

func save_data(path_file : String, message : String) -> void:
	var file = File.new()
	if file.file_exists(path_file):
		file.open(path_file,File.READ_WRITE)
	else:
		file.open(path_file,File.WRITE)
	
	match(path_file):
		data_file:
			file.store_line(JSON.print(create_data()))
		log_file:
			file.store_line(message)
	
	file.close()

func create_data() -> Dictionary:
	var time = OS.get_datetime()
	
	data[webserver_ip] = ( {
		"webserver_ip": webserver_ip,
		"webserver_name": webserver_name,
		"last_connection": str(time.day)+"-"+str(time.month)+"-"+str(time.year)+"   "+str(time.hour)+":"+str(time.minute)
			} )
	
	return data

func load_data(path_file : String) -> void :
	var file : File = File.new()
	if file.open(path_file,File.READ) != OK:
		return
	else:
		match(path_file):
			data_file:
				set_data(JSON.parse(file.get_as_text()).result)
			log_file:
				log_ = file.get_as_text()
				print(log_)
				
		
		file.close()

func current_webserver(wip : String , wnam : String) -> void :
	webserver_ip =  wip
	webserver_name = wnam