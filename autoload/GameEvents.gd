# scripts/GameEvents.gd
extends Node

# プレイヤーのHPが更新されたことを知らせる、グローバルな信号
signal player_health_updated(current_health, max_health)
signal player_stats_changed()
signal player_died()
