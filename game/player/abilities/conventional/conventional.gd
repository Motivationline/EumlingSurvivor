extends Ability

@export var time_between_quests: float = 2

var active_quest: Quest
var unavailable_quests: Array[Quest] = []

func _ready() -> void:
	_type = Enum.EUMLING_TYPE.CONVENTIONAL
	super()

func _process(_delta: float) -> void:
	if amt_eumlings == 0:
		return
	if active_quest:
		active_quest.process()

func _update():
	if amt_eumlings == 0:
		#disable everything
		_end_quest()
		_reset_possible_quests()
		return
	# TODO remove this, as usually an eumling would be unlocked AFTER the level ends.
	# And then you don't need to start a quest, but it's here for debug for now.
	_start_quest()
	

func level_start() -> void:
	if amt_eumlings == 0: return
	_reset_possible_quests()
	_start_quest()

func _reset_possible_quests():
	unavailable_quests.clear()

func _start_quest() -> void:
	if active_quest:
		_end_quest()
	active_quest = _select_next_quest()

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

	active_quest.progress.disconnect(_quest_progress)
	active_quest.completed.disconnect(_quest_complete)
	active_quest.failed.disconnect(_quest_failed)

	active_quest = null
	%QuestDisplay.hide()

func _select_next_quest() -> Quest:
	# TODO add check to prevent repeats for 2 quests
	var possible_quests: Array[Quest]
	for quest in get_children():
		if not quest is Quest: continue
		if unavailable_quests.has(quest): continue
		if quest.precondition_is_met():
			possible_quests.append(quest)
	
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
	_end_quest()
