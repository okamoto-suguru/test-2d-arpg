extends State

# この攻撃の持続時間（硬直時間）
@export var attack_duration: float = 0.5
@onready var hitbox: Area2D = owner.get_node("Hitbox")
@onready var hitbox_collision: CollisionShape2D = owner.get_node("Hitbox/CollisionShape2D")

# 内部で使うタイマー変数
var countdown: float = 0.0

func _init():
	can_be_interrupted = false

func enter(_previous_state_name: String, _data: Dictionary = {}) -> void:
	# Stateに入った時に、タイマーをセット
	countdown = attack_duration
	hitbox.damage = owner.current_damage
	# アニメーション時間を同期して再生
	sync_animation_to_duration("attack", attack_duration)
	# 攻撃開始時にHitboxを有効化
	hitbox_collision.disabled = false

func physics_update(delta: float) -> void:
	# 毎フレーム、タイマーを減らす
	countdown -= delta
	
	# タイマーが0以下になったら、待機状態に戻る
	if countdown <= 0.0:
		finished.emit.call_deferred("Idle")

func exit() -> void:
	# 攻撃終了時にHitboxを無効化
	hitbox_collision.disabled = true
	reset_animation_speed()
