# scripts/rooms/RoomData.gd
extends Resource
class_name RoomData

enum VictoryCondition {
	CLEAR_ALL_ENEMIES,
	SURVIVE_FOR_TIME,
	DESTROY_TARGETS
}

@export var victory_condition: VictoryCondition
# スポーンさせる敵のシーン配列
@export var waves: Array[WaveData]
# この部屋が使用するレイアウトシーン
@export var layout_scene: PackedScene
# サバイバルの場合の制限時間
@export var survival_time: float = 30.0
