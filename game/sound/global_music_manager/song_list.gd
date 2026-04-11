class_name SongList extends Node

enum TRACK {
	MENU = 0, 
	COMBAT_FOREST = 1, 
	COMBAT_ISLAND = 2,
	COMBAT_VOLCANO = 8,
	BOSS_GENERIC = 3,
	BOSS_ISLAND = 4, 
	BOSS_VOLCANO = 5,
	CHASE = 6,
	GAMBA = 7
}
enum ENVNOISE {
	FOREST,
	ISLAND,
	VOLCANO
}
static var tracks:Dictionary[TRACK, Array] = {
	TRACK.MENU :["res://assets/sound/music/menu.tres", null],
	TRACK.COMBAT_FOREST:["res://assets/sound/music/combat_forest.tres",ENVNOISE.FOREST], 
	TRACK.COMBAT_ISLAND:["res://assets/sound/music/combat_island.tres", ENVNOISE.ISLAND],
	TRACK.COMBAT_VOLCANO:["res://assets/sound/music/combat_volcano.tres", ENVNOISE.VOLCANO],
	TRACK.BOSS_GENERIC:["res://assets/sound/music/boss_generic.tres", ENVNOISE.FOREST],
	TRACK.BOSS_ISLAND:["res://assets/sound/music/boss_island.tres", ENVNOISE.ISLAND], 
	TRACK.BOSS_VOLCANO:["res://assets/sound/music/boss_volcano.tres", ENVNOISE.VOLCANO],
	TRACK.CHASE:["res://assets/sound/music/chase.tres", null],
	TRACK.GAMBA:["res://assets/sound/music/gamba.tres", null]
}
static var envnoises:Dictionary[ENVNOISE,String] = {
	ENVNOISE.FOREST:"res://assets/sound/environment_noise/Env_Forest.ogg",
	ENVNOISE.ISLAND:"res://assets/sound/environment_noise/Env_Island.ogg",
	ENVNOISE.VOLCANO:"res://assets/sound/environment_noise/Env_Volcano.ogg"
}
static func get_noise_of_song(song:TRACK) -> int:
	var noise = tracks[song][1]
	if noise!= null:
		return noise
	else:
		return -1 
	
static func get_noise_resource(noise:ENVNOISE) -> AudioStream:
	var res:AudioStream

	var path:String = envnoises[noise]
	res = load(path)
	return res

static func get_song_resource(song:TRACK) -> AudioStreamInteractive:
	var path:String = tracks[song][0]
	var res:AudioStreamInteractive = load(path)
	return res
