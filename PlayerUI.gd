extends CanvasLayer

class_name PlayerUi
@onready var gridContainer = $GridContainer
@onready var ammo_label = $VBoxContainer/Label2 
@onready var name_label = $VBoxContainer/Label3
@onready var guninhand = $VBoxContainer/Label4
@onready var StaminaBar = $StamBar 
@onready var healthBar = $HealthBar
var ammoCount :int
var count = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	clearGridContainer()
	updateScoreboard()
	
func updateAmmoCount(ammo: int):
	ammo_label.text = str(ammo)
func playerName(p):
	name_label.text = str(p)

func weaponinhandLabel(p):
	guninhand.text = str(p)
	var playerPeerId = 0
func setHealthBar(health):
	healthBar.value = health
func setStaminaBar(stamina):
	StaminaBar.value = stamina
func updateScoreboard():
	var scoreboard = get_parent().get_parent().getScoreboard()
	var players = get_parent().get_parent().getPlayerNames()
	scoreboard = getSortedDictionary(scoreboard)
	for player in scoreboard.keys(): 
		var player_name = player
		var score = str(scoreboard[player])
		var PlayerLabel = Label.new()
		var ScoreLabel = Label.new()
		var playerGameName = ''
		var playerPeerId = 0
		for p in players.keys():
			if int(player_name) == p:
				playerGameName = players[p]
				playerPeerId = p
		PlayerLabel.text = 'Player '+ str(playerGameName)
		if playerPeerId == int(str(get_parent().name)):
			PlayerLabel.add_theme_color_override('font_color', Color(0,1,0))
		ScoreLabel.text = score
		gridContainer.add_child(PlayerLabel)
		gridContainer.add_child(ScoreLabel)
		count = 1
		
func clearGridContainer():
	for child in gridContainer.get_children():
		gridContainer.remove_child(child)

func getSortedDictionary(scoreboard : Dictionary):
	var scoreBoardList = []
	for key in scoreboard.keys():
		var List = [key,scoreboard[key]]
		scoreBoardList.append(List)
	
	scoreBoardList = mergeSort(scoreBoardList)
	var sortedScoreboard = {}
	for item in scoreBoardList:
		sortedScoreboard[item[0]]= item[1]
	return sortedScoreboard

func mergeSort(array: Array):
	var i = 0
	if array.size() <= 1:
		return array
	var mid = array.size()/2
	var leftList = []
	while i < mid:
		leftList.append(array[i])
		i+=1
	var rightList = []
	var m = mid
	while m < array.size():
		rightList.append(array[m])
		m+=1
	rightList = mergeSort(rightList)
	leftList = mergeSort(leftList)
	var sortedScoreboarList = comparisons(rightList,leftList)
	return sortedScoreboarList

func comparisons(left:Array,right:Array):
	var sorted = []
	var a = 0
	var b = 0
	while a < left.size() and b < right.size():
		if left[a][1]> right[b][1]:
			sorted.append(left[a])
			a+=1
		else:
			sorted.append(right[b])
			b+=1
	while a < left.size():
		sorted.append(left[a])
		a+=1
	while b<right.size():
		sorted.append(right[b])
		b+=1
	return sorted

