extends TextureRect

var icons : Dictionary = {"connected":Vector2(256,0),"error":Vector2(0,0),"pending":Vector2(0,256),"disconnected":Vector2(256,256)}


func _ready():
	match_icon_status("disconnected")

func match_icon_status(status : String) -> void:
	set_icon(icons[status])
	update()

func set_icon(icon : Vector2) -> void:
	get_texture().set_region(Rect2(icon,Vector2(256,256)))