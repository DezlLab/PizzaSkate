extends Area2D

const ACT_BODY_NAME := "Player"

enum PizzaShape {
	Circle
}

enum CellState {
	EMPTY,
	FULL,
	CUT
}

class Cutter:
	var node : Node2D
	var curPos : Vector2
	var isCutting := true
	
	func _init() -> void:
		curPos = Vector2.ZERO

var cellStates := PackedByteArray()
var cellIds := PackedByteArray()
var cutters : Array[Cutter]
var curShape := PizzaShape.Circle
var circleRadius := 45.0
var resolution := Vector2i(64, 64) : 
	set(newRes) :
		resolution = newRes
		cellStates.resize(resolution.x * resolution.y)
		cellIds.resize(resolution.x * resolution.y)
		_set_shape(curShape)

var cellBounds : Rect2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var node = ColorRect.new()
	node.color = Color.PURPLE
	#node.position = $CollisionShape2D.position
	cellBounds = $CollisionShape2D.shape.get_rect()
	node.size = cellBounds.size
	node.position = cellBounds.position
	self.add_child(node)
	
	resolution = Vector2i(96, 96)
	_cut_line(Vector2i(40, 75), Vector2i(90, 80))
	_dbg_print()
	
	cutters.append(Cutter.new())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_dbg_show()
	print($CharacterBody2D.position)
	_update_cutter(cutters[0], $CharacterBody2D.position / 32.0)


func _dbg_show():
	var addNodes := false
	var nodes = $DBG.get_children()
	if nodes.size() == 0:
		for y in resolution.y:
			for x in resolution.x:
				var node = ColorRect.new()
				node.position = Vector2(x, y) * 32
				node.size = Vector2(28, 28)
				$DBG.add_child(node)
	else:
		var i := 0
		for node in nodes:
			node.color.a = float(cellStates[i] / 3.0)
			i += 1

func _dbg_print():
	for y in resolution.y:
		var str := ""
		for x in resolution.x:
			if cellStates[y*resolution.x+x] != 1:
				str += "."
			else:
				str += "#"
		print(str)

func _set_shape(shape : PizzaShape):
	for y in resolution.y:
		for x in resolution.x:
			var newState := CellState.EMPTY
			if shape == PizzaShape.Circle:
				if (Vector2(x, y) - resolution / 2.0 + Vector2.ONE / 2.0).length() <= circleRadius:
					newState = CellState.FULL
				cellStates[y*resolution.x+x] = newState

func _update_cutter(cutter : Cutter, newPos : Vector2):
	if cutter.isCutting:
		_cut_line(cutter.curPos, newPos)
	cutter.curPos = newPos

func _cut_line(curPos : Vector2i, newPos : Vector2i):
	var dx :float= newPos.x - curPos.x
	var dy :float= newPos.y - curPos.y
	var m := dy/dx
	var y := 0
	for x in range(curPos.x, newPos.x):
		y = m * (x - newPos.x) + curPos.x
		cellStates[y * resolution.x + x] = CellState.CUT


func _on_body_entered(body: Node2D) -> void:
	if body.name == ACT_BODY_NAME:
		cutters.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body.name == ACT_BODY_NAME:
		cutters.erase(body) ##body should only be in list once!
