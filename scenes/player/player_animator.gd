extends Node2D

@export var anim_sprite: AnimatedSprite2D
@export var player: CharacterBody2D

func _process(delta):
	update_animation()

func update_animation():
	if player.is_dead:
		anim_sprite.play("fall")
		return
	
	if player.is_on_wall() and player.velocity.y > 0:
		anim_sprite.play("slide")
	elif not player.is_on_floor():
		if player.velocity.y < 0:
			anim_sprite.play("jump")
		else:
			anim_sprite.play("fall")
	elif abs(player.velocity.x) > 5:
		anim_sprite.play("run")
	else:
		anim_sprite.play("idle")
	
	if player.velocity.x < 0:
		anim_sprite.flip_h = true
	elif player.velocity.x > 0:
		anim_sprite.flip_h = false
