# InAirState.gd (見下ろし視点用)

extends State

@export var jump_height: float = 192.0   # ジャンプの高さ（ピクセル）
@export var jump_duration: float = 0.5  # ジャンプの時間（秒）

var countdown: float = 0.0
# 元のマスクを保存しておく変数
var original_mask: int
# ジャンプで動かす見た目のスプライト
@onready var character_sprite: AnimatedSprite2D = owner.get_node("CharacterSprite")

func enter(_previous_state_name: String, _data: Dictionary = {}) -> void:
	countdown = jump_duration
	# 空中でのアニメーションを開始
	sync_animation_to_duration("jump", jump_duration)
	# 1. 現在のコリジョンマスクを保存
	original_mask = owner.get_collision_mask()
	# 2. 空中では"world"レイヤー(レイヤー2)とだけ衝突するようにマスクを上書き
	owner.set_collision_mask_value(2, true)  # worldと衝突ON
	owner.set_collision_mask_value(3, false) # enemiesと衝突OFF

func physics_update(delta: float) -> void:
	countdown -= delta

	if countdown <= 0.0:
		# ジャンプ終了
		finished.emit.call_deferred("OnGround")
		return

	# ジャンプの進行度を計算 (0.0 -> 1.0 -> 0.0 の放物線を描く)
	var t = 1.0 - (countdown / jump_duration)
	var y_offset = 4.0 * jump_height * t * (1.0 - t)
	
	# 見た目のスプライトだけを上に動かす
	character_sprite.position.y = -y_offset
	
	# 地面での移動処理はそのまま実行
	var move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	owner.velocity = move_input * 150.0
	# 向きの更新処理
	if move_input != Vector2.ZERO:
		owner.look_direction = move_input
	owner.move_and_slide()

func exit() -> void:
	# 3. 着地したら、コリジョンマスクを元に戻す
	owner.collision_mask = original_mask
	# 念のため、スプライトの位置を元に戻す
	character_sprite.position.y = -52
	reset_animation_speed()
