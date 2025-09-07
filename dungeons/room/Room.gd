extends Node2D
class_name Room

signal room_cleared

@export var room_data: RoomData
@export var survival_widget_scene: PackedScene

@onready var entry_trigger: Area2D = $EntryTrigger
@onready var enemy_spawn_positions: Node2D = $EnemySpawnPositions

var is_active: bool = false
# --- 敵全滅用 ---
var current_wave_index: int = -1
var wave_timer: Timer
var enemies_left_in_wave: int = 0
# --- サバイバル用 ---
var survival_timer: Timer
var survival_widget_instance

func _process(_delta):
	# サバイバルタイマーが作動中なら、UIの表示を更新する
	if is_active and room_data.victory_condition == RoomData.VictoryCondition.SURVIVE_FOR_TIME:
		if is_instance_valid(survival_widget_instance):
			survival_widget_instance.update_timer(survival_timer.time_left)


func _ready():
	entry_trigger.body_entered.connect(_on_player_entered)
	
	wave_timer = Timer.new()
	add_child(wave_timer)
	wave_timer.one_shot = true
	wave_timer.timeout.connect(start_next_wave)
	
	survival_timer = Timer.new()
	add_child(survival_timer)
	survival_timer.one_shot = true
	survival_timer.timeout.connect(_on_survival_time_end)

func _on_player_entered(body):
	if body.is_in_group("player") and not is_active:
		is_active = true
		entry_trigger.get_node("CollisionShape2D").disabled = true
		print("部屋を開始！")
		match room_data.victory_condition:
			RoomData.VictoryCondition.CLEAR_ALL_ENEMIES:
				print("勝利条件: 敵の全滅")
				start_next_wave()
			RoomData.VictoryCondition.SURVIVE_FOR_TIME:
				print("勝利条件: %d秒間生存" % room_data.survival_time)
				start_survival()

func start_next_wave():
	current_wave_index += 1
	
	if current_wave_index >= room_data.waves.size():
		if is_active:
			print("部屋クリア！")
			room_cleared.emit()
			is_active = false
		return
	print(room_data.waves[current_wave_index])
	var current_wave = room_data.waves[current_wave_index]
	print("ウェーブ %d / %d を開始！" % [current_wave_index + 1, room_data.waves.size()])
	spawn_enemies_for_wave(current_wave)
	
	var next_wave_index = current_wave_index + 1
	if next_wave_index < room_data.waves.size():
		var next_wave_data = room_data.waves[next_wave_index]
		if next_wave_data.trigger == WaveData.TriggerCondition.TIME_ELAPSED:
			wave_timer.start(next_wave_data.trigger_delay)

func spawn_enemies_for_wave(wave_data: WaveData):
	enemies_left_in_wave = wave_data.enemy_spawns.size()
	var spawn_points = enemy_spawn_positions.get_children()
	spawn_points.shuffle()
	
	if wave_data.enemy_spawns.size() > spawn_points.size():
		printerr("敵の数に対してスポーン地点が不足しています！")

	for i in range(wave_data.enemy_spawns.size()):
		if i >= spawn_points.size(): break
		var enemy_scene = wave_data.enemy_spawns[i]
		var spawn_point = spawn_points[i]
		var enemy_instance = enemy_scene.instantiate()
		add_child(enemy_instance)
		enemy_instance.global_position = spawn_point.global_position
		enemy_instance.tree_exited.connect(_on_enemy_defeated)

func _on_enemy_defeated():
	enemies_left_in_wave -= 1
	print("敵が倒された。残り敵数: %d" % enemies_left_in_wave)

	if enemies_left_in_wave <= 0:
		var next_wave_index = current_wave_index + 1
		if next_wave_index < room_data.waves.size():
			var next_wave_data = room_data.waves[next_wave_index]
			if next_wave_data.trigger == WaveData.TriggerCondition.PREVIOUS_WAVE_CLEARED:
				start_next_wave()
		else:
			# これが最後のウェーブだった場合
			start_next_wave()

# --- 「サバイバル」ロジック (新しく追加) ---
func start_survival():
	if survival_widget_scene:
		survival_widget_instance = survival_widget_scene.instantiate()
		get_tree().get_first_node_in_group("hud_canvas").add_child(survival_widget_instance)
	# サバイバルタイマーを開始
	survival_timer.start(room_data.survival_time)
	
	# サバイバル中は、敵を無限にスポーンさせ続ける
	# ここでは簡略化のため、最初のウェーブの敵を使い回す
	# (将来的にはSpawnerを使うのが理想)
	var wave_data = room_data.waves[0]
	spawn_enemies_for_wave(wave_data)

func _on_survival_time_end():
	print("生存成功！部屋クリア！")
	if is_instance_valid(survival_widget_instance):
		survival_widget_instance.queue_free()
	
	# 生き残っている敵を全て削除
	for node in get_children():
		if node is CharacterBase and not node.is_in_group("player"):
			node.queue_free()
			
	room_cleared.emit()
