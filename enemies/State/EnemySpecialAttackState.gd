# enemies/State/EnemySpecialAttackState.gd
extends State

# 通常攻撃より少し長い硬直時間
@export var attack_duration: float = 2.0
@export var active_start_time: float = 0.8
@export var active_end_time: float = 1.5

var countdown: float = 0.0
var target = null

@onready var hitbox: Area2D = owner.get_node("Hitbox")

func enter(_previous_state_name: String, data: Dictionary = {}) -> void:
	if data.has("target"):
		target = data["target"]
	
	countdown = attack_duration
	owner.velocity = Vector2.ZERO
	# owner.get_node("AnimatedSprite2D").play("special_attack") # 将来の特殊攻撃アニメーション
	
	# 自身のステータスから攻撃力を取得し、Hitboxに設定（ダメージ2倍）
	hitbox.damage = owner.current_damage * 2

func exit() -> void:
	hitbox.get_node("CollisionShape2D").disabled = true

func physics_update(delta: float) -> void:
	countdown -= delta
	
	var time_elapsed = attack_duration - countdown
	if time_elapsed >= active_start_time and time_elapsed < active_end_time:
		hitbox.get_node("CollisionShape2D").disabled = false
	else:
		hitbox.get_node("CollisionShape2D").disabled = true

	if countdown <= 0.0:
		finished.emit.call_deferred("Chase", {"target": target})
