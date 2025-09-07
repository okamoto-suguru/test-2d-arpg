# GameCamera.gd
extends Camera2D
class_name GameCamera

var tween: Tween

func _ready():
	# 起動時に、シングルトンに自分自身を登録する
	CameraManager.register_camera(self)

# 揺れを開始する関数
func shake(duration: float = 0.2, strength: float = 10.0):
	if tween:
		tween.kill()

	tween = create_tween()
	# duration秒かけて、ランダムな方向にstrengthの強さでオフセットを加え、元に戻すのを繰り返す
	tween.tween_property(self, "offset", Vector2(randf_range(-strength, strength), randf_range(-strength, strength)), duration / 4)
	tween.tween_property(self, "offset", Vector2(randf_range(-strength, strength), randf_range(-strength, strength)), duration / 4)
	tween.tween_property(self, "offset", Vector2(randf_range(-strength, strength), randf_range(-strength, strength)), duration / 4)
	tween.tween_property(self, "offset", Vector2.ZERO, duration / 4) # 最後に必ず中央に戻す
