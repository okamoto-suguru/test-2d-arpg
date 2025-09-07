# autoload/FXManager.gd
extends Node

# Mainシーンのreadyとタイミングが合わないので起動時に参照を取得するのをやめる！
# @onready var damage_number_scene: PackedScene = RM.damage_number_scene

# ダメージ数字を表示するためのグローバルな窓口
func show_damage_number(amount: int, world_position: Vector2, is_critical: bool = false):
	# --- ここからが重要 ---
	# 実際に必要になった、この瞬間にRMからシーンを取得する
	var damage_number_scene: PackedScene = RM.damage_number_scene
	
	# もしRMがまだ準備できていない場合は、安全に処理を中断する
	if not damage_number_scene:
		printerr("DamageNumberシーンがResourceManagerに登録されていません！")
		return
	# --- ここまで ---
	
	var instance = damage_number_scene.instantiate()
	get_tree().get_first_node_in_group("hud_canvas").add_child(instance)
	
	var camera = get_tree().get_first_node_in_group("camera") as Camera2D
	if camera:
		# この座標変換の計算式は、以前の最終版と同じです
		var screen_position = (world_position - camera.global_position) * camera.zoom + camera.get_viewport_rect().size / 2.0
		instance.position = screen_position
	
	var damage_color = Color.YELLOW if is_critical else Color.WHITE
	
	instance.show_damage(amount, damage_color)
