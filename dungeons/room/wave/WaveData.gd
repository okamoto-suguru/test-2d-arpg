# scripts/rooms/WaveData.gd
extends Resource
class_name WaveData

enum TriggerCondition {
	PREVIOUS_WAVE_CLEARED, # 前のウェーブが全滅したら
	TIME_ELAPSED          # 指定時間が経過したら
}

@export var trigger: TriggerCondition
@export var trigger_delay: float = 0.0 # 条件達成から次のウェーブ開始までの遅延時間

@export var enemy_spawns: Array[PackedScene]
@export var spawner_scenes: Array[PackedScene]
