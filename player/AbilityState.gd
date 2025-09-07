# core/states/AbilityState.gd
extends State

# --- このStateが持つ変数 ---
# 実行するアビリティのレシピ
var ability_data: AbilityData
# 技の硬直時間を管理するタイマー
var countdown: float = 0.0
# AIが狙っている主要なターゲット
var main_target: CharacterBase
# このアビリティ実行中に生成したHitboxのインスタンス
var hitbox_instance: Hitbox

# このStateは、デフォルトでは中断させない
func _init():
	can_be_interrupted = false


# Stateが開始された時に呼ばれる
func enter(_previous_state_name: String, data: Dictionary = {}) -> void:
	# --- 1. レシピとターゲット情報を受け取る ---
	if data.has("main_target"):
		main_target = data["main_target"]
	if data.has("ability_data"):
		ability_data = data["ability_data"]
	else:
		ability_data = owner.normal_attack_ability # データがない場合は通常攻撃をデフォルトに

	# --- 2. 基本的な設定 ---
	countdown = ability_data.duration
	owner.velocity = Vector2.ZERO # 実行中は移動を停止
	
	# --- 3. 演出（アニメーションとサウンド）を開始 ---
	sync_animation_to_duration(ability_data.animation_name, ability_data.duration)
	if ability_data.sfx_activation:
		SoundManager.play_sfx(ability_data.sfx_activation)

	# --- 4. Hitboxの生成と変形 ---
	_setup_hitbox()


# Stateが終了する時に呼ばれる
func exit() -> void:
	# 生成したHitboxを安全に破棄する
	if is_instance_valid(hitbox_instance):
		hitbox_instance.queue_free()
	# アニメーション速度を元に戻す
	reset_animation_speed()


# Stateがアクティブな間、毎フレーム呼ばれる
func physics_update(delta: float) -> void:
	countdown -= delta

	# Hitboxが有効な場合、レシピに従って当たり判定の有効/無効を切り替える
	if is_instance_valid(hitbox_instance):
		var time_elapsed = ability_data.duration - countdown
		if time_elapsed >= ability_data.active_start_time and time_elapsed < ability_data.active_end_time:
			hitbox_instance.get_node("CollisionShape2D").disabled = false
		else:
			hitbox_instance.get_node("CollisionShape2D").disabled = true

	# 硬直時間が終わったら、次の状態に戻る
	if countdown <= 0.0:
		var next_state = "Chase" if "enemies" in owner.get_groups() else "Idle"
		finished.emit.call_deferred(next_state, {"target": main_target})


# --- 内部で使う補助関数 ---

# Hitboxを生成し、設定し、変形させる
func _setup_hitbox():
	if not ability_data.hitbox_scene: return

	hitbox_instance = ability_data.hitbox_scene.instantiate()
	var spawn_parent = _get_spawn_parent(ability_data.spawn_origin)
	spawn_parent.add_child(hitbox_instance)
	
	hitbox_instance.damage = owner.current_damage * ability_data.damage_multiplier
	hitbox_instance.sfx_hit = ability_data.sfx_hit
	
	if owner.is_in_group("player"):
		hitbox_instance.collision_layer = 1 << 4 # player_hitbox
		hitbox_instance.collision_mask = 1 << 5  # enemy_hurtbox
	else:
		hitbox_instance.collision_layer = 1 << 6 # enemy_hitbox
		hitbox_instance.collision_mask = 1 << 3  # player_hurtbox
	
	# 最後に、向きに合わせてHitboxを変形させる
	_apply_isometric_distortion(hitbox_instance)

# レシピのspawn_originに応じて、Hitboxを追加するべき親ノードを返す
func _get_spawn_parent(spawn_origin: int) -> Node2D:
	match spawn_origin:
		AbilityData.SpawnOrigin.SELF:
			return owner
		AbilityData.SpawnOrigin.ATTACK_POINT:
			var attack_point: Node2D = owner.get_node("AttackPoint")
			attack_point.rotation = owner.look_direction.angle()
			return attack_point
		AbilityData.SpawnOrigin.TARGET_POSITION:
			if is_instance_valid(main_target):
				hitbox_instance.global_position = main_target.global_position
			return owner.get_parent() # YSortレイヤー
	return owner # 不明な場合は自分自身を返す


# Hitboxノードのscaleを、アイソメトリックに歪ませる関数
func _apply_isometric_distortion(hitbox: Hitbox):
	# アイソメトリックなY軸の基本圧縮率
	var base_y_squash = 0.5
	
	# キャラクターの向きの角度を取得 (ラジアン)
	var angle = owner.look_direction.angle()
	
	# 角度の絶対値を使って、0~90度の範囲で考える
	var abs_cos = abs(cos(angle))
	var abs_sin = abs(sin(angle))
	
	# 水平に近いほどYを圧縮し(0.5に近づける)、垂直に近いほどYを元に戻す(1.0に近づける)
	var scale_y = lerp(1.0, base_y_squash, abs_cos)
	# 垂直に近いほどXを圧縮し(0.5に近づける)、水平に近いほどXを元に戻す(1.0に近づける)
	var scale_x = lerp(1.0, base_y_squash, abs_sin)
	
	hitbox.scale = Vector2(scale_x, scale_y)
