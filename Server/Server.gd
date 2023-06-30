class_name Server
extends Window

var blockProxyConnections = false;

var _CLIENT: PackedScene = preload("res://Client/Client.tscn");
var websocket_server: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new();
var connected_peers = [];

## gateways that are controlled by the server
var server_gateways = ["64.64.64.64", "128.64.128.128", "192.64.192.192",
						"64.128.64.64", "128.128.128.128", "192.128.192.192",
						"64.192.64.64", "128.192.128.128", "192.192.192.192"
					]; # holds all ISP gateways
#"9.64.0.0", "11.128.0.1", "129.128.0.1", "169.128.0.1", "172.128.0.1", "192.44.3.1", "192.88.100.1", "192.169.0.1", "198.20.0.1"
## possible ip addresses for public devices: # -> maybe change ISP-gateways randomly between these IP ranges.
# 
#    1.0.0.0 – 9.255.255.255
#
#    11.0.0.0 – 126.255.255.255
#
#    129.0.0.0 – 169.253.255.255
#
#    169.255.0.0 – 172.15.255.255
#
#    172.32.0.0 – 191.0.1.255
#
#    192.0.3.0 – 192.88.98.255
#
#    192.88.100.0 – 192.167.255.255
#
#    192.169.0.0 – 198.17.255.255
#
#    198.20.0.0 – 223.255.255.255







#var host: String = "";
#var port: int = 0;
var prefix = str("[SERVER][" , get_instance_id() , "]");

# default methods:
func _ready():
	print(prefix,"[METHOD] SERVER._READY() ");
	print(prefix,"[DEBUG] Protocols: ", websocket_server.get_supported_protocols());
	# websocket_server.set_supported_protocols([]); # demo-chat, etc.

	for ip in server_gateways:
		var new_client: Client = _CLIENT.instantiate();
		new_client.setAddress(ip);
		new_client.position = new_client.addressToPosition();
		new_client.peerId = 0;
		new_client.peerAddr = "0.0.0.0";
		new_client.modulate = Color(255, 0, 0, 1);
		%MiniMap.add_child(new_client);

func _process(_delta):
	websocket_server.poll();
	var count = websocket_server.get_available_packet_count();
	if(count):
		print("PACKET FOUND:", count);
		var peerId = websocket_server.get_packet_peer();
		var messageRaw = websocket_server.get_packet().get_string_from_utf8();
		# var messageObj = JSON.parse_string(messageRaw);
		print("[CLIENT-MSG] new message from peerId: '",  peerId, "'\n -> messageRaw: ", messageRaw);


# basics server methods (start/stop/exit etc.):
func start(host, port, server_tls_options = null):
	print(prefix,"[METHOD] SERVER.START()");
	var error = websocket_server.create_server(int(port), host, server_tls_options);
	if error:
		print(prefix, "[DEBUG] Server can't start, error: ", error, " (queue_free)");
		delete();
		return error;
	print(prefix, "[DEBUG] Server is running and listening on: ws://", host, ":", port, " with Options: ", server_tls_options)
	
	# Connect the peer_connected signal to the _on_peer_connected method
	websocket_server.connect("peer_connected", Callable(self, "_on_peer_connected"));
	websocket_server.connect("peer_disconnected", Callable(self, "_on_peer_disconnected"));
	
	
#	var client = websocket_server.create_client(str("ws://", host, ":", port));
#	print("TEST CLIENT: ", client)
	
	return Error.OK;
	
func stop():
	print("[Method] SERVER.STOP()");
	websocket_server.close();
	print("Server has stopped successfully.");

func delete():
	queue_free();

# helper methods
func getClientByPeerId(peerId):
	for user in %MiniMap.get_children():
		if(user.peerId == peerId):
			return user;
	return null;

func getClientByAddress(ipAddress):
	for user in %MiniMap.get_children():
		if(user.peerAddr == ipAddress):
			return user;
	return null;



func getPeerIdList():
	var clients = [];
	for client in %MiniMap.get_children():
		if(client.peerId != null):
			clients.push_back(client.peerId);
	return clients;


# build network packets for the users:
func buildMessage(peerId, message: String):
	return {
		"action":"MESSAGE",
		"data": message
	};

# ready to transfer over sockets to multiplayer instances. filter: no passwords etc. allowed.
## collect all visible clients that are connected with the given client.
func getSimplifiedKnownClients(client):
	var clients = [];
	# collect the subClients
	for subClient in client.getSubClientList():
		clients.push_back(subClient.toMinimapNetworkPacket());
	return clients;

## in this method, we collect all needed network-informations for clients after they connect to the server
## and build a simple networkpacket for this specific client known by the 'peerId'
func buildSimplifiedUserUpdate(peerId):
	var client = getClientByPeerId(peerId);
	var clients = [client.toMinimapNetworkPacket()];
	clients.append_array(getSimplifiedKnownClients(client));
	return {
		"action":"UPDATE_USER",
		"data": clients
	};

func emitObjectToPeer(obj, peer):
	var packet = JSON.stringify(obj);
	peer.send_text(packet);
	return;


# events
func _on_peer_connected(peerId: int): # peer connected
	var peer = websocket_server.get_peer(peerId);
	var peerAddr = websocket_server.get_peer_address(peerId);
	print("\nPeer connected: ", peerId, " with IP Address: ", peerAddr);
	
	# is multi-user or using same proxy:
	var client = getClientByAddress(peerAddr);
	if(client):
		var jsonObj = buildMessage(peerId, "ILLEGAL LOGIN!");
		emitObjectToPeer(jsonObj, peer);
		if(blockProxyConnections):
			peer.close()
			return;
	
	# create new client
	var new_client: Client = _CLIENT.instantiate();
#	new_client.position.x = randi() % 291;
#	new_client.setAddress(str(randi_range(0,255), ".", randi_range(0,255), ".", randi_range(0,255), ".", randi_range(0,255)));
	new_client.position = new_client.addressToPosition();
	new_client.peerId = peerId;
	new_client.peerAddr = peerAddr;
	%MiniMap.add_child(new_client);
	
	# give client-peer informations about the 'known/visible' network for that specific client
	
	# old solution: give all connected clients
#	var peers = getPeerIdList();
#	for p in peers:
#		var jsonObj2 = buildSimplifiedUserUpdate(p);
#		emitObjectToPeer(jsonObj2, websocket_server.get_peer(p));
	
	
	# only emit KNOWN clients...
	var jsonObj2 = buildSimplifiedUserUpdate(peerId);
	emitObjectToPeer(jsonObj2, peer);



	
	# testing here
#	var client_peer = websocket_server.get_peer(peerId);
#	var buffer: PackedByteArray = [];
#	client_peer.put_packet(buffer);

func _on_peer_disconnected(peerId: int): # peer disconnected
	print("Client disconnected! ", peerId);
	var client:Client = getClientByPeerId(peerId);
	if(client):
		client.queue_free();
	
	return false;
