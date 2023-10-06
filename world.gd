extends Node
@export var scoreboard = {}
@onready var menu = $CanvasLayer/MainMenu
@onready var address = $CanvasLayer/MainMenu/MC/Options/address_input
@onready var map = $Node3D
const port = 9999
@onready var gameName =$CanvasLayer/MainMenu/MC/Options/LineEdit
const Player = preload("res://player_body.tscn")
var enet_p = ENetMultiplayerPeer.new()
@export var players = {}
const HOST = 1
func _on_host_b_pressed():
	if gameName.text:
		menu.hide()
		enet_p.create_server(port)
		multiplayer.multiplayer_peer = enet_p
		multiplayer.peer_connected.connect(add_player)
		var peerID = enet_p.get_unique_id()
		add_player(1)

func _input(event):
	if Input.is_action_just_pressed("Jump"):
		print(players)
		
func _on_join_b_pressed():
	if gameName.text:
		print('joinB pressed')
		menu.hide()
		enet_p.create_client('localhost',port)
		multiplayer.multiplayer_peer = enet_p
		
@rpc("any_peer")	
func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player, true)
	scoreboard[str(peer_id)] = 0
	if peer_id == 1:
		players[peer_id] = gameName.text
	else:
		players[peer_id] = ''
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
func addPlayertodict(peerid):
	var gName = gameName.text
	players[str(peerid)] = gName 

func getPlayerName(): 
	pass
