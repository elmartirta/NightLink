extends Node2D

@export var spawn_path: Node2D
@export var spawner: MultiplayerSpawner
@export var color_picker: OptionButton
@export var player_name: TextEdit

# This is the cursor for the local player.
var our_cursor: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	spawner.spawn_function = add_cursor
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_player_connected)
		multiplayer.peer_disconnected.connect(_on_player_disconnected)
		
		for id in multiplayer.get_peers():
			_on_player_connected(id)
			
		if not OS.has_feature("dedicated_server"):
			_on_player_connected(1)

var cursor_sprites = [
	preload("res://media/art/cursors/black_cursor.svg"),
	preload("res://media/art/cursors/blue_cursor.svg"),
	preload("res://media/art/cursors/green_cursor.svg"),
	preload("res://media/art/cursors/red_cursor.svg")
]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for child in spawn_path.get_children():
		if not child is MultiplayerSpawner:
			var sprite = child.get_node("Cursor Sprite")
			sprite.texture = cursor_sprites[sprite.get_meta("color")]

func add_cursor(id):
	var cursor = preload("res://templates/cursor_template.tscn").instantiate()
	cursor.set_name(str(id))
	cursor.get_node("MultiplayerSynchronizer").set_multiplayer_authority(id)
	if id == multiplayer.get_unique_id():
		our_cursor = cursor
	return cursor

func _on_player_connected(id):
	spawner.spawn(id)

func _on_player_disconnected(id):
	spawn_path.get_node(str(id)).queue_free()

func set_cursor_name(name: String):
	if our_cursor:
		our_cursor.get_node("Cursor Sprite").get_node("Username").text = name

func set_color(color_index: int):
	if our_cursor:
		our_cursor.get_node("Cursor Sprite").set_meta("color", color_index)

func _on_player_name_text_changed():
	set_cursor_name(player_name.text)

func _on_color_item_selected(index):
	set_color(color_picker.selected)

func move_cursor(x: int, y: int):
	if our_cursor:
		our_cursor.position.x = x
		our_cursor.position.y = y

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_position = get_viewport().get_mouse_position()
		move_cursor(mouse_position.x, mouse_position.y)
