extends Node2D

# Called before _ready, so that child nodes can know if we're a server or not.
func _enter_tree():
	var server_ip = "127.0.0.1"
	var server_port = 42019
	var server_addr = "ws://" + server_ip + ":" + str(server_port)
	
	if OS.has_feature("web"):
		server_ip = JavaScriptBridge.eval("window.location.hostname")
		server_port = 443
		server_addr = "wss://" + server_ip + "/ws"
	
	if OS.has_feature("dedicated_server") or "--server" in OS.get_cmdline_user_args():
		# Create server and open the port to listen on.
		var peer = WebSocketMultiplayerPeer.new()
		peer.create_server(server_port)
		multiplayer.multiplayer_peer = peer
	else:
		# Connect to Server as Client
		var peer = WebSocketMultiplayerPeer.new()
		peer.create_client(server_addr)
		multiplayer.multiplayer_peer = peer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
