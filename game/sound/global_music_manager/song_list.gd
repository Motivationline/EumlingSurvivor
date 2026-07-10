class_name SongList extends Node

enum TRACK {
	NOTHING = 13,
	MENU = 0, 
	COMBAT_FOREST = 1, 
	COMBAT_ISLAND = 2,
	COMBAT_VOLCANO = 8,
	COMBAT_FLOWERS = 9,
	COMBAT_SHROOMS = 10,
	COMBAT_MOUNTAIN = 12,
	BOSS_GENERIC = 3,
	BOSS_ISLAND = 4, 
	BOSS_VOLCANO = 5,
	BOSS_MOUNTAIN = 15,
	CHASE = 6,
	GAMBA = 7,
	TITLE = 11,
	TUTORIAL = 14,
}
enum ENVNOISE {
	NOTHING  = 0,
	FOREST = 1,
	ISLAND = 2,
	VOLCANO = 3,
	FLOWERS = 4,
	MUSHROOMS = 5,
	MOUNTAIN = 6
}
static var tracks:Dictionary[TRACK, Array] = {
	TRACK.MENU :["res://assets/sound/music/menu.tres", ENVNOISE.NOTHING],
	TRACK.COMBAT_FOREST:["res://assets/sound/music/combat_forest.tres",ENVNOISE.FOREST], 
	TRACK.COMBAT_ISLAND:["res://assets/sound/music/combat_island.tres", ENVNOISE.ISLAND],
	TRACK.COMBAT_VOLCANO:["res://assets/sound/music/combat_volcano.tres", ENVNOISE.VOLCANO],
	TRACK.COMBAT_FLOWERS:["res://assets/sound/music/combat_flowers.tres",ENVNOISE.FLOWERS],
	TRACK.COMBAT_MOUNTAIN:["res://assets/sound/music/combat_mountain.tres",ENVNOISE.MOUNTAIN],
	TRACK.COMBAT_SHROOMS:["res://assets/sound/music/combat_shrooms.tres",ENVNOISE.MUSHROOMS],
	TRACK.BOSS_GENERIC:["res://assets/sound/music/boss_generic.tres", ENVNOISE.FOREST],
	TRACK.BOSS_ISLAND:["res://assets/sound/music/boss_island.tres", ENVNOISE.ISLAND], 
	TRACK.BOSS_VOLCANO:["res://assets/sound/music/boss_volcano.tres", ENVNOISE.VOLCANO],
	TRACK.BOSS_MOUNTAIN:["res://assets/sound/music/boss_mountain.tres", ENVNOISE.MOUNTAIN],
	TRACK.CHASE:["res://assets/sound/music/chase.tres", ENVNOISE.NOTHING],
	TRACK.GAMBA:["res://assets/sound/music/gamba.tres", ENVNOISE.NOTHING],
	TRACK.TITLE:["res://assets/sound/music/title_theme.tres",ENVNOISE.NOTHING],
	TRACK.TUTORIAL:["res://assets/sound/music/tutorial.tres",ENVNOISE.FLOWERS]
}
static var envnoises:Dictionary[ENVNOISE,String] = {
	ENVNOISE.FOREST:"res://assets/sound/environment_noise/Env_Forest.ogg",
	ENVNOISE.ISLAND:"res://assets/sound/environment_noise/Env_Island.ogg",
	ENVNOISE.VOLCANO:"res://assets/sound/environment_noise/Env_Volcano.ogg",
	ENVNOISE.FLOWERS:"res://assets/sound/environment_noise/Env_Flowers.ogg",
	ENVNOISE.MUSHROOMS:"res://assets/sound/environment_noise/Env_Mushrooms.ogg",
	ENVNOISE.MOUNTAIN:"res://assets/sound/environment_noise/Env_Mountain.ogg"
}
static func get_noise_of_song(song:TRACK) -> int:
	var noise = tracks[song][1]
	if noise!= null:
		return noise
	else:
		return -1 
	
static func get_noise_resource(noise:ENVNOISE) -> AudioStream:
	if noise == ENVNOISE.NOTHING:
		return
	var res:AudioStream

	var path:String = envnoises[noise]
	res = load(path)
	return res

static func get_song_resource(song:TRACK) -> Song:
	var path:String = tracks[song][0]
	var res:Song = load(path)
	return res
