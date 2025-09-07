# Enemy.gd
extends CharacterBase

@export var health_bar_scene: PackedScene
var health_bar_instance

func _ready():
	super._ready()
	# Hurtboxのhitシグナルを、このスクリプトの_on_hurtbox_hit関数に接続
	$Hurtbox.hit.connect(_on_hurtbox_hit)
	
	# HPバーをインスタンス化
	if health_bar_scene:
		health_bar_instance = health_bar_scene.instantiate()
		# 常に手前に表示されるように、CanvasLayerに追加するのが良い
		get_tree().get_first_node_in_group("hud_canvas").add_child(health_bar_instance)
		# HPバーに自分自身をターゲットとして設定
		health_bar_instance.initialize.call_deferred(self)

func take_damage(damage_amount: int, hit_sfx: AudioStream, is_critical: bool):
	super.take_damage(damage_amount, hit_sfx, false)
	
	# HPバーが存在すれば、更新を指示する
	if is_instance_valid(health_bar_instance):
		health_bar_instance.update_value(current_health, stats.max_health)

# Hurtboxが攻撃を受けたら呼ばれる関数
func _on_hurtbox_hit(hitbox):
	take_damage(hitbox.get_damage(),hitbox.sfx_hit, false)

func die():
	super.die()
	# シングルトンからシーンを直接参照してインスタンス化
	var orb_instance = RM.karma_orb_scene.instantiate()
	orb_instance.get_node(".").karma_value = stats.karma_drop_amount
	get_tree().current_scene.add_child(orb_instance)
	orb_instance.global_position = self.global_position
	queue_free() # 敵は消える
