# KarmaOrb.gd
extends Area2D

@export var karma_value: int = 1

func _on_body_entered(body):
	if body.is_in_group("player"):
		PlayerData.add_karma(karma_value)
		queue_free()
