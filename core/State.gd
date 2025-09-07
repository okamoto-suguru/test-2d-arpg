# This is a base class for all states.
class_name State extends Node

# The state machine is the parent node.
@onready var state_machine: StateMachine
@onready var sprite: AnimatedSprite2D = owner.get_node("CharacterSprite")

# このStateが他アクションで中断可能かどうかのフラグ
var can_be_interrupted: bool = true

# Emitted when the state is finished to transition to the next state.
# The state machine connects to this signal.
# We pass the name of the next state as a string.
signal finished(next_state_name: String)


## Called by the state machine when the state is entered.
func enter(_previous_state_name: String, _data: Dictionary = {}) -> void:
	pass


## Called by the state machine when the state is exited.
func exit() -> void:
	pass


## Called by the state machine's _unhandled_input callback.
func handle_input(_event: InputEvent) -> void:
	pass


## Called by the state machine's _process callback.
func update(_delta: float) -> void:
	pass


## Called by the state machine's _physics_process callback.
func physics_update(_delta: float) -> void:
	pass

## 指定したアニメーションの再生速度を、指定した秒数で終わるように調整する
func sync_animation_to_duration(anim_name: String, duration: float) -> void:
	var sprite_frames: SpriteFrames = sprite.sprite_frames
	var frame_count = sprite_frames.get_frame_count(anim_name)
	var anim_speed = sprite_frames.get_animation_speed(anim_name)
	
	if anim_speed > 0 and duration > 0:
		var anim_duration = frame_count / anim_speed
		sprite.speed_scale = anim_duration / duration
	sprite.play(anim_name)

## アニメーションの再生速度を通常に戻す
func reset_animation_speed() -> void:
	sprite.speed_scale = 2.0
