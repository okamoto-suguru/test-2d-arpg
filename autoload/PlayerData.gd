# autoload/PlayerData.gd
extends Node

# --- ここからがセーブ対象となるデータ ---
# @exportを付けておくだけで、自動的にセーブされるようになります
@export var karma: int = 0
@export var attack_level: int = 0
# 将来的に、@export var health_level: int = 0 などを追加していくだけでOK
# --- ここまで ---


const SAVE_PATH = "user://savegame.dat"

func _ready():
	load_game()

# --- ここからが自動セーブ＆ロードのロジック ---

# ゲームをセーブする関数
func save_game():
	var save_data = {}
	# このスクリプトが持つプロパティのリストを取得
	for property in get_script().get_script_property_list():
		# @exportされた変数（保存すべき変数）のみを対象とする
		if property.usage & PROPERTY_USAGE_STORAGE:
			var prop_name = property.name
			# その変数の現在の値を取得して、辞書に追加
			save_data[prop_name] = get(prop_name)
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(save_data)
	file.close()
	print("ゲームをセーブしました。 (自動)")

# ゲームをロードする関数
func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var save_data = file.get_var()
	file.close()
	
	if save_data is Dictionary:
		# セーブデータの辞書をループし、キー（変数名）と値を使って復元
		for key in save_data:
			var value = save_data[key]
			# set()関数を使って、このスクリプトの同名の変数に値を設定
			set(key, value)
		print("ゲームをロードしました。 (自動)")
		
func add_karma(amount: int):
	karma += amount
	print("カルマを %d 獲得！ 現在の合計: %d" % [amount, karma])
