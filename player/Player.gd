# Player.gd
extends CharacterBase

var is_invincible: bool = false:
	set(value):
		is_invincible = value
		if is_invincible:
			$CharacterSprite.modulate.a = 0.5
		else:
			$CharacterSprite.modulate.a = 1.0

func _ready():
	super._ready()
	# Hurtboxのhitシグナルを、Playerの_on_hurtbox_hit関数に接続
	$Hurtbox.hit.connect(_on_hurtbox_hit)
	
	GameEvents.player_health_updated.emit(current_health, stats.max_health)

# Hurtboxが攻撃を受けたら呼ばれる関数
func _on_hurtbox_hit(hitbox):
	if is_invincible:
		return # 無敵中はダメージを受けない

	take_damage(hitbox.get_damage(), hitbox.sfx_hit, false)
	# ここにHPを減らす処理などを追加していく

func take_damage(damage_amount: int, hit_sfx: AudioStream, is_critical: bool):
	super.take_damage(damage_amount, hit_sfx, is_critical) # 親のダメージ処理を呼び出す
	# ダメージを受けた後、更新されたHP情報を通知する
	GameEvents.player_health_updated.emit(current_health, stats.max_health)

# Controllerへの参照
@onready var temp_upgrade_controller = $TemporaryUpgradeController

func apply_temporary_upgrade(data: TemporaryUpgradeData):
	# 実際の処理はControllerに丸投げする
	temp_upgrade_controller.apply_temporary_upgrade(data)


# Player固有の死亡処理
func die():
	super.die() # 親クラスのprint文も呼び出す
	print("ゲームオーバー")
	# ここにゲームオーバー処理を記述
	GameEvents.player_died.emit()
