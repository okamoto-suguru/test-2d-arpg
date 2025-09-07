extends Resource
class_name TemporaryUpgradeData

# 強化効果の種類を定義（enum）
enum EffectType {
	ADD_DAMAGE,         # 攻撃力加算
	ADD_MAX_HEALTH,     # 最大HP加算
	INCREASE_DODGE_COUNT, # 回避回数増加
	ADD_PROJECTILE      # 攻撃に弾を追加
}

@export var id: String = "" # 強化のユニークID
@export var upgrade_name: String = "強化名"
@export_multiline var description: String = "強化の説明"

@export var effect_type: EffectType
@export var value: float = 0.0 # 効果量（例: ダメージ+5なら5.0）
