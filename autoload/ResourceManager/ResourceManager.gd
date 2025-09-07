# scripts/ResourceManager.gd
extends Node
class_name ResourceManager

# ここでゲーム中に使う主要なシーンを@exportで定義する
var karma_orb_scene: PackedScene
var player_hitbox_scene: PackedScene
var room_scene: PackedScene
var damage_number_scene: PackedScene
# ...など、今後増えていく
