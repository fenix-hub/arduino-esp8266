extends LineEdit

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	HTTPManager.connect("update_moisture",self,"update_moisture")

func update_moisture(val : String) -> void:
	set_text(val)
