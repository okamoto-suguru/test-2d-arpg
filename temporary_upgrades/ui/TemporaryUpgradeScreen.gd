# TemporaryUpgradeScreen.gd
extends CanvasLayer

# 最終的に選択された強化をゲーム本体に伝えるためのシグナル
signal upgrade_selected(temporary_upgrade_data)

@onready var card_container: HBoxContainer = $ColorRect/HBoxContainer

# 外部から呼び出され、3つの強化データをカードにセットする関数
func show_upgrades(upgrades: Array[TemporaryUpgradeData]):
	var cards = card_container.get_children()
	
	if cards.size() != upgrades.size():
		printerr("カードの数と強化データの数が一致しません！")
		return

	# 各カードにデータを設定し、selectedシグナルを接続する
	for i in range(cards.size()):
		var card = cards[i]
		var data = upgrades[i]
		
		card.set_data(data)
		# 接続済でなければ接続
		if not card.selected.is_connected(_on_card_selected):
			card.selected.connect(_on_card_selected)

# いずれかのカードが選択された時に呼ばれる
func _on_card_selected(data: TemporaryUpgradeData):
	# 選択されたデータを、さらに上位のゲームロジックに伝える
	upgrade_selected.emit(data)
	get_tree().paused = false
	# 役目が終わったので、自分自身をシーンから削除する
	queue_free()
