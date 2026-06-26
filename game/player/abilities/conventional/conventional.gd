extends Ability

@export var time_between_quests: float = 2

var active_quest: Quest
var unavailable_quests: Array[Quest] = []
var recent_quests: Array[Quest] = []
var level_ended = true

func _ready() -> void:
	_type = Enum.EUMLING_TYPE.CONVENTIONAL
	super()

func _process(_delta: float) -> void:
	if amt_eumlings == 0:
		return
	if active_quest:
		active_quest.process(_delta)

func _update():
	if amt_eumlings == 0:
		#disable everything
		_end_quest()
		_reset_possible_quests()
		return
	

func level_start() -> void:
	level_ended = false
	if amt_eumlings == 0: return
	_reset_possible_quests()
	_start_quest()

func _reset_possible_quests():
	unavailable_quests.clear()

func _start_quest() -> void:
	if level_ended: return
	if active_quest:
		_end_quest()
	active_quest = _select_next_quest()
	if not active_quest: return
	active_quest.level = amt_eumlings

	active_quest.progress.connect(_quest_progress)
	active_quest.completed.connect(_quest_complete)
	active_quest.failed.connect(_quest_failed)


	if not active_quest.can_be_repeated:
		unavailable_quests.append(active_quest)
	
	%QuestIcon.texture = active_quest.icon
	%QuestLabel.text = active_quest.text

	%QuestProgressLabel.text = ""
	%QuestProgressBar.max_value = 1
	%QuestProgressBar.value = 0

	%QuestDisplay.show()

	active_quest.start()

func _end_quest() -> void:
	if not active_quest: return
	active_quest.abort()

	recent_quests.push_front(active_quest)
	recent_quests.resize(2)

	active_quest.progress.disconnect(_quest_progress)
	active_quest.completed.disconnect(_quest_complete)
	active_quest.failed.disconnect(_quest_failed)

	active_quest = null
	%QuestDisplay.hide()

func _select_next_quest() -> Quest:
	var possible_quests: Array[Quest]
	for quest in get_children():
		if not quest is Quest: continue
		if unavailable_quests.has(quest): continue
		if recent_quests.has(quest): continue
		if not quest.precondition_is_met(): continue
		possible_quests.append(quest)
	
	# prevent stalling of no quests if there are only two quest left to do.
	if possible_quests.is_empty():
		if recent_quests.is_empty():
			return null
		recent_quests.clear()
		return _select_next_quest()
	return possible_quests.pick_random()

func _quest_progress(value: float, maximum: float):
	%QuestProgressLabel.text = "%d / %d" % [value, maximum]
	%QuestProgressBar.max_value = maximum
	%QuestProgressBar.value = value

func _quest_complete() -> void:
	_end_quest()
	await get_tree().create_timer(time_between_quests).timeout
	_start_quest()

func _quest_failed() -> void:
	_end_quest()
	await get_tree().create_timer(time_between_quests).timeout
	_start_quest()


func level_completed() -> void:
	level_ended = true
	_end_quest()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_abort_quest"):
		_quest_failed()
