extends Node
var scoreboard = {}
@onready var menu = $CanvasLayer/MainMenu
@onready var address = $CanvasLayer/MainMenu/MC/Options/address_input
@onready var map = $Node3D
const port = 9999
const Player = preload("res://player_body.tscn")
var enet_p = ENetMultiplayerPeer.new()
var players = []
func _on_host_b_pressed():
	menu.hide()
	enet_p.create_server(port)
	multiplayer.multiplayer_peer = enet_p
	multiplayer.peer_connected.connect(add_player)
	add_player(1)

func _on_join_b_pressed():
	menu.hide()
	enet_p.create_client('localhost',port)
	multiplayer.multiplayer_peer = enet_p
#	add_player(1)

@rpc("any_peer")	
func add_player(peer_id):
	if enet_p.get_unique_id() == 1:
		add_player.rpc(peer_id)
		var player = Player.instantiate()
		player.name = str(peer_id)
#	player.game_name = $CanvasLayer/MainMenu/MC/Options/LineEdit.text
		add_child(player, true)
		for p in scoreboard.keys():
			add_player.rpc_id(peer_id, int(p))
	scoreboard[str(peer_id)] = 0
	print(scoreboard)
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
		

func getPlayerIndex(Pname):
	var index = 0
	for key in scoreboard.keys():
		if key == Pname:
			return index
		index += 1
	
func wPrint(x):
	print(str(x))

func getScoreboard():
	return scoreboard
