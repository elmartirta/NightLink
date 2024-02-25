extends GridContainer

@export var player_cursors: Node2D
@export var color_picker: OptionButton
@export var player_name: TextEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	var server_ip = "0.0.0.0"
	var server_port = 42019
	
	if true or OS.has_feature("dedicated_server") or "--server" in OS.get_cmdline_user_args():
		# Create server and open the port to listen on.
		var peer = ENetMultiplayerPeer.new()
		peer.create_server(server_port, 10)
		multiplayer.multiplayer_peer = peer
	else:
		# Connect to Server as Client
		var peer = ENetMultiplayerPeer.new()
		peer.create_client(server_ip, server_port)
		print("Create Client " + server_ip + ":" + str(server_port))
		multiplayer.multiplayer_peer = peer
	
	if multiplayer.is_server():
		player_cursors._on_player_connected(multiplayer.get_unique_id())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_name_text_changed():
	player_cursors.set_cursor_name.rpc(multiplayer.get_unique_id(), player_name.text)

func _on_color_item_selected(index):
	player_cursors.set_color.rpc(multiplayer.get_unique_id(), color_picker.selected)
