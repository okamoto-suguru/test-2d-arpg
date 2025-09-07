# scripts/CharacterBase.gd
extends CharacterBody2D
class_name CharacterBase

@export var stats: CharacterStats
@export var ai_behavior: AIBehavior
@export var normal_attack_ability: AbilityData
@export var special_attack_ability: AbilityData
@export var ultimate_attack_ability: AbilityData

var current_health: int
# 実際の戦闘で使う、計算後のステータス
var current_speed: float
var current_damage: int

func _ready():
	if character_sprite.material:
		character_sprite.material = character_sprite.material.duplicate()
	initialize_stats()
	GameEvents.player_stats_changed.connect(update_stats)
	
# ゲーム開始時に一度だけ呼ばれる、完全な初期化
func initialize_stats():
	if not stats: return
	
	current_health = stats.max_health
	# update_statsを呼び出して、他のステータスも計算させる
	update_stats()
	
	print("%s のステータスを初期化: HP=%d" % [name, current_health])

# 向きを記憶する変数をCharacterBaseに移動
var look_direction: Vector2 = Vector2.RIGHT
# 反転中かどうかを管理するフラグ
var is_flipping: bool = false

@onready var character_sprite: AnimatedSprite2D = $CharacterSprite
# ヒットフラッシュ用のアニメーションを保持する変数
var hit_flash_tween: Tween

# _physics_processをCharacterBaseに追加
func _physics_process(_delta):
	# look_directionのx成分に応じてスプライトを反転させる
	var target_scale_x = character_sprite.scale.x

	if look_direction.x < 0:
		target_scale_x = -1.0
	elif look_direction.x > 0:
		target_scale_x = 1.0
	
	if not is_flipping and target_scale_x != character_sprite.scale.x:
		_execute_flip_animation(target_scale_x)

# 反転アニメーションを実行する関数
func _execute_flip_animation(target_scale: float):
	is_flipping = true
	var tween = create_tween()
	tween.tween_property(character_sprite, "scale:x", 0, 0.1)
	tween.tween_property(character_sprite, "scale:x", target_scale, 0.1)
	await tween.finished
	is_flipping = false

# 強化時など、プレイ中に呼ばれる更新処理
func update_stats():
	if not stats: return
	
	var previous_max_health = stats.max_health # ここではまだ古い最大HP
	# 将来的に最大HPを強化する場合の処理
	# var new_max_health = stats.max_health + PlayerData.health_level * 10
	# if new_max_health > previous_max_health:
	#	current_health += new_max_health - previous_max_health
	
	current_speed = stats.speed
	
	if is_in_group("player"):
		current_damage = stats.attack_damage + (PlayerData.attack_level * 2)
	else:
		current_damage = stats.attack_damage
		
	print("%s のステータスを更新: DMG=%d" % [name, current_damage])


func take_damage(damage_amount: int, hit_sfx: AudioStream, is_critical: bool):
	current_health -= damage_amount
	print("%sが %d ダメージを受けた！残りHP: %d" % [name, damage_amount, current_health])
	if hit_sfx:
		SoundManager.play_sfx(hit_sfx)
	_start_hit_flash_effect()
	if damage_amount > stats.max_health * 0.1:
		CameraManager.shake(0.2, damage_amount * 0.5)
	# FXManagerを呼び出して、ダメージ数字を表示する
	FXManager.show_damage_number(damage_amount, global_position, is_critical)
	if current_health <= 0:
		die()

func _start_hit_flash_effect():
	if hit_flash_tween:
		hit_flash_tween.kill()
		
	hit_flash_tween = create_tween()
	
	# シェーダーのパラメータ "flash_modifier" を0.1秒で1.0(白)にし、
	# さらに0.1秒で0.0(元に戻す)ようにアニメーションさせる
	hit_flash_tween.tween_property(character_sprite.material, "shader_parameter/flash_modifier", 1.0, 0.1)
	hit_flash_tween.tween_property(character_sprite.material, "shader_parameter/flash_modifier", 0.0, 0.1)

# 死亡処理は、PlayerとEnemyで挙動が違うので、空の関数として用意
func die():
	print("%s is dead." % name)
	queue_free()
	# 具体的な処理は子クラスで書く
	pass
