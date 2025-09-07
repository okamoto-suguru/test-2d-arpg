# EnemyIdleState.gd
extends State

@onready var detection_area: Area2D = owner.get_node("DetectionArea")
var target = null

func _ready():
	# 索敵範囲に何かが入ってきたら、_on_body_enteredを呼び出す
	detection_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# 侵入してきたのがPlayerなら、Chase状態に遷移する
	if body.is_in_group("player"):
		# 次のStateにターゲット（Player）情報を渡す
		finished.emit("Chase", {"target": body})
