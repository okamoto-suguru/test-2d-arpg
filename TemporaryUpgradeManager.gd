# UpgradeManager.gd
extends Node
signal selection_finished

# インスペクターから、作成した全ての.tresファイルをドラッグ&ドロップする
@export var all_upgrades: Array[TemporaryUpgradeData]
# 強化選択UIのシーンをセットする
@export var upgrade_screen_scene: PackedScene
@onready var player = %Player # Playerノードへの参照

# 外部から呼ばれる、アップグレード選択を開始する関数
func start_upgrade_selection():
	# 3つ以上のアップグレードデータがない場合は何もしない
	if all_upgrades.size() < 3:
		printerr("アップグレードデータが3つ未満です。")
		return

	# 全データの中から、重複しないように3つをランダムに選ぶ
	var choices: Array[TemporaryUpgradeData] = []
	var available_upgrades = all_upgrades.duplicate()
	available_upgrades.shuffle()
	for i in range(3):
		choices.append(available_upgrades.pop_front())
	
	# ゲームをポーズする
	get_tree().paused = true
	# UIをインスタンス化してシーンに追加
	var screen_instance = upgrade_screen_scene.instantiate()
	get_tree().root.add_child(screen_instance)
	
	# UIに選択肢を渡して表示
	screen_instance.show_upgrades(choices)
	
	# UIで何かが選択されたら、_on_upgrade_selectedを呼び出す
	screen_instance.upgrade_selected.connect(_on_upgrade_selected)


func _on_upgrade_selected(data: TemporaryUpgradeData):
	print("「%s」が選択されました。" % data.upgrade_name)
	# プレイヤーに効果を適用するよう依頼
	player.apply_temporary_upgrade(data)
	selection_finished.emit()

func _on_trigger_area_body_entered(body):
	if body.is_in_group("player"):
		start_upgrade_selection()
		# トリガーが何度も反応しないように、一度で無効化する
		get_node("../TriggerArea/CollisionShape2D").disabled = true
