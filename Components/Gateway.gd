extends Sprite2D

# EVERYTHING IS A FILE!!!

var gateway = "192.168.178.1"; # default: 0.0.0.0 = zero conf
#var ip_addr = "192.168.178.100"; # default: 0.0.0.0 = zero conf
	
var ip_addr = str(randi_range(0,255), ".", randi_range(0,255), ".", randi_range(0,255), ".", randi_range(0,255));

## whenever a client uses this client as a gateway, this client stores his "subClients" in this list.
## (but only when they are online)
var subClients = [];


var filepaths = {
	"/root": {}, # executables, system-files, etc.
	"/home": {}  # users default file storage
	
	}; # multi-dimensional array to store all file-paths

var nics = []; # network interfaces
var listenings = []; # hostnames, ports etc.
var routes = []; # known routes

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
