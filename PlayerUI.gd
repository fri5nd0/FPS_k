extends CanvasLayer

class_name PlayerUi

@onready var ammo_label = $VBoxContainer/Label2 
var ammoCount :int
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func updateAmmoCount(ammo: int):
	ammo_label.text = str(ammo)
