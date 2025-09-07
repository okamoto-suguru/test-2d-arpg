# core/ai/_AIBehaviorBase.gd
extends Resource
class_name AIBehavior

# ownerは、このAIを使うキャラクター自身
# 戻り値は、次に遷移すべきStateと、渡すデータを含む辞書
func choose_next_action(owner) -> Dictionary:
	# デフォルトでは、通常攻撃を行う
	return {
		"state": "Ability",
		"ability_data": owner.normal_attack_ability,
		"target": null # ターゲット情報はChaseStateが渡す
	}
