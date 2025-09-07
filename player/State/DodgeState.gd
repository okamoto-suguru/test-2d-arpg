extends State

@export var dodge_duration: float = 0.4
@export var dodge_speed: float = 250.0
# 無敵時間の開始と終了タイミング
@export var invincible_start_time: float = 0.05
@export var invincible_end_time: float = 0.25

var countdown: float = 0.0

func _init():
	can_be_interrupted = false

func enter(_previous_state_name: String, _data: Dictionary = {}) -> void:
	countdown = dodge_duration
	sync_animation_to_duration("dodge", dodge_duration)

	# 保存されている最後の向きに回避する
	owner.velocity = owner.look_direction.normalized() * dodge_speed

func exit() -> void:
	reset_animation_speed()
	# Stateを抜ける時は、必ず無敵状態を解除する
	owner.is_invincible = false

func physics_update(delta: float) -> void:
	countdown -= delta

	# 無敵時間の判定
	# 回避の開始から0.05秒後～0.25秒後の間だけ無敵になる
	if countdown < (dodge_duration - invincible_start_time) and countdown > (dodge_duration - invincible_end_time):
		owner.is_invincible = true
	else:
		owner.is_invincible = false

	# 回避終了
	if countdown <= 0.0:
		finished.emit.call_deferred("Idle")
	
	owner.move_and_slide()
