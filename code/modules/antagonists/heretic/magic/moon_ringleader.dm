/datum/action/cooldown/spell/aoe/moon_ringleader
	name = "剧团长的登台"
	desc = "大范围的AoE法术，对范围内的所有人造成脑损伤和幻觉.\
			目标理智越少，效果越好. \
			如果目标理智足够低，他们会陷入疯狂，而这个法术能进一步减少他们的理智."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "moon_ringleader"
	sound = 'sound/effects/moon_parade.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 1 MINUTES

	invocation = "R''S 'E"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	aoe_radius = 5
	/// Effect for when the spell triggers
	var/obj/effect/moon_effect = /obj/effect/temp_visual/moon_ringleader

/datum/action/cooldown/spell/aoe/moon_ringleader/cast(mob/living/caster)
	new moon_effect(get_turf(caster))
	return ..()

/datum/action/cooldown/spell/aoe/moon_ringleader/get_things_to_cast_on(atom/center, radius_override)
	var/list/stuff = list()
	var/list/o_range = orange(center, radius_override || aoe_radius) - list(owner, center)
	for(var/mob/living/carbon/nearby_mob in o_range)
		if(nearby_mob.stat == DEAD)
			continue
		if(!nearby_mob.mob_mood)
			continue
		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		if(nearby_mob.can_block_magic(antimagic_flags))
			continue

		stuff += nearby_mob

	return stuff

/datum/action/cooldown/spell/aoe/moon_ringleader/cast_on_thing_in_aoe(mob/living/carbon/victim, mob/living/caster)
	var/victim_sanity = victim.mob_mood.sanity

	victim.adjustOrganLoss(ORGAN_SLOT_BRAIN, 100 - victim_sanity, 160)
	for(var/i in 1 to round((120 - victim_sanity) / 10))
		victim.cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/body), name)
	if(victim_sanity < 15)
		victim.apply_status_effect(/datum/status_effect/moon_converted)
		caster.log_message("made [victim] insane.", LOG_GAME)
		victim.log_message("was driven insane by [caster]")
	victim.mob_mood.set_sanity(victim_sanity * 0.5)


/obj/effect/temp_visual/moon_ringleader
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "ring_leader_effect"
	alpha = 180
	duration = 6

/obj/effect/temp_visual/moon_ringleader/ringleader/Initialize(mapload)
	. = ..()
	transform = transform.Scale(10)
