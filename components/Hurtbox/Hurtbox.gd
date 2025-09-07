# Hurtbox.gd
extends Area2D

# 攻撃がヒットした時に発信するシグナル
signal hit(hitbox)

# Area2Dのarea_enteredシグナルに接続する関数
func _on_area_entered(area):
	# 侵入してきたのがHitboxなら、hitシグナルを発信する
	# area.get("damage")で、Hitboxがdamage変数を持っているか安全にチェック
	print("hit")
	if area.has_method("get_damage"):
		emit_signal("hit", area)
