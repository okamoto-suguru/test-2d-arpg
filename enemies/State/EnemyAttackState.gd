# EnemyAttackState.gd
extends State

# 攻撃全体の時間
@export var attack_duration: float = 1.5
# 攻撃判定が発生し始める時間
@export var active_start_time: float = 0.5
# 攻撃判定が終了する時間
@export var active_end_time: float = 1.0

var countdown: float = 0.0
var target = null

@onready var hitbox: Area2D = owner.get_node("Hitbox") # Hitbox本体への参照
@onready var hitbox_collision: CollisionShape2D = owner.get_node("Hitbox/CollisionShape2D")

func enter(_previous_state_name: String, data: Dictionary = {}) -> void:
	if data.has("target"):
		target = data["target"]
	
	countdown = attack_duration
	owner.velocity = Vector2.ZERO
	hitbox.damage = owner.current_damage
	# owner.get_node("AnimatedSprite2D").play("attack") # 攻撃アニメーションを再生

func exit() -> void:
	# Stateを抜ける時は、必ずHitboxを無効化する
	hitbox_collision.disabled = true

func physics_update(delta: float) -> void:
	countdown -= delta

	# 攻撃判定が発生する時間かどうかを判定
	var time_elapsed = attack_duration - countdown
	if time_elapsed >= active_start_time and time_elapsed < active_end_time:
		hitbox_collision.disabled = false
	else:
		hitbox_collision.disabled = true

	if countdown <= 0.0:
		finished.emit.call_deferred("Chase", {"target": target})
