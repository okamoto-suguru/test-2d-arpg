# autoload/SoundManager.gd
extends Node

# --- 効果音管理 ---
# 効果音プレイヤーの「プール（溜まり場）」を配列として用意
var sfx_player_pool: Array[AudioStreamPlayer]
# 同時に鳴らせる効果音の最大数
@export var sfx_pool_size: int = 12

# --- BGM管理 ---
# BGM用のプレイヤー
var bgm_player: AudioStreamPlayer


func _ready():
	# --- SFXプレイヤーのプールを生成 ---
	# sfx_pool_sizeの数だけ、あらかじめプレイヤーを生成しておく
	for i in range(sfx_pool_size):
		var player = AudioStreamPlayer.new()
		sfx_player_pool.append(player)
		add_child(player)
	
	# --- BGMプレイヤーを生成 ---
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)


# --- グローバル関数 ---

## 効果音を再生する
func play_sfx(sound: AudioStream):
	if not sound: return

	# プールの中から、現在再生中でないプレイヤーを探す
	for player in sfx_player_pool:
		if not player.playing:
			# 空いているプレイヤーが見つかったら、それで音を鳴らして処理を終える
			player.stream = sound
			player.play()
			return
	
	# もし全てのプレイヤーが使用中なら、今回は音を鳴らさない
	# print("効果音プレイヤーの空きがありませんでした。")


## BGMを再生する
func play_bgm(music: AudioStream, fade_in_time: float = 1.0):
	if not music: return
	
	# 現在のBGMと同じなら何もしない
	if bgm_player.stream == music and bgm_player.playing:
		return
		
	bgm_player.stream = music
	bgm_player.play()
	# フェードイン処理
	bgm_player.volume_db = -80.0
	var tween = create_tween()
	tween.tween_property(bgm_player, "volume_db", 0, fade_in_time)


## BGMを停止する
func stop_bgm(fade_out_time: float = 1.0):
	var tween = create_tween()
	tween.tween_property(bgm_player, "volume_db", -80.0, fade_out_time)
	# フェードアウトが終わったら再生を停止
	await tween.finished
	bgm_player.stop()
