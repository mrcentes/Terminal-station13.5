/datum/action/changeling/adrenaline
	name = "肾上腺素囊"
	desc = "在我们体内进化出额外的肾上腺素囊，花费30点化学物质."
	helptext = "立即从眩晕中完全恢复，并在短时间内对眩晕产生抗性. 在无意识状态下依然可以使用该能力，但持续使用会毒害身体."
	button_icon_state = "adrenaline"
	chemical_cost = 25 // similar cost to biodegrade, as they serve similar purposes
	dna_cost = 2
	req_human = FALSE
	req_stat = CONSCIOUS
	disabled_by_fire = FALSE

/datum/action/changeling/adrenaline/can_sting(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE

	if(HAS_TRAIT_FROM(user, TRAIT_IGNOREDAMAGESLOWDOWN, CHANGELING_TRAIT))
		user.balloon_alert(user, "already boosted!")
		return FALSE

	return .

//Recover from stuns.
/datum/action/changeling/adrenaline/sting_action(mob/living/carbon/user)
	..()
	to_chat(user, span_changeling("手臂力量变弱，但双腿却涌现力量!"))

	for(var/datum/action/changeling/weapon/weapon_ability in user.actions)
		weapon_ability.unequip_held(user)

	// Destroy legcuffs with our IMMENSE LEG STRENGTH.
	if(istype(user.legcuffed))
		user.visible_message(
			span_warning("[user]用腿撕开了[user.legcuffed]!"),
			span_warning("我们撕开了挂在脚上的束缚物!"),
		)
		qdel(user.legcuffed)

	// Regenerate our legs only.
	var/our_leg_zones = (GLOB.all_body_zones - GLOB.leg_zones)
	user.regenerate_limbs(excluded_zones = our_leg_zones) // why is this exclusive rather than inclusive

	user.add_traits(list(TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM), CHANGELING_TRAIT)

	// Revert above mob changes.
	addtimer(CALLBACK(src, PROC_REF(unsting_action), user), 20 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

	// Get us standing up.
	user.SetAllImmobility(0)
	user.setStaminaLoss(0)
	user.set_resting(FALSE, instant = TRUE)

	// Add fast reagents to go fast.
	user.reagents.add_reagent(/datum/reagent/medicine/changelingadrenaline, 4) //20 seconds

	return TRUE

/datum/action/changeling/adrenaline/proc/unsting_action(mob/living/user)
	to_chat(user, span_changeling("我们的四肢的肌肉重新回到初始的均衡状态."))
	user.remove_traits(list(TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM), CHANGELING_TRAIT)
