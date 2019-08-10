extends Control

func _ready():
	HTTPManager.connect("debug_signal",self,"debug_print")

func debug_print(body : String, color : String) -> void:
	$RichTextLabel.append_bbcode("[color="+color+"] - "+body+"[/color]\n")
	print(body)