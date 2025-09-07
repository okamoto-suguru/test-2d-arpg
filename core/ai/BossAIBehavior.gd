# core/ai/BossAIBehavior.gd
extends AIBehavior
class_name BossAIBehavior

func choose_next_action(owner) -> Dictionary:
	# HPが30%以下になったら、最優先で必殺技を使う
	if owner.current_health < owner.stats.max_health * 0.3:
		return {
			"state": "UltimateAttack", # 新しいStateに遷移
			"ability_data": owner.ultimate_attack_ability, # 必殺技のレシピ
			"target": null # ターゲット情報はChaseStateが渡してくれる
		}

	# それ以外は、通常攻撃と特殊攻撃を50%の確率で使い分ける
	if randf() < 0.5:
		return { "state": "Ability", "ability_data": owner.normal_attack_ability }
	else:
		return { "state": "Ability", "ability_data": owner.special_attack_ability }
