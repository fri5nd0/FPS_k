extends Control
@onready var label = $VBoxContainer/Label
var PlayersInGame = []
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	label.text = str(PlayersInGame)
	if visible == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
func updatePlayersInGame(peer_id):
	PlayersInGame.append(peer_id)
	
