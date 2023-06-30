class_name PING
extends Node

# PING Protocol (similar to real ICMP)

# bits instead of bytes are needed for this, since we have sometimes 3 or 4 bits used instead of 8 (1byte)
# so thats why I cant use default stuff like PackedByteArray etc. maybe I should create smth for that

# IPv4 Header:
var header4 = {
	"version": 0100, # 0100=4 means IP version 4
	"IHL": 0101, # IHL = Internet Header Length (IPv4 based) means: how many 32 bit (=4 bytes) headers are in this packet. since there are a min. of required headers, the min. size is 20 (5 x 32bit or 5 x 4byte = 20bytes)
	"TOS": 00000000, # type of service, means the packet-priority (normally higher on VoIP or custom from big games and big companies that modify these bits for better networking)
	"TOTAL_LENGTH": 0000000000000000, # total length converted to bytes: min 20 max. 65.535. # the number "20" shown with bits would mean 20 bytes in the data. so 1 packed can be max. 65535 bytes big, or 8 MBytes
	"FRAGMENT_ID": 0000000000000000, # fragment ID after splitting to place them in the right order, 0 means no following fragments, 1 means there are more fragments incoming, after an ID 1,higher IDs like 2,3,4,5,... are allowed.
	"FLAGS": 010, # Bit 0: is reserved and has to be set to zero, Bit 1: means do not fragment, Bit 2: means more fragments.
	"FRAGMENT_OFFSET": 0000000000000, # its only 13 bits instead of 16, so that it begins to count with 8 instead of 1. (it has to be a multiple of 8)
		# if a packet is 800 bytes big and is split in 2 equal fragments (400 bytes each), the first packet has 0 as offset since it starts at the beginning.
		# the second packet will have the number 50 as binary, since 400bytes / 8 is 50. so in order to set this, we have to read data from TOTAL_LENGTH minus the the size of the packets before.
	"TTL": 00011110, # time to live, each hop decreases this number by 1. default is 30 hops.
	"PROTOCOL": 00000001, # default: 1 = ICMP = PING :), the number 6 is used to indicate TCP, 17 is used to denote the UDP protocol. see: https://en.wikipedia.org/wiki/List_of_IP_protocol_numbers for more IDs
	"HEADER_CHECKSUM": 0000000000000000, # verify data is not modified or has an error.  The IP header is compared to the value of its checksum. When the header checksum is not matching, then the packet will be discarded. 
	"SOURCE_ADDRESS": 00000000000000000000000000000000, # 32 bits = ip address of source
	"DESTINATION_ADDRESS": 00000000000000000000000000000000, # 32 bits = ip address of target
};

func calculate_checksum():
	for key in header4:
		print("index: %s, value: %d" % [key, header4[key]]);  # does it respect the order of the keys? or are they sorted sometimes? maybe after JSON stringify? be aware of that since this can destroy the bit order, I should save them as 1 string.
		
#		HEADER_CHECKSUM is set to 0 while calculation:
		if key == "HEADER_CHECKSUM":
			continue;
		
		# sum everything together
		
		
	pass;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
