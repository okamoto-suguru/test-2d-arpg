# core/ai/AggressiveMeleeBehavior.gd
extends AIBehavior
class_name AggressiveMeleeBehavior

# 70%の確率で通常攻撃、30%で特殊攻撃
func choose_next_action(owner) -> Dictionary:
	if randf() < 0.7:
		return {
			"state": "Ability",
			"ability_data": owner.normal_attack_ability
		}
	else:
		return {
			"state": "Ability",
			"ability_data": owner.special_attack_ability
		}
