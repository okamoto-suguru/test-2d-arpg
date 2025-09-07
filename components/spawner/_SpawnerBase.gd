# components/spawner/Spawner.gd
extends Node2D
class_name Spawner

signal wave_cleared # このスポナーの仕事が終わったことを知らせる

@export var enemy_scene: PackedScene
# --- スポーンのルールを定義する変数 ---
@export var spawn_count: int = 1 # 何体スポーンさせるか (0なら無限)
@export var interval: float = 1.0 # スポーン間隔
@export var max_on_screen: int = 5 # 画面上の最大数

var spawn_timer: Timer
var spawned_enemies: Array[Node] = []
var spawn_counter: int = 0

func _ready():
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.wait_time = interval
	spawn_timer.timeout.connect(spawn_enemy)

# スポーンを開始する
func start():
	spawn_timer.start()

func spawn_enemy():
	# --- 有限スポーンの終了判定 ---
	if spawn_count > 0 and spawn_counter >= spawn_count:
		spawn_timer.stop()
		return

	# --- 無限スポーンの数制限 ---
	spawned_enemies = spawned_enemies.filter(func(e): return is_instance_valid(e))
	if spawned_enemies.size() < max_on_screen:
		var enemy = enemy_scene.instantiate()
		get_parent().add_child(enemy)
		enemy.global_position = self.global_position
		enemy.tree_exited.connect(_on_enemy_defeated)
		spawned_enemies.append(enemy)
		spawn_counter += 1

func _on_enemy_defeated():
	# 有限スポーンの場合、最後の1体が倒されたらクリア信号を出す
	if spawn_count > 0:
		spawned_enemies = spawned_enemies.filter(func(e): return is_instance_valid(e))
		if spawn_counter >= spawn_count and spawned_enemies.is_empty():
			wave_cleared.emit()
