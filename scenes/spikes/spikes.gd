extends Node2D

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		body.die()
		await get_tree().create_timer(2.0).timeout
		SceneManager.restart_current_scene()
