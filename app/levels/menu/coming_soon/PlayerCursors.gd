extends Node2D

@export var cursor_template: Node2D = null
var cursors = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_position = get_viewport().get_mouse_position()
		move_cursor.rpc(multiplayer.get_unique_id(), mouse_position.x, mouse_position.y)

func _on_player_connected(id):
	print("Connect " + str(id))
	cursors[id] = cursor_template.duplicate(0)
	cursors[id].visible = true
	add_child(cursors[id])

func _on_player_disconnected(id):
	print("Disconnect " + str(id))
	cursors[id].queue_free()
	cursors.erase(id)

@rpc("any_peer", "call_local", "reliable")
func set_cursor_name(id: int, name: String):
	cursors[id].get_node("Cursor Sprite").get_node("Username").text = name

var cursor_sprites = [
	preload("res://media/art/cursors/black_cursor.svg"),
	preload("res://media/art/cursors/blue_cursor.svg"),
	preload("res://media/art/cursors/green_cursor.svg"),
	preload("res://media/art/cursors/red_cursor.svg")
]

@rpc("any_peer", "call_local", "reliable")
func set_color(id: int, color_index: int):
	cursors[id].get_node("Cursor Sprite").texture = cursor_sprites[color_index]

@rpc("any_peer", "call_local", "unreliable_ordered")
func move_cursor(id: int, x: int, y: int):
	cursors[id].position.x = x
	cursors[id].position.y = y
