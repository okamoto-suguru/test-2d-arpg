extends BaseResourceBar

# 追従する対象のキャラクター
var target: CharacterBase

func _process(_delta):
	if not is_instance_valid(target):
		queue_free()
		return
	
	# --- これが最も確実で、最終的な解決策です ---
	var camera = get_tree().get_first_node_in_group("camera") as Camera2D
	
	if camera:
		# ターゲットのワールド座標を、カメラの視点とズームを考慮して
		# 手動でスクリーン座標に変換します
		var screen_position = (target.global_position - camera.global_position) * camera.zoom + camera.get_viewport_rect().size / 2.0
		
		# HPバーの位置を、計算したスクリーン座標に設定します
		position = screen_position + Vector2(0, -40) # Yオフセットは調整
		
# HPバーを初期化するための関数
func initialize(character: CharacterBase):
	target = character
	# BaseResourceBarが持つupdate_value関数を呼び出す
	update_value(target.current_health, target.stats.max_health)
