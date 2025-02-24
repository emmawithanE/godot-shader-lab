@tool
extends MeshInstance3D

@export var active := false

func _process(delta: float) -> void:
	if !active:
		rotation_degrees = Vector3(0,0,0)
		return
	var mouse_pos : Vector2 = %Control.get_global_mouse_position()
	#DisplayServer.mouse_get_position()
	
	var scaled := mouse_pos / Vector2(DisplayServer.window_get_size())
	var centred := scaled - Vector2(0.5,0.5)
	var to_rot = centred * 40
	
	rotation_degrees.y = to_rot.x
	rotation_degrees.x = to_rot.y
