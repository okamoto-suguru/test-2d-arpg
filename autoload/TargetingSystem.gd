# autoload/TargetingSystem.gd
extends Node

# どんな種類のターゲット探しも、この一つの関数で受け付けます
func find_targets(caster: CharacterBase, ability_data: AbilityData) -> Array[CharacterBase]:
	var targets_found: Array[CharacterBase] = []
	
	# アビリティのレシピに書かれたTargetTypeに応じて、索敵方法をここで分岐させます
	match ability_data.target_type:
		AbilityData.TargetType.SELF:
			targets_found.append(caster)
			
		AbilityData.TargetType.NEAREST_ENEMY:
			# AbilityDataに索敵半径(radius)の変数を追加する必要があります
			var nearest_enemy = _find_nearest_enemy_in_radius(caster, 500.0) # 半径は仮
			if is_instance_valid(nearest_enemy):
				targets_found.append(nearest_enemy)
		
		AbilityData.TargetType.ENEMIES_IN_RADIUS:
			# AbilityDataに索敵半径(radius)の変数を追加する必要があります
			targets_found = _find_enemies_in_radius(caster, 300.0) # 半径は仮

		# 注意：このケースは、Hitboxが物理的に接触した相手を返すため、
		# 本来はAbilityStateがHitboxのシグナルを直接待ち受けるのが最も正確です。
		# ここでは、簡略化のため最も近い敵を返します。
		AbilityData.TargetType.ENEMIES_IN_HITBOX:
			var nearest_enemy = _find_nearest_enemy_in_radius(caster, 1000.0)
			if is_instance_valid(nearest_enemy):
				targets_found.append(nearest_enemy)

		# ...将来的に、他のターゲティングタイプもここに追加していきます...
			
	return targets_found


# --- 内部で使う、具体的な索敵処理（ヘルパー関数） ---

# 指定された半径内で、最も近い敵を探す
func _find_nearest_enemy_in_radius(caster: Node2D, radius: float) -> CharacterBase:
	var nearest_enemy: CharacterBase = null
	var min_distance_sq: float = INF # 距離の2乗で比較する方が高速

	var space_state = caster.get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = radius
	
	query.shape = circle_shape
	query.transform = Transform2D(0, caster.global_position)
	# 敵のコリジョンレイヤーと衝突するようにマスクを設定 (要調整)
	query.collision_mask = 1 << 2 # レイヤー3 (enemies) を仮定

	var results = space_state.intersect_shape(query)

	for result in results:
		var collider = result.collider
		if collider is CharacterBase and not collider.is_in_group("player"):
			var distance_sq = caster.global_position.distance_squared_to(collider.global_position)
			if distance_sq < min_distance_sq:
				min_distance_sq = distance_sq
				nearest_enemy = collider
				
	return nearest_enemy

# 指定された半径内の、全ての敵を探す
func _find_enemies_in_radius(caster: Node2D, radius: float) -> Array[CharacterBase]:
	var enemies_found: Array[CharacterBase] = []
	
	var space_state = caster.get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = radius
	
	query.shape = circle_shape
	query.transform = Transform2D(0, caster.global_position)
	query.collision_mask = 1 << 2 # レイヤー3 (enemies) を仮定

	var results = space_state.intersect_shape(query)
	
	for result in results:
		var collider = result.collider
		if collider is CharacterBase and not collider.is_in_group("player"):
			enemies_found.append(collider)
			
	return enemies_found
