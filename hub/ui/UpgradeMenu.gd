# UpgradeMenu.gd
extends Control

# メニューが閉じられたことを親（Hub）に知らせるためのシグナル
signal close_menu

@onready var karma_label: Label = $PanelContainer/VBoxContainer/KarmaLabel
@onready var upgrade_button: Button = $PanelContainer/VBoxContainer/UpgradeButton
@onready var close_button: Button = $PanelContainer/VBoxContainer/CloseButton

var upgrade_cost: int = 10

func _ready():
	# ボタンのシグナルを接続
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	# 最初に表示を更新
	update_display()

# 表示を更新する関数
func update_display():
	karma_label.text = "現在のカルマ: %d" % PlayerData.karma
	upgrade_button.text = "攻撃力を強化 (コスト: %d)" % upgrade_cost
	# カルマが足りなければボタンを無効化
	upgrade_button.disabled = PlayerData.karma < upgrade_cost

# 強化ボタンが押された時の処理
func _on_upgrade_button_pressed():
	if PlayerData.karma >= upgrade_cost:
		PlayerData.karma -= upgrade_cost
		PlayerData.attack_level += 1
		print("攻撃力を強化しました！ 現在の攻撃レベル: %d" % PlayerData.attack_level)
		GameEvents.player_stats_changed.emit()
		# 表示を更新
		update_display()

# 閉じるボタンが押された時の処理
func _on_close_button_pressed():
	close_menu.emit()
