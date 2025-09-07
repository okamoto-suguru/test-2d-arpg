extends State

@export var move_speed: float = 200.0

# PlayerノードのAnimatedSprite2Dを取得

func enter(_previous_state_name: String, _data: Dictionary = {}) -> void:
	sprite.play("run") # "run"は走りアニメーション名に置き換えてください
	print("Entered Move State.") # デバッグ用
	
func physics_update(_delta: float) -> void:
	var move_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# 移動入力がある場合、キャラクターを動かす
	if move_input != Vector2.ZERO:
		owner.velocity = move_input * move_speed
		# 向きの更新処理
		if move_input != Vector2.ZERO:
			owner.look_direction = move_input
		owner.move_and_slide()
	# 移動入力がなくなったら、"Idle"状態に遷移する
	else:
		finished.emit.call_deferred("Idle")

func exit() -> void:
	# MoveStateを抜けるときに、念のため速度を0にしておく
	owner.velocity = Vector2.ZERO
