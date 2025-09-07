extends Node

@onready var owner_character: CharacterBase = get_parent()

# 適用された強化効果をここに記録していく
var active_upgrades: Array[TemporaryUpgradeData] = []

func apply_temporary_upgrade(data: TemporaryUpgradeData):
	active_upgrades.append(data)
	
	match data.effect_type:
		TemporaryUpgradeData.EffectType.ADD_DAMAGE:
			owner_character.current_damage += data.value
			print("攻撃力が %d 上昇！ 現在値: %d" % [data.value, owner_character.current_damage])
		
		TemporaryUpgradeData.EffectType.ADD_MAX_HEALTH:
			owner_character.stats.max_health += data.value
			owner_character.current_health += data.value
			GameEvents.player_health_updated.emit(owner_character.current_health, owner_character.stats.max_health)
			print("最大HPが %d 上昇！" % data.value)
		# ...他の効果...
