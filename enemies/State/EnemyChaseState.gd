extends State

# 移動速度
@export var move_speed: float = 80.0

# 攻撃範囲と索敵範囲のArea2Dへの参照
@onready var attack_range: Area2D = owner.get_node("AttackRange")
@onready var detection_area: Area2D = owner.get_node("DetectionArea")

# 追いかける対象のターゲット
var target = null

func enter(_previous_state_name: String, data: Dictionary = {}) -> void:
	# 前の状態からターゲット情報を受け取る
	if data.has("target"):
		target = data["target"]

func physics_update(_delta: float) -> void:
	# ターゲットを見失ったり、倒されたりしたらIdle状態に戻る
	if not is_instance_valid(target):
		finished.emit("Idle")
		return

	# ターゲットが攻撃範囲に入ったら、どの攻撃を出すか決めて遷移する
	var bodies_in_attack_range = attack_range.get_overlapping_bodies()
	if bodies_in_attack_range.has(target):
		var decision = _choose_next_action()
		# "Ability" Stateに、使用するアビリティのレシピ(data)とターゲット情報を渡す
		finished.emit(decision["state"], decision)
		return

	# ターゲットが索敵範囲から出たらIdle状態に戻る
	var bodies_in_detection_range = detection_area.get_overlapping_bodies()
	if not bodies_in_detection_range.has(target):
		finished.emit("Idle")
		return

	# 上記のいずれでもなければ、ターゲットに向かって移動を続ける
	var direction = owner.global_position.direction_to(target.global_position)
	owner.velocity = direction * move_speed
	owner.look_direction = direction
	owner.move_and_slide()

# どの攻撃を出すか決定する補助関数
# 将来的には、このロジックをAIBehaviorリソースに置き換える
func _choose_next_action() -> Dictionary:
	# キャラクターが持つAIデータに、次の行動を決めさせる
	if owner.ai_behavior:
		var decision = owner.ai_behavior.choose_next_action(owner)
		# ターゲット情報を追加して返す
		decision["target"] = target
		return decision
	else:
		# AIが未設定なら、以前のランダムな攻撃を行う
		if randf() < 0.7:
			return { "state": "Ability", "ability_data": owner.normal_attack_ability, "target": target }
		else:
			return { "state": "Ability", "ability_data": owner.special_attack_ability, "target": target }
