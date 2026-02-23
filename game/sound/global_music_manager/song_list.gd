class_name SongList extends Node

enum TRACK {
	MENU, 
	COMBAT_ISLAND,
	COMBAT_FOREST, 
	BOSS_GENERIC,
	BOSS_ISLAND, 
	CHASE,
	GAMBA
}

static var tracks:Dictionary[TRACK, String] = {
	TRACK.MENU :"res://assets/sound/music/menu.tres",
	TRACK.COMBAT_ISLAND:"res://assets/sound/music/combat_island.tres",
	TRACK.COMBAT_FOREST:"res://assets/sound/music/combat_forest.tres", 
	TRACK.BOSS_GENERIC:"res://assets/sound/music/boss_generic.tres",
	TRACK.BOSS_ISLAND:"res://assets/sound/music/boss_island.tres", 
	TRACK.CHASE:"res://assets/sound/music/chase.tres",
	TRACK.GAMBA:"res://assets/sound/music/gamba.tres"
}


#TODO Dictionary
static func get_song_resource(_song:TRACK) -> AudioStreamInteractive:
	var path:String = tracks[_song]
	var res:AudioStreamInteractive = load(path)
	return res
