# scripts/BaseResourceBar.gd
class_name BaseResourceBar extends Control

@onready var main_bar: TextureProgressBar = $MainBar
@onready var secondary_bar: TextureProgressBar = $SecondaryBar
var tween: Tween

# バーの値を更新する、共通のコアロジック
func update_value(current_value: int, max_value: int):
	if not is_inside_tree():
		return
		
	main_bar.max_value = max_value
	main_bar.value = current_value
	secondary_bar.max_value = max_value

	if tween:
		tween.kill()
	
	tween = create_tween().set_parallel(true)
	tween.tween_property(secondary_bar, "tint_progress", Color.WHITE, 0.0)
	var tween_value = tween.tween_property(secondary_bar, "value", current_value, 0.5)
	tween_value.set_delay(0.2)
	var tween_color = tween.tween_property(secondary_bar, "tint_progress", Color(1,1,1,1), 0.3)
	tween_color.set_delay(0.2)
