extends CanvasLayer

class_name PlayerUi

@onready var ammo_label = $VBoxContainer/Label2 
@onready var name_label = $VBoxContainer/Label3
@onready var Lastshot = $VBoxContainer/Label4
var ammoCount :int
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func updateAmmoCount(ammo: int):
	ammo_label.text = str(ammo)
func playerName(p):
	name_label.text = str(p)

func lastShotbyLabel(p):
	Lastshot.text = str(p)
