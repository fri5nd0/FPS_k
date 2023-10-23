extends Node
@export var Address = '127.0.0.1'
@export var scoreboard = {}
@onready var menu = $CanvasLayer/MainMenu
@onready var address = $CanvasLayer/MainMenu/MC/Options/address_input
@onready var map = $Node3D
const port = 6000
@onready var gameName =$CanvasLayer/MainMenu/MC/Options/LineEdit
const Player = preload("res://player_body.tscn")
@export var players = {}
var remoteGameName : String
func _on_host_b_pressed():
	var enet_p = ENetMultiplayerPeer.new()
	menu.hide()
	enet_p.create_server(port)
	multiplayer.multiplayer_peer = enet_p
#	enet_p.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.peer_connected.connect(add_player)
	add_player(multiplayer.get_unique_id())
#	upnp_setup()
func _input(event):
	if Input.is_action_just_pressed("Jump"):
		print(players)
		
func _on_join_b_pressed():
#	if address.text:
		menu.hide()
		var enet_p = ENetMultiplayerPeer.new()
		print('joinB pressed')
		remoteGameName = gameName.text
		enet_p.create_client(Address,port)
		multiplayer.multiplayer_peer = enet_p
#		enet_p.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
#		multiplayer.connected_to_server.connect(addPlayertodict,1)
#		print(remoteGameName)
#		print(enet_p.get_unique_id())
#		addPlayertodict.rpc_id(1,enet_p.get_unique_id(),remoteGameName)
@rpc("any_peer", "call_local")	
func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player, true)
	scoreboard[str(peer_id)] = 0
	if peer_id == 1:
		players[peer_id] = 1
	else:
		var lastVal :int
		for p in players.values():
			lastVal = p
		players[peer_id] = lastVal+1
func findSafeSpawn():
	var safeQuadrant: int
	var Q1 = map.get_node('Quadrant1')
	var Q2 = map.get_node('Quadrant2')
	var Q3 = map.get_node('Quadrant3')
	var Q4 = map.get_node('Quadrant4')
	var WorstQuadrantCount = max(Q1.PlayersInQuadrant, Q2.PlayersInQuadrant,Q3.PlayersInQuadrant,Q4.PlayersInQuadrant)
	if Q1.PlayersInQuadrant == WorstQuadrantCount:
		safeQuadrant = 3
	if Q2.PlayersInQuadrant == WorstQuadrantCount:
		safeQuadrant = 4
	if Q3.PlayersInQuadrant == WorstQuadrantCount:
		safeQuadrant = 1
	if Q4.PlayersInQuadrant == WorstQuadrantCount:
		safeQuadrant = 2
	return safeQuadrant

func checkForPlayer(opponent):
	if scoreboard.has(opponent):
		return true
@rpc("any_peer","call_local")
func changeScore(PlayerName:String, shotname):
	if PlayerName != '':
		var currentScore = scoreboard[PlayerName]
		currentScore += 1
		scoreboard[PlayerName] += 1
		print('Scoreboard of:'+ shotname)
		print(scoreboard)
		
func getScoreboard():
	return scoreboard

func getPlayerNames():
	return players

@rpc("any_peer","call_local")
func setPlayerNames(PName,peer_id):
	if PName:
		players[PName] = str(peer_id)

@rpc("any_peer")
func addPlayertodict(peerid,gName):
	players[peerid] = gName 

@rpc("any_peer")
func setPlayerName(gamename): 
	remoteGameName = gamename

func getGameName():
	return gameName.text

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(port)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())
