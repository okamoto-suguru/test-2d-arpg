extends State

# 実行するアビリティのレシピ
var ability_data: AbilityData
# 技の硬直時間を管理するタイマー
var countdown: float = 0.0
# AIが狙っている主要なターゲット（プレイヤー）
var main_target = null
# このアビリティ実行中に生成したHitboxのインスタンス
var hitbox_instance: Hitbox

func enter(_previous_state_name: String, data: Dictionary = {}) -> void:
	# 前の状態から、主要ターゲットと使用するアビリティのレシピを受け取る
	if data.has("target"):
		main_target = data["target"]
	if data.has("ability_data"):
		ability_data = data["ability_data"]
	else:
		# データがない場合は、通常攻撃をデフォルトとして実行
		ability_data = owner.normal_attack_ability
	print("攻撃！：",ability_data.ability_name)
	if ability_data.sfx_activation:
		SoundManager.play_sfx(ability_data.sfx_activation)
	# レシピから硬直時間をセット
	countdown = ability_data.duration
	# 実行中は移動を停止
	owner.velocity = Vector2.ZERO

	# --- Hitboxの生成と設定 ---
	# レシピにHitboxシーンが指定されていれば
	if ability_data.hitbox_scene:
		# Hitboxをインスタンス化
		hitbox_instance = ability_data.hitbox_scene.instantiate()
		# 敵キャラクターの子として追加
		owner.add_child(hitbox_instance)
		# ダメージを計算して設定
		hitbox_instance.damage = owner.current_damage * ability_data.damage_multiplier
		# このHitboxは「敵の攻撃」レイヤーに所属させる
		hitbox_instance.collision_layer = 1 << 6 # レイヤー7 (enemy_hitbox)
		# このHitboxは「プレイヤーの当たり判定」レイヤーだけを探す
		hitbox_instance.collision_mask = 1 << 3  # レイヤー4 (player_hurtbox)
		hitbox_instance.sfx_hit = ability_data.sfx_hit
		# ここで、キャラクターの向きに合わせてHitboxの位置や回転を調整する
		hitbox_instance.position = owner.look_direction * 20


func exit() -> void:
	# Stateを抜ける時に、生成したHitboxを安全に破棄する
	if is_instance_valid(hitbox_instance):
		hitbox_instance.queue_free()


func physics_update(delta: float) -> void:
	countdown -= delta

	# Hitboxが有効な場合、レシピに従って当たり判定の有効/無効を切り替える
	if is_instance_valid(hitbox_instance):
		var time_elapsed = ability_data.duration - countdown
		if time_elapsed >= ability_data.active_start_time and time_elapsed < ability_data.active_end_time:
			hitbox_instance.get_node("CollisionShape2D").disabled = false
		else:
			hitbox_instance.get_node("CollisionShape2D").disabled = true

	# 硬直時間が終わったら、Chase状態に戻る
	if countdown <= 0.0:
		finished.emit.call_deferred("Chase", {"target": main_target})
