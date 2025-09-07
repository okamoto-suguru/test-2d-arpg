# enemies/boss/states/BossVulnerableState.gd
extends State

# 隙を晒す時間
@export var vulnerable_duration: float = 3.0
var countdown: float = 0.0
var target = null

# このStateも中断させない
func _init():
	can_be_interrupted = false

func enter(_previous_state_name: String, data: Dictionary = {}) -> void:
	if data.has("target"):
		target = data["target"]
		
	countdown = vulnerable_duration
	owner.velocity = Vector2.ZERO
	# owner.get_node("CharacterSprite").play("vulnerable") # 息切れアニメーションなど
	print("ボスが大きな隙を晒した！攻撃のチャンス！")

func physics_update(delta: float) -> void:
	countdown -= delta
	if countdown <= 0.0:
		# 時間が来たら、通常のChase状態に戻る
		finished.emit.call_deferred("Chase", {"target": target})
