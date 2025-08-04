extends TileMapLayer

@export var beat_interval := 1
@export var starts_on := true

var is_on := true
var player_ref: CharacterBody2D = null

func _ready():
	BeatManager.connect("beat_tick", Callable(self, "_on_beat_tick"))
	player_ref = get_tree().get_first_node_in_group("Player")
	if starts_on:
		_on_beat_tick(0)
	
func _on_beat_tick(beat_count):
	if beat_count % beat_interval  == 0:
		is_on = !is_on
		if is_on:
			_attempt_push_player()
			modulate.a = 1.0
			tile_set.set_physics_layer_collision_layer(0, 1)
			tile_set.set_physics_layer_collision_mask(0, 1)
		else:
			modulate.a = 0.5
			tile_set.set_physics_layer_collision_layer(0, 0)
			tile_set.set_physics_layer_collision_mask(0, 0)

func _attempt_push_player():
	if not player_ref or player_ref.is_dead:
		return
	
	var player_rect = Rect2(player_ref.global_position - Vector2(4, 7), Vector2(8, 14))
	
	var overlapping_tiles = []
	var used_cells = get_used_cells()
	
	for cell_pos in used_cells:
		var world_pos = map_to_local(cell_pos)
		var tile_rect = Rect2(world_pos - Vector2(4, 4), Vector2(8, 8))
		var shrunk_tile = tile_rect.grow(-2)
		
		if shrunk_tile.intersects(player_rect):
			overlapping_tiles.append(cell_pos)
	
	if overlapping_tiles.is_empty():
		return
	
	player_ref.global_position.y -= 12
	player_ref.velocity.y = min(player_ref.velocity.y, 0)
	
	if _is_still_overlapping():
		player_ref.die()
		await get_tree().create_timer(1.5).timeout
		SceneManager.restart_scene()
	
func _is_still_overlapping():
	for cell_pos in get_used_cells():
		var world_pos = map_to_local(cell_pos)
		var tile_rect = Rect2(world_pos - Vector2(4, 4), Vector2(8, 8))
		var player_rect = Rect2(player_ref.global_position - Vector2(6, 7), Vector2(12, 14))
		
		if tile_rect.intersects(player_rect):
			return true
	
	return false
