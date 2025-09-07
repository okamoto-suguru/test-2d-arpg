# scripts/ResourceLoader.gd
extends Node

# ...@export変数の定義...
@export var karma_orb_scene: PackedScene
@export var player_hitbox_scene: PackedScene
@export var room_scene: PackedScene
@export var damage_number_scene: PackedScene

func _ready():
	# このスクリプトが持つプロパティのリストを取得
	var properties = get_script().get_script_property_list()
	
	for p in properties:
		# @exportされた変数のみを対象とする
		if p.usage & PROPERTY_USAGE_STORAGE:
			var property_name = p.name
			# このノードから値を取得
			var value = get(property_name)
			# シングルトン(RM)の同名変数に値を設定
			RM.set(property_name, value)
