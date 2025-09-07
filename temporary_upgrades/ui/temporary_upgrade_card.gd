# TemporaryUpgradeCard.gd
extends PanelContainer

# このカードが選択されたことを知らせるシグナル
signal selected(temporary_upgrade_data)

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var description_label: Label = $VBoxContainer/DescriptionLabel
@onready var select_button: Button = $VBoxContainer/SelectButton

# このカードが持つ一時強化データを保持する変数
var temporary_upgrade_data: TemporaryUpgradeData

func _ready():
	select_button.pressed.connect(_on_select_button_pressed)

# 外部からデータを設定し、表示を更新する関数
func set_data(data: TemporaryUpgradeData):
	temporary_upgrade_data = data
	name_label.text = temporary_upgrade_data.upgrade_name
	description_label.text = temporary_upgrade_data.description

func _on_select_button_pressed():
	# 選択されたデータを添えて、シグナルを発信する
	selected.emit(temporary_upgrade_data)
