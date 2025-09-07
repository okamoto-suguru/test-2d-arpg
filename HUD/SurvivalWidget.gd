# ui/SurvivalWidget.gd
extends Control

@onready var message_label: Label = $VBoxContainer/MessageLabel
@onready var timer_label: Label = $VBoxContainer/TimerLabel

# 残り時間を更新する関数
func update_timer(time_left: float):
	# 小数点以下を切り捨てて表示
	timer_label.text = str(int(time_left))
