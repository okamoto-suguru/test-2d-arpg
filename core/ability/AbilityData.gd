# 以前のAttackDataを改名・拡張
extends Resource
class_name AbilityData

## アビリティが誰を対象にするかを定義する
enum TargetType {
	SELF,               # 自分自身
	SINGLE_ENEMY,       # 狙っている単体の敵
	NEAREST_ENEMY,      # 最も近い敵
	ENEMIES_IN_HITBOX,  # Hitbox内の全ての敵
	ENEMIES_IN_RADIUS,  # 半径内の全ての敵
	ALLIES_IN_RADIUS    # 半径内の全ての味方
}

## アビリティがどこから発生するかを定義する
enum SpawnOrigin {
	SELF,           # 自分自身の足元
	ATTACK_POINT,   # 向きに合わせた攻撃基点
	TARGET_POSITION # ターゲットの足元
}

@export var ability_name: String = "アビリティ名"
@export var animation_name: String = "attack" # 再生するアニメーション名
@export_multiline var description: String = "アビリティの説明"
@export var sfx_activation: AudioStream # 空振り音
@export var sfx_hit: AudioStream   # ヒット音

# このアビリティの硬直時間
@export var duration: float = 1.0
# --- ターゲティングと攻撃範囲 ---
@export var target_type: TargetType = TargetType.ENEMIES_IN_HITBOX
@export var spawn_origin: SpawnOrigin = SpawnOrigin.ATTACK_POINT
@export var hitbox_scene: PackedScene
@export var radius: float = 300.0
# ダメージ倍率
@export var damage_multiplier: float = 1.0
# 攻撃判定の開始・終了時間
@export var active_start_time: float = 0.2
@export var active_end_time: float = 0.8

# 将来の拡張用
# @export var effects: Array[Effect]
