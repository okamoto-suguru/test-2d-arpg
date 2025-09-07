# Hitbox.gd
extends Area2D
class_name Hitbox

@export var damage: int = 10
var sfx_hit: AudioStream

func get_damage() -> int:
	return damage
