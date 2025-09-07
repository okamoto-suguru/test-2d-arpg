# InteractableBase.gd
extends Area2D
class_name InteractableBase

@onready var prompt_sprite: Sprite2D = $PromptSprite

# 範囲内にいるプレイヤーを保持する変数
var player_in_range = null

func _ready():
	prompt_sprite.hide()
	# body_entered/exitedシグナルを接続
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta):
	# プレイヤーが範囲内にいて、インタラクトボタンが押されたら
	if player_in_range and Input.is_action_just_pressed("interact"):
		_interact()

# この関数は、子クラスで上書き（オーバーライド）されることを想定
func _interact():
	print("インタラクトしました (基底クラス)")
	pass

func _on_body_entered(body):
	if body.is_in_group("player"):
		prompt_sprite.show()
		player_in_range = body

func _on_body_exited(body):
	if body.is_in_group("player"):
		prompt_sprite.hide()
		player_in_range = null
