# enemies/boss/states/BossUltimateAttackState.gd
extends State

var ability_data: AbilityData
var countdown: float = 0.0
var target = null
var hitbox_instance: Hitbox

# このStateは中断させない
func _init():
	can_be_interrupted = false

func enter(_previous_state_name: String, data: Dictionary = {}) -> void:
	if data.has("target"):
		target = data["target"]
	# 実行すべきアビリティとして、必殺技のレシピを受け取る
	if data.has("ability_data"):
		ability_data = data["ability_data"]
	else:
		ability_data = owner.ultimate_attack_ability
	print("攻撃！：",ability_data.ability_name)
	countdown = ability_data.duration
	owner.velocity = Vector2.ZERO
	
	# 必殺技の音やアニメーションを開始
	if ability_data.sfx_activation:
		SoundManager.play_sfx(ability_data.sfx_activation)
	# sync_animation_to_duration(ability_data.ability_name, ability_data.duration)

	# Hitboxを生成・設定
	if ability_data.hitbox_scene:
		hitbox_instance = ability_data.hitbox_scene.instantiate()
		owner.add_child(hitbox_instance)
		hitbox_instance.damage = owner.current_damage * ability_data.damage_multiplier
		hitbox_instance.sfx_hit = ability_data.sfx_hit
		hitbox_instance.collision_layer = 1 << 6 # enemy_hitbox
		hitbox_instance.collision_mask = 1 << 3  # player_hurtbox

func exit() -> void:
	if is_instance_valid(hitbox_instance):
		hitbox_instance.queue_free()

func physics_update(delta: float) -> void:
	countdown -= delta

	if is_instance_valid(hitbox_instance):
		var time_elapsed = ability_data.duration - countdown
		if time_elapsed >= ability_data.active_start_time and time_elapsed < ability_data.active_end_time:
			hitbox_instance.get_node("CollisionShape2D").disabled = false
		else:
			hitbox_instance.get_node("CollisionShape2D").disabled = true

	if countdown <= 0.0:
		# 攻撃が終わったら、ChaseではなくVulnerable（隙だらけ）状態に遷移する
		finished.emit.call_deferred("Vulnerable", {"target": target})
