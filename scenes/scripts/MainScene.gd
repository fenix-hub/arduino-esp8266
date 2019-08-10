extends Node

var menu : bool = true #the switch sets it false
onready var debug_web : Node = $Debug
onready var status1 : Node = $DeviceChoice/VBoxContainer/HBoxContainer/status2
onready var status2 : Node = $DeviceManager/HBoxContainer/status


func _ready() -> void:
	HTTPManager.connect("update_status_signal",self,"update_status")
	
	webserver_data.load_data(webserver_data.data_file)
	switch_child($DeviceChoice)
	$DeviceChoice/VBoxContainer/HBoxContainer2/disconnect.disabled = true
	webserver_data.webserver_state = "disconnected"
	update_status(webserver_data.webserver_state)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func manage_menu() -> void:
	menu=!menu
	match (menu):
		false:
			$AnimationPlayer.play("menu_out")
		true:
			$AnimationPlayer.play("menu_in")

func _on_MenuButton_pressed():
	manage_menu()

func switch_child(child : Node) -> void:
	for ch in get_children():
		if ch.get_class()=="Control" and ch.get_name() != "Overlay" and ch.get_name() != "Menu":
			if  ch != child :
				ch.visible=false
			else:
				ch.visible=true
	
	manage_menu()


func _on_Webserver_pressed():
	switch_child($DeviceManager)


func _on_ChangeIP_pressed():
	switch_child($DeviceChoice)


func _on_Exit_pressed():
	get_tree().set_auto_accept_quit(true)
	get_tree().quit()

func _on_disconnect_pressed():
	
	webserver_data.webserver_state = "disconnected"
	update_status(webserver_data.webserver_state)
	HTTPManager.Request.cancel_request()
	$DeviceChoice/VBoxContainer/HBoxContainer2/connect.disabled = false
	$DeviceChoice/VBoxContainer/HBoxContainer2/disconnect.disabled = true


func _on_connect_pressed():
	var ip : String = $DeviceChoice/VBoxContainer/webserver_ip.get_text()
	var nam : String = $DeviceChoice/VBoxContainer/webserver_name.get_text()
	if ip!="" and nam!="":
		webserver_data.webserver_state = "pending"
		
		update_status(webserver_data.webserver_state)
		
		$DeviceChoice/VBoxContainer/HBoxContainer2/connect.disabled = true
		$DeviceChoice/VBoxContainer/HBoxContainer2/disconnect.disabled = false
		webserver_data.current_webserver(ip,nam)
		
		webserver_data.save_data(webserver_data.data_file,"")
		
		$DeviceManager/HBoxContainer/w_ip.set_text(ip)
		$DeviceManager/HBoxContainer/w_name.set_text(nam)
		
		HTTPManager.httprequest("request","")


func _on_WebserverList_pressed():
	switch_child($WebServerList)
	$WebServerList/Tree.load_webserver_list()


func _on_Guide_pressed():
	switch_child($Guide)

func _on_Debug_pressed():
	switch_child(debug_web)

func _on_Tree_item_selected():
	var webserver : TreeItem = $WebServerList/Tree.get_selected()
	$DeviceChoice/VBoxContainer/webserver_ip.set_text(webserver.get_text(0))
	$DeviceChoice/VBoxContainer/webserver_name.set_text(webserver.get_text(1))

#func _on_HTTPRequest_request_completed(result, response_code, headers, body):
#	if webserver_data.webserver_state == "connected" or webserver_data.webserver_state == "pending":
#		debug_web.debug_print("Richiesta http eseguita...","green")
#		debug_web.debug_print("Result code to http request: "+str(result),"yellow")
#		debug_web.debug_print("Response code to http request: "+str(response_code),"yellow")
#
#		http_response = str(body.get_string_from_utf8())
#		$HTTPRequest.cancel_request()
#
#		if body_request == "":
#			update_status(http_response)
#			webserver_data.webserver_state = http_response
#		else:
#			update_moisture(str(http_response))
#			debug_web.debug_print("Aggiorno umidità: "+http_response,"orange")
#			HTTPManager.httprequest("moisture")
#	else:
#		debug_web.debug_print("Disconnesso dal Webserver, impossibile completare richieste","red")

#func httprequest(body_r : String) -> void:
#	if webserver_data.webserver_state == "connected" or webserver_data.webserver_state == "pending":
#		var http_request : String = webserver_data.webserver_ip+"/"+body_r
#		body_request = body_r
#		debug_web.debug_print("Richiesta http: " + str(http_request),"green")
#		var err = $HTTPRequest.request("http://"+http_request,["Cache-Control: no-cache"],false,0,"")
#		debug_web.debug_print("Risposta http: " + str(err),"yellow")
#		if err > 1:
#			webserver_data.webserver_state = "error"
#			update_status(webserver_data.webserver_state)
#	else:
#		debug_web.debug_print("Disconnesso dal Webserver, impossibile eseguire richieste","red")

func update_status(http_r : String) -> void:
	status1.match_icon_status(str(http_r))
	status2.match_icon_status(str(http_r))
	match(http_r):
		"connected":
			debug_web.debug_print("Connesso al server","green")
			HTTPManager.emit_signal("log_signal","Connesso al server")
			$DeviceChoice/VBoxContainer/state_message.text = "Connected to Webserver!"
		"error":
			debug_web.debug_print("Errore nella connessione","red")
			$DeviceChoice/VBoxContainer/state_message.text = "Can't connect to Webserver!"
			HTTPManager.emit_signal("log_signal","Errore nella connessione")
		"disconnected":
			debug_web.debug_print("Disconnesso dal server","gray")
			$DeviceChoice/VBoxContainer/state_message.text = "No webserver to connect to."
			HTTPManager.emit_signal("log_signal","Disconnesso dal server")
		"pending":
			debug_web.debug_print("Provo a connettermi al server...","orange")
			$DeviceChoice/VBoxContainer/state_message.text = "Connecting to the webserver..."
			HTTPManager.emit_signal("log_signal","Provo a connettermi al server...")



func _on_moisture_btn_toggled(button_pressed):
	if (button_pressed):
		HTTPManager.button_moisture = true
		HTTPManager.httprequest("request","moisture")
		debug_web.debug_print("Attivato aggiornamento umidità","cyan")
		HTTPManager.emit_signal("log_signal","Led 1 acceso")
	else:
		HTTPManager.button_moisture = false
		$DeviceManager/VBoxContainer/HBoxContainer2/moisture.text = "---"
		HTTPManager.Request.cancel_request()
		debug_web.debug_print("Disattivato aggiornamento umidità","gray")
		HTTPManager.emit_signal("log_signal","Led 1 spento")

func _on_led1_toggled(button_pressed):
	HTTPManager.httprequest("command","toggleled1")

#func _on_HTTPCommand_request_completed(result, response_code, headers, body):
#	HTTPManager.httprequest("moisture")


func _on_Log_pressed():
	switch_child($Log)
