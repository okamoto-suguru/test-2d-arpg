# autoload/CameraManager.gd
extends Node

var camera: GameCamera

# カメラ自身が、起動時に自分を登録するための関数
func register_camera(cam: GameCamera):
	camera = cam

# 画面を揺らすためのグローバルな窓口
func shake(duration: float = 0.2, strength: float = 10.0):
	if is_instance_valid(camera):
		camera.shake(duration, strength)
	else:
		printerr("CameraManagerにカメラが登録されていません。")
