# DeployPortal.gd
extends InteractableBase

# インタラクトされた時の処理だけを上書き
func _interact():
	print("戦場へ向かいます...")
	get_tree().change_scene_to_file("res://main.tscn")
