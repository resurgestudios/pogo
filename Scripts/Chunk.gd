extends Node2D

var tcode2obj = {
	0 : "res://Scenes/Blocks/GroundTile.tscn",
	1 : "res://Scenes/Blocks/GroundTileUnder.tscn",
	2 : "res://Scenes/Blocks/Platform.tscn",
}
var highest = 0
var lowest = 0

func tile_setup():
#	for i in $Tiles.get_children():
#		i.position -= Vector2(32, 32)
	
	for i in $TileMap.get_used_cells():
		var tile_num = $TileMap.get_cellv(i)
		if tile_num in [0, 1, 2]:
			var rects = [Rect2(0, 0, 32, 32), Rect2(32, 0, 32, 32), Rect2(64, 0, 32, 32)]
			var inst = Global.instance_scene(tcode2obj[0], $Tiles, $TileMap.map_to_world(i) * Vector2(2, 2) +  global_position + Vector2(32, 32))
			inst.get_node("Sprite").region_rect = rects[tile_num]
		elif tile_num in [3, 4, 5]:
			var rects = [Rect2(0, 32, 32, 16), Rect2(32, 32, 32, 16), Rect2(64, 32, 32, 16)]
			var inst = Global.instance_scene(tcode2obj[1], $Tiles, $TileMap.map_to_world(i) * Vector2(2, 2) +  global_position + Vector2(32, 16))
			inst.get_node("Sprite").region_rect = rects[tile_num - 3]
		
		elif tile_num == 6:
			var inst = Global.instance_scene(tcode2obj[2], $Tiles, $TileMap.map_to_world(i) * Vector2(2, 2) +  global_position + Vector2(32, 16))
			
		highest = max($TileMap.map_to_world(i).y * 2, highest)
		lowest = min($TileMap.map_to_world(i).y * 2, lowest)
		
		$TileMap.visible = false
