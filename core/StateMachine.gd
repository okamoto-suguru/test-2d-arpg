class_name StateMachine extends Node

## 状態が切り替わった直後に発信される
signal state_changed()

## 状態遷移直後の入力を無視するためのフラグ
var can_process_input := true

## エディタから初期状態を設定可能にする
@export var initial_state: State

## 現在アクティブなState
@onready var state: State = initial_state if initial_state else get_child(0)


func _ready() -> void:
	# このStateMachine配下の全ての子孫Stateに、自身への参照を渡す
	for state_node: State in find_children("*", "State", true, false):
		state_node.state_machine = self
		# finishedシグナルは、トップレベルの遷移にのみ使用
		if state_node.get_parent() == self:
			state_node.finished.connect(_transition_to_next_state)
	
	await owner.ready
	state.enter("")


func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)


func _process(delta: float) -> void:
	state.update(delta)


func _physics_process(delta: float) -> void:
	state.physics_update(delta)


func _transition_to_next_state(target_state_name: String, data: Dictionary = {}) -> void:
	var target_state = get_node_or_null(target_state_name)

	if not target_state:
		printerr(owner.name + ": Trying to transition to state '" + target_state_name + "' but it does not exist as a direct child of the StateMachine.")
		return

	var previous_state_name := state.name
	print("Top-Level State Change: %s -> %s" % [previous_state_name, target_state_name])

	state.exit()
	state = target_state

	can_process_input = false
	state.enter(previous_state_name, data)
	# 0.1秒後に再び入力を受け付ける
	await get_tree().create_timer(0.1).timeout
	can_process_input = true
	
	state_changed.emit()
