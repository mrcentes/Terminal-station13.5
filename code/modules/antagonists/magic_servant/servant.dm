/datum/antagonist/magic_servant
	name = "\improper 魔法之仆"
	show_in_roundend = FALSE
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE

/datum/antagonist/magic_servant/proc/setup_master(mob/M)
	var/datum/objective/O = new("服侍[M.real_name].")
	O.owner = owner
	objectives |= O

/datum/antagonist/magic_servant/greet()
	. = ..()
	owner.announce_objectives()
