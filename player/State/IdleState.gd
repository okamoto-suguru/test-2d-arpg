extends State

func enter(_previous_state_name: String, _data: Dictionary = {}) -> void:
	print("Entered Idle State.") # デバッグ用
	sprite.play("idle")

func physics_update(_delta: float) -> void:
	# 移動入力があったら、"Move"状態に遷移するよう、シグナルを発信する
	var move_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if move_input != Vector2.ZERO:
		finished.emit.call_deferred("Move")
