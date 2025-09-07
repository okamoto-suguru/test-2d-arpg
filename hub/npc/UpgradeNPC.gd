# UpgradeNPC.gd
extends InteractableBase

signal request_upgrade_menu

# _interact()の処理だけを記述する
func _interact():
	print("強化メニューを開きます...")
	request_upgrade_menu.emit()
	# ここに、以前作ったHubのUIを開く処理を記述する
