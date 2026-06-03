extends Node3D
@export var character_id := 5
@export var endpoint := "http://localhost:8000/api"
var pos := Vector2i(0, 0)
var dir := Vector2i(1, 0)
var http_request: HTTPRequest
var local_map: Array

func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)
	_move(0, 0)

func _move(dx: int, dy: int):
	if http_request.request("%s/%d/move" % [endpoint, character_id],
	   ["Content-Type: application/json"],
	   HTTPClient.METHOD_POST,
	   JSON.stringify({"dx": dx, "dy": dy})) != OK:
		print("not OK")
		return
	var result = await http_request.request_completed
	var json = JSON.new()
	json.parse(result[3].get_string_from_utf8())
	var resp_body = json.get_data()
	pos = Vector2i(resp_body.pos_x, resp_body.pos_y)
	if http_request.request("%s/localmap/%d" % [endpoint, character_id]) != OK:
		return
	result = await http_request.request_completed
	json.parse(result[3].get_string_from_utf8())
	resp_body = json.get_data()
	local_map = resp_body.local_map
	_rebuild_maze()
	
func _rebuild_maze():
	for ch in $MazeWalls.get_children():
		ch.queue_free()
	var block := BoxMesh.new()
	block.size = Vector3(1, 0.5, 1)
	for dy in range(-3, 4):
		for dx in range(-3, 4):
			var x = local_map[3 + dy][3 + dx]
			if x == "#":
				var b = MeshInstance3D.new()
				b.mesh = block
				b.position = Vector3(dx, 0, dy)
				$MazeWalls.add_child(b)
	_set_camera()
	$Control/Label.text = "(%d, %d)" % [pos.x, pos.y]

func _set_camera():
	var yrot := 0.0
	if dir.x == 1:
		yrot = 270
	elif dir.y == 1:
		yrot = 180
	elif dir.x == -1:
		yrot = 90
	$Camera3D.rotation_degrees = Vector3(0, yrot, 0)
		

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("KEY_UP"):
		_move(dir.x, dir.y)
	if Input.is_action_just_pressed("KEY_DOWN"):
		_move(-dir.x, -dir.y)
	if Input.is_action_just_pressed("KEY_LEFT"):
		dir = Vector2(dir.y, -dir.x)	
		_set_camera()
	if Input.is_action_just_pressed("KEY_RIGHT"):
		dir = Vector2(-dir.y, dir.x)	
		_set_camera()
