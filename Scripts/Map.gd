extends TileMap
class_name Map


func get_tilev(position: Vector2) -> Vector2:
	var local_position = self.to_local(position)
	var map_position = self.world_to_map(local_position)
	return map_position

func get_tile_name(position: Vector2) -> String:
	var map_position = get_tilev(position)
	var cell = self.get_cellv(map_position)
	if cell == INVALID_CELL:
		return ''
	return self.tile_set.tile_get_name(cell)
