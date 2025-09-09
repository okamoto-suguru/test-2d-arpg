extends State

# 最初の子（Idle）を初期状態とする
@onready var current_child_state: State = get_child(0)

func enter(_previous_state_name: String, _data: Dictionary = {}) -> void:
	# この親Stateに入ったら、その最初の子（Idle）のenter処理も呼び出す
	current_child_state.enter(_previous_state_name, _data)

	# 全ての子Stateのfinishedシグナルを、自身の中間管理用の関数に接続する
	for child in get_children():
		if child is State:
			# すでに接続されていないか確認
			if not child.finished.is_connected(_on_child_state_finished):
				child.finished.connect(_on_child_state_finished)


func exit() -> void:
	# この親Stateを抜ける時は、現在の子Stateのexit処理も呼び出す
	current_child_state.exit()
	
	# 後片付けとしてシグナルを切断
	for child in get_children():
		if child is State:
			if child.finished.is_connected(_on_child_state_finished):
				child.finished.disconnect(_on_child_state_finished)


# OnGroundState.gd の handle_input 関数を修正

func handle_input(event: InputEvent) -> void:
	# 現在の子Stateが中断可能な場合のみ、新しいアクションを受け付ける
	if current_child_state.can_be_interrupted:
		if event.is_action_pressed("jump"):
			finished.emit("InAir")
			return

		if state_machine.can_process_input and event.is_action_pressed("dodge"):
			_transition_to("Dodge")
			return
		
		if state_machine.can_process_input and event.is_action_pressed("attack"):
			# "Ability" Stateに、通常攻撃のレシピを渡して遷移
			_transition_to("Ability", {"ability_data": owner.normal_attack_ability})
			return
		# 将来的に特殊攻撃ボタンを追加する場合
		if state_machine.can_process_input and event.is_action_pressed("special_attack"):
			_transition_to("Ability", {"ability_data": owner.special_attack_ability})
			return

	# 子State自身の入力処理は常に呼ぶ
	current_child_state.handle_input(event)


func physics_update(delta: float) -> void:
	# 現在の子Stateに物理更新を渡す
	current_child_state.physics_update(delta)


# 子Stateから遷移要求が来た時に呼ばれる
func _on_child_state_finished(next_state_name: String, data: Dictionary = {}) -> void:
	_transition_to(next_state_name, data)


# このOnGroundState内部での遷移を処理する
func _transition_to(next_state_name: String, data: Dictionary = {}):
	var target_node = get_node_or_null(next_state_name)
	if not target_node:
		return

	var previous_state_name := current_child_state.name
	print("Sub-State Change (OnGround): %s -> %s" % [previous_state_name, next_state_name])

	current_child_state.exit()
	current_child_state = target_node
	# ここで受け取ったdataを、子Stateのenter関数に渡す
	current_child_state.enter(previous_state_name, data)
