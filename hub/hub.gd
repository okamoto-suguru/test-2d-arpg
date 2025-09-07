# Hub.gd
extends Node2D

# インスペクターからUpgradeMenu.tscnをセットできるようにする
@export var upgrade_menu_scene: PackedScene
@export var hub_bgm: AudioStream
@onready var upgrade_npc = $UpgradeNPC # シーン内のNPCノードへの参照


func _ready():
	# NPCからのメニュー表示要求を受け取る
	upgrade_npc.request_upgrade_menu.connect(_on_request_upgrade_menu)
	SoundManager.play_bgm(hub_bgm)

func _on_request_upgrade_menu():
	# メニューをインスタンス化してシーンに追加
	var menu_instance = upgrade_menu_scene.instantiate()
	add_child(menu_instance)
	
	# メニューのclose_menuシグナルを受け取ったら、メニューを破棄する
	menu_instance.close_menu.connect(menu_instance.queue_free)
