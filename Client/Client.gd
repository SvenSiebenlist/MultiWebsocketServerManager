## this is the real network client, it handles as manager for ingame clients named 'gateway'.
class_name Client
extends Node2D

var peerId = null;
var peerAddr = "0.0.0.0"; # REAL ip addresses

func setAddress(addr):
	%Gateway.ip_addr = addr;
	position = addressToPosition();

func toMinimapNetworkPacket(): # rename to: , usage: minimap position
	var obj = {};
	obj.id = get_instance_id();
	obj.username = name;
#	var pos = addressToPosition();
#	obj.position = {"x": pos.x, "y": pos.y}
	obj.color = {"r":modulate.r, "g":modulate.g, "b": modulate.b, "a": modulate.a};
	obj.ip_addr = %Gateway.ip_addr;
	return obj;

func addressToPosition(addr: String = getGatewayAddress()) -> Vector2:
	var addrParts = addr.split(".");
	print("addrParts", addrParts)
	var minimapSize = Vector2(300,300);
	var x = floor(int(addrParts[0]) / 255.0 * minimapSize.x);
	var y = floor(int(addrParts[1]) / 255.0 * minimapSize.y);
	var angle = floor(int(addrParts[2]) / 255.0 * 360.0);
	var radius = floor(int(addrParts[3]) / 255.0 * 10.0);
	var nx = x + (radius * cos(angle));
	var ny = y + (radius * sin(angle));
	return Vector2(nx, ny);

func getSubClientList():
	return %Gateway.subClients;

func getGatewayAddress():
	return %Gateway.ip_addr;

func getConnectedClientAddressList():
	var list = [];
	for client in %Gateway.subClients:
		if(client.gateway == %Gateway.ip_addr):
			list.push_back(client.ip_addr);
	return list;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
