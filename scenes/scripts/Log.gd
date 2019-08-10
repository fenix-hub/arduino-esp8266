extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	HTTPManager.connect("log_signal",self,"log_save")
	webserver_data.load_data(webserver_data.log_file)
	$RichTextLabel.append_bbcode(webserver_data.log_)

func log_save(message : String):
	var time = OS.get_datetime()
	var stamp : String = str(time.day)+"-"+str(time.month)+"-"+str(time.year)+"   "+str(time.hour)+":"+str(time.minute)+" ["+webserver_data.webserver_ip+"] - "
	var content = (stamp+" "+message)
	$RichTextLabel.append_bbcode(content+"\n")
	webserver_data.save_data(webserver_data.log_file,content)
