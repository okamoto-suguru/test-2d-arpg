# HealthBar.gd
extends BaseResourceBar

func _ready():
	# HP更新のラジオ放送を聴く
	GameEvents.player_health_updated.connect(update_value)
