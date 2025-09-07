# components/damage_number/DamageNumber.gd
extends Label

# この関数で、表示する数字と色を外部から設定する
func show_damage(amount: int, color: Color = Color.WHITE):
	text = str(amount)
	modulate = color

	# アニメーションを実行
	var tween = create_tween()
	# 0.7秒かけて、30ピクセル上に移動しながら、フェードアウトする
	tween.tween_property(self, "position:y", position.y - 64, 0.7).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.7).from(1.0)
	# アニメーションが終わったら、自分自身を削除する
	tween.tween_callback(queue_free)
