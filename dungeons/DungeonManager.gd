extends Node

# インスペクターからダンジョンの設計図(.tres)を設定
@export var dungeon_data: DungeonData
@export var battle_bgm: AudioStream

# UpgradeManagerへの参照
@onready var upgrade_manager = %TemporaryUpgradeManager
@onready var dungeon_layer = %DungeonLayer
@onready var dungeon_ysort_layer = %DungeonYsortLayer
@onready var dungeon_ground_layer = %DungeonGroundLayer

# 現在の部屋のインスタンスを保持
var current_room_instance: Room
# この挑戦で攻略する、シャッフル済みの部屋リスト
var shuffled_rooms: Array[RoomData]
# 現在何番目の部屋か
var current_room_index: int = -1
var is_run_over: bool = false # この挑戦が終わったかどうかのフラグ

func _ready():
	# UpgradeManagerが選択を終えたら、次の部屋へ進むように接続
	upgrade_manager.selection_finished.connect(spawn_next_room)
	GameEvents.player_died.connect(_on_player_died)
	# ダンジョンを開始
	start_dungeon()


# ダンジョンの挑戦を開始する
func start_dungeon():
	is_run_over = false
	# 利用可能な部屋のリストをコピーしてシャッフル
	shuffled_rooms = dungeon_data.rooms.duplicate()
	shuffled_rooms.shuffle()
	
	current_room_index = -1
	SoundManager.play_bgm(battle_bgm)
	spawn_next_room()

func clear_current_room_visuals():
	# "current_room_visuals" グループに属するすべてのノードを取得して削除
	for node in get_tree().get_nodes_in_group("current_room_visuals"):
		node.queue_free()

# 次の部屋を生成し、表示する
func spawn_next_room():
	# 古い部屋があれば、安全に削除
	if is_instance_valid(current_room_instance):
		current_room_instance.queue_free()
	# 古い部屋のビジュアル部分（壁やオブジェクトなど）をグループ指定で一括削除
	clear_current_room_visuals()
	
	current_room_index += 1
	
	var room_data_to_spawn: RoomData
	
	# ボス部屋までの部屋数をクリアしていたらボス部屋へ
	if current_room_index >= dungeon_data.rooms_before_boss:
		# さらに、ボス部屋もクリアしていたらダンジョンクリア
		if current_room_index > dungeon_data.rooms_before_boss:
			print("ダンジョンクリア！")
			# ここに拠点に戻る処理などを記述
			SoundManager.stop_bgm() # BGMを停止
			PlayerData.save_game()
			get_tree().change_scene_to_file("res://hub/hub.tscn")
			return
		
		room_data_to_spawn = dungeon_data.boss_room
		print("ボス部屋へ！")
	else:
		# シャッフルされたリストから次の部屋を選ぶ
		room_data_to_spawn = shuffled_rooms[current_room_index]
	
	# Roomシーンをインスタンス化 (RMに登録しておくこと)
	var room_scene = RM.room_scene.instantiate() as Room
	# Roomに部屋データを設定
	room_scene.room_data = room_data_to_spawn
	if room_data_to_spawn.layout_scene:
		var layout_instance = room_data_to_spawn.layout_scene.instantiate()
		# ロジックシーンの子として、見た目を追加する
		room_scene.add_child(layout_instance)
		# ノードを取得
		var ground_node = layout_instance.get_node("ground")
		var wall_node = layout_instance.get_node("wall")
		var object_node = layout_instance.get_node("object")
		
		# 元の親から削除
		layout_instance.remove_child(ground_node)
		layout_instance.remove_child(wall_node)
		layout_instance.remove_child(object_node)

		# ▼▼▼ 修正点2: 新しいオブジェクトをグループに追加する ▼▼▼
		# groundをDungeonLayerに追加し、グループにも追加
		dungeon_ground_layer.add_child(ground_node)
		ground_node.add_to_group("current_room_visuals")
		
		# wallをDungeonYsortLayerに追加し、グループにも追加
		dungeon_ysort_layer.add_child(wall_node)
		wall_node.add_to_group("current_room_visuals")
		
		# objectをDungeonYsortLayerに追加し、グループにも追加
		dungeon_ysort_layer.add_child(object_node)
		object_node.add_to_group("current_room_visuals")
		
		# layout_instance.queue_free()
	dungeon_ground_layer.add_child(room_scene)
	current_room_instance = room_scene
	# 部屋がクリアされたら、このDungeonManagerの_on_room_clearedを呼び出す
	current_room_instance.room_cleared.connect(_on_room_cleared)


# 部屋がクリアされた時に呼ばれる
func _on_room_cleared():
	if is_run_over: return
	# ボス部屋だった場合は、アップグレード選択なしで次の処理（ダンジョンクリア）へ
	if current_room_index >= dungeon_data.rooms_before_boss:
		print("ダンジョンクリア！拠点に戻ります。")
		PlayerData.save_game()
		get_tree().change_scene_to_file("res://hub/hub.tscn") # 拠点シーンのパス
		return
		
	# アップグレード選択を開始するよう依頼
	upgrade_manager.start_upgrade_selection()

# プレイヤーが死亡した時に呼ばれる関数
func _on_player_died():
	# 挑戦終了フラグを立てる
	is_run_over = true
	SoundManager.stop_bgm()
	# 拠点に戻る処理はDungeonManagerが一元管理する
	PlayerData.save_game()
	get_tree().change_scene_to_file("res://hub/hub.tscn")
