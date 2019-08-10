extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal debug_signal(message,color) 
signal update_status_signal(status)
signal update_moisture(val)
signal log_signal(message)

onready var Request : Node = $HTTPRequest
onready var Command : Node = $HTTPCommand

var body_request : String = ""
var button_moisture : bool 
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func httprequest(type : String, body_r : String) -> void:
	if webserver_data.webserver_state == "connected" or webserver_data.webserver_state == "pending":
		var http_request : String = webserver_data.webserver_ip+"/"+body_r
		body_request = body_r
		emit_signal("debug_signal","Richiesta http: " + str(http_request) + " (tipo: "+type+")","green")
		var err : int
		match(type):
			"request":
				err = Request.request("http://"+http_request,["Cache-Control: no-cache"],false,0,"")
				
			"command":
				Request.cancel_request()
				match(body_r):
					"toggleled1":
						emit_signal("debug_signal","Accensione/Spegnimento Led1","arancione")
				err = Command.request("http://"+http_request,["Cache-Control: no-cache"],false,0,"")
				
		emit_signal("debug_signal","Risposta http: " + str(err),"yellow")
		if err > 1:
			webserver_data.webserver_state = "error"
			emit_signal("update_status_signal",(webserver_data.webserver_state))
	else:
		emit_signal("debug_signal","Disconnesso dal Webserver, impossibile eseguire richieste","red")

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if webserver_data.webserver_state == "connected" or webserver_data.webserver_state == "pending":
		emit_signal("debug_signal","Richiesta http eseguita...","green")
		emit_signal("debug_signal","Result code to http request: "+str(result),"yellow")
		emit_signal("debug_signal","Response code to http request: "+str(response_code),"yellow")
		
		var http_response = str(body.get_string_from_utf8())
		Request.cancel_request()
		
		if body_request == "":
			emit_signal("update_status_signal",http_response)
			webserver_data.webserver_state = http_response
			
		else:
			emit_signal("update_moisture",str(http_response))
			
			emit_signal("log_signal","Moisture = "+http_response)
			
			emit_signal("debug_signal","Aggiorno umidità: "+http_response,"orange")
			httprequest("request","moisture")
	else:
		emit_signal("debug_signal","Disconnesso dal Webserver, impossibile completare richieste","red")

func _on_HTTPCommand_request_completed(result, response_code, headers, body):
	if button_moisture:
		httprequest("request","moisture")