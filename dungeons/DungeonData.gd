# scripts/dungeons/DungeonData.gd
extends Resource
class_name DungeonData

@export var rooms: Array[RoomData]
@export var rooms_before_boss: int = 3
@export var boss_room: RoomData
