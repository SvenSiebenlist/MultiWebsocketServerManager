extends Control
var _SERVER: PackedScene = preload("res://Server/Server.tscn");
var crypto:Crypto = Crypto.new()
var key:CryptoKey = CryptoKey.new()
var cert:X509Certificate = X509Certificate.new()
var server_cert = null;
var server_key = null;
var server_tls_options: TLSOptions = null;

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_button_create_server_pressed();
	# Generate new RSA key.
#	server_key = crypto.generate_rsa(4096);
#	server_key = key.load("res://certs/privkey.key")
	# Generate new self-signed certificate with the given key.
	# server_cert = crypto.generate_self_signed_certificate(server_key, "CN=localhost,O=My Game Company,C=DE");
	
#	server_key = load("res://certs/privkey.key");
	# Generate new self-signed certificate with the given key.
#	server_cert = load("res://certs/fullchain.crt");
	
#	server_tls_options = TLSOptions.server(server_cert, server_key);
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func create_server() -> Server:
	get_window().set_embedding_subwindows(false);

	var server_instance = _SERVER.instantiate();
	server_instance.visible = true;
	var pos:Vector2 = get_screen_position();
	server_instance.size = Vector2(300,300);
	pos.x -= server_instance.size.x + 10;
	server_instance.position = pos;
	server_instance.title = "WebSocket SERVER";
	return server_instance;

func _on_button_create_server_pressed():
	var host = $InputHostname.text;
	var port = $InputPort.text;
	
	var server: Server = create_server();
	var status: Error = server.start(host, port, server_tls_options);
	if(!status):
		$ServerList.add_item(str(host, ":", port));
		$ServerList.add_child(server);
