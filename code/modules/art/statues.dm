/// This controls the delay for the sculpt rock breaking sound
/// Every 4th iterator while sculpting will emit a sound (rougly every couple of seconds)
#define SCULPT_SOUND_INCREMENT 4

/obj/structure/statue
	name = "雕像"
	desc = "Placeholder. Yell at Firecage if you SOMEHOW see this."
	icon = 'icons/obj/art/statue.dmi'
	icon_state = ""
	density = TRUE
	anchored = FALSE
	max_integrity = 100
	can_atmos_pass = ATMOS_PASS_DENSITY
	material_modifier = 0.5
	material_flags = MATERIAL_EFFECTS | MATERIAL_AFFECT_STATISTICS
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	/// Beauty component mood modifier
	var/impressiveness = 15
	/// Art component subtype added to this statue
	var/art_type = /datum/element/art
	/// Abstract root type
	var/abstract_type = /obj/structure/statue

/obj/structure/statue/Initialize(mapload)
	. = ..()
	AddElement(art_type, impressiveness)
	AddElement(/datum/element/beauty, impressiveness * 75)
	AddComponent(/datum/component/simple_rotation)
	AddComponent(/datum/component/marionette)

/obj/structure/statue/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/structure/statue/attackby(obj/item/W, mob/living/user, params)
	add_fingerprint(user)
	if(W.tool_behaviour == TOOL_WELDER)
		if(!W.tool_start_check(user, amount=1))
			return FALSE
		user.balloon_alert(user, "slicing apart...")
		if(W.use_tool(src, user, 40, volume=50))
			deconstruct(TRUE)
		return
	return ..()


/obj/structure/statue/atom_deconstruct(disassembled = TRUE)
	var/amount_mod = disassembled ? 0 : -2
	for(var/mat in custom_materials)
		var/datum/material/custom_material = GET_MATERIAL_REF(mat)
		var/amount = max(0,round(custom_materials[mat]/SHEET_MATERIAL_AMOUNT) + amount_mod)
		if(amount > 0)
			new custom_material.sheet_type(drop_location(), amount)

//////////////////////////////////////STATUES/////////////////////////////////////////////////////////////
////////////////////////uranium///////////////////////////////////

/obj/structure/statue/uranium
	max_integrity = 300
	// largish, dim green glow
	light_range = 3
	light_power = 0.7
	light_color = LIGHT_COLOR_NUCLEAR
	custom_materials = list(/datum/material/uranium=SHEET_MATERIAL_AMOUNT*5)
	impressiveness = 25 // radiation makes an impression
	abstract_type = /obj/structure/statue/uranium

/obj/structure/statue/uranium/nuke
	name = "核裂变炸弹雕像"
	desc = "一尊宏伟的核裂变炸药雕像。这雕像泛着绿光，好恶心。"
	icon_state = "nuke"

/obj/structure/statue/uranium/eng
	name = "Statue of an engineer"
	desc = "This statue has a sickening green colour."
	icon_state = "eng"

////////////////////////////plasma///////////////////////////////////////////////////////////////////////

/obj/structure/statue/plasma
	max_integrity = 200
	impressiveness = 20
	desc = "这是一尊等离子雕像，用料相得益彰。"
	custom_materials = list(/datum/material/plasma=SHEET_MATERIAL_AMOUNT*5)
	abstract_type = /obj/structure/statue/plasma

/obj/structure/statue/plasma/scientist
	name = "科学家雕像"
	icon_state = "sci"

/obj/structure/statue/plasma/xeno
	name = "异形雕像"
	icon_state = "xeno"

//////////////////////gold///////////////////////////////////////

/obj/structure/statue/gold
	max_integrity = 300
	impressiveness = 25
	desc = "这尊雕像很值钱，它是用黄金做成的"
	custom_materials = list(/datum/material/gold=SHEET_MATERIAL_AMOUNT*5)
	abstract_type = /obj/structure/statue/gold

/obj/structure/statue/gold/hos
	name = "安保部长雕像"
	icon_state = "hos"

/obj/structure/statue/gold/hop
	name = "人事部长雕像"
	icon_state = "hop"

/obj/structure/statue/gold/cmo
	name = "医疗部长雕像"
	icon_state = "cmo"

/obj/structure/statue/gold/ce
	name = "工程部长雕像"
	icon_state = "ce"

/obj/structure/statue/gold/rd
	name = "科研主管雕像"
	icon_state = "rd"

/obj/structure/statue/gold/qm
	name = "军需官雕像"
	icon_state = "qm"

//////////////////////////silver///////////////////////////////////////

/obj/structure/statue/silver
	max_integrity = 300
	impressiveness = 25
	desc = "这尊雕像很值钱，它是用白银做成的。"
	custom_materials = list(/datum/material/silver=SHEET_MATERIAL_AMOUNT*5)
	abstract_type = /obj/structure/statue/silver

/obj/structure/statue/silver/md
	name = "医务员雕像"
	icon_state = "md"

/obj/structure/statue/silver/janitor
	name = "清洁工雕像"
	icon_state = "jani"

/obj/structure/statue/silver/sec
	name = "安全官雕像"
	icon_state = "sec"

/obj/structure/statue/silver/secborg
	name = "安保赛博雕像"
	icon_state = "secborg"

/obj/structure/statue/silver/medborg
	name = "医疗赛博雕像"
	icon_state = "medborg"

/////////////////////////diamond/////////////////////////////////////////

/obj/structure/statue/diamond
	max_integrity = 1000
	impressiveness = 50
	desc = "这是一尊价值不菲的钻石雕像。"
	custom_materials = list(/datum/material/diamond=SHEET_MATERIAL_AMOUNT*5)
	abstract_type = /obj/structure/statue/diamond

/obj/structure/statue/diamond/captain
	name = "舰长雕像"
	icon_state = "cap"

/obj/structure/statue/diamond/ai1
	name = "AI全息图雕像"
	icon_state = "ai1"

/obj/structure/statue/diamond/ai2
	name = "AI核心雕像"
	icon_state = "ai2"

////////////////////////bananium///////////////////////////////////////

/obj/structure/statue/bananium
	max_integrity = 300
	impressiveness = 50
	desc = "一尊香蕉做的雕像，上面刻着细小的：'HOOOOOOONK'。"
	custom_materials = list(/datum/material/bananium=SHEET_MATERIAL_AMOUNT*5)
	abstract_type = /obj/structure/statue/bananium

/obj/structure/statue/bananium/clown
	name = "statue of a clown"
	icon_state = "clown"

/////////////////////sandstone/////////////////////////////////////////

/obj/structure/statue/sandstone
	max_integrity = 50
	impressiveness = 15
	custom_materials = list(/datum/material/sandstone=SHEET_MATERIAL_AMOUNT*5)
	abstract_type = /obj/structure/statue/sandstone

/obj/structure/statue/sandstone/assistant
	name = "助手雕像"
	desc = "一尊廉价砂岩制成的雕像，献给灰潮。"
	icon_state = "assist"

/obj/structure/statue/sandstone/venus //call me when we add marble i guess
	name = "纯洁少女之像"
	desc = "一尊历经岁月的大理石雕像。它一头长辫垂落脚踝，手握一个工具箱。朱庇特在上，这是你从未见过的绝美女性塑像，艺术家一定是一位真正的技艺大师。但令人惋惜的是，雕像的胳膊断了。"
	icon = 'icons/obj/art/statuelarge.dmi'
	icon_state = "venus"

/////////////////////snow/////////////////////////////////////////

/obj/structure/statue/snow
	max_integrity = 50
	custom_materials = list(/datum/material/snow=SHEET_MATERIAL_AMOUNT*5)
	abstract_type = /obj/structure/statue/snow

/obj/structure/statue/snow/snowman
	name = "雪人"
	desc = "几个雪球堆在一起，堆成了雪人。"
	icon_state = "snowman"

/obj/structure/statue/snow/snowlegion
	name = "雪人军团"
	desc = "看起来那个带着老虎玩偶的怪孩子又来过这里了。"
	icon_state = "snowlegion"

///////////////////////////////bronze///////////////////////////////////

/obj/structure/statue/bronze
	custom_materials = list(/datum/material/bronze=SHEET_MATERIAL_AMOUNT*5)
	abstract_type = /obj/structure/statue/bronze

/obj/structure/statue/bronze/marx
	name = "卡尔·马克思的半身像"
	desc = "一个19世纪的经济学家的半身像。你有种，一个幽灵，在空间站游荡的感觉。"
	icon_state = "marx"
	art_type = /datum/element/art/rev

///////////Elder Atmosian///////////////////////////////////////////

/obj/structure/statue/elder_atmosian
	name = "古老大气人"
	desc = "一尊古老大气人的雕像，他们能够随心所欲操纵热力学定律。"
	icon_state = "eng"
	custom_materials = list(/datum/material/metalhydrogen = SHEET_MATERIAL_AMOUNT*10)
	max_integrity = 1000
	impressiveness = 100
	abstract_type = /obj/structure/statue/elder_atmosian //This one is uncarvable

///////////Goliath//////////////////////////////////////////////////
/obj/structure/statue/goliath
	desc = "一尊栩栩如生的惊悚怪物雕像"
	icon = 'icons/mob/simple/lavaland/lavaland_monsters_wide.dmi'
	icon_state = "goliath"
	pixel_x = -12
	base_pixel_x = -12
	name = "goliath"

///////////Other Stuff//////////////////////////////////////////////
/obj/item/chisel
	name = "凿子"
	desc = "从公元前4000年延续至今，破开石料，创造艺术。如今这把凿子搭载上先进科技，能让雕像由静变动，栩栩如生。"
	icon = 'icons/obj/art/statue.dmi'
	icon_state = "chisel"
	inhand_icon_state = "screwdriver_nuke"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	obj_flags = CONDUCTS_ELECTRICITY
	slot_flags = ITEM_SLOT_BELT
	force = 5
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.75)
	attack_verb_continuous = list("stabs")
	attack_verb_simple = list("stab")
	hitsound = 'sound/weapons/bladeslice.ogg'
	usesound = list('sound/effects/picaxe1.ogg', 'sound/effects/picaxe2.ogg', 'sound/effects/picaxe3.ogg')
	drop_sound = 'sound/items/handling/screwdriver_drop.ogg'
	pickup_sound = 'sound/items/handling/screwdriver_pickup.ogg'
	sharpness = SHARP_POINTY
	tool_behaviour = TOOL_RUSTSCRAPER
	toolspeed = 3 // You're gonna have a bad time

	/// Block we're currently carving in
	var/obj/structure/carving_block/prepared_block
	/// If tracked user moves we stop sculpting
	var/mob/living/tracked_user
	/// Currently sculpting
	var/sculpting = FALSE

/obj/item/chisel/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/eyestab)
	AddElement(/datum/element/wall_engraver)
	//deals 200 damage to statues, meaning you can actually kill one in ~250 hits
	AddElement(/datum/element/bane, target_type = /mob/living/basic/statue, damage_multiplier = 40)

/obj/item/chisel/Destroy()
	prepared_block = null
	tracked_user = null
	return ..()

/*
Hit the block to start
Point with the chisel at the target to choose what to sculpt or hit block to choose from preset statue types.
Hit block again to start sculpting.
Moving interrupts
*/
/obj/item/chisel/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(sculpting)
		return ITEM_INTERACT_BLOCKING
	if(istype(interacting_with, /obj/structure/carving_block))
		var/obj/structure/carving_block/sculpt_block = interacting_with

		if(sculpt_block.completion) // someone already started sculpting this so just finish
			set_block(sculpt_block, user, silent = TRUE)
			start_sculpting(user)
		else if(sculpt_block == prepared_block && (prepared_block.current_target || prepared_block.current_preset_type))
			start_sculpting(user)
		else if(!prepared_block)
			set_block(sculpt_block, user)
		else if(sculpt_block == prepared_block)
			show_generic_statues_prompt(user)
		return ITEM_INTERACT_SUCCESS

	else if(prepared_block) //We're aiming at something next to us with block prepared
		prepared_block.set_target(interacting_with, user)
		return ITEM_INTERACT_SUCCESS

	return NONE

// We aim at something distant.
/obj/item/chisel/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if (!sculpting && prepared_block && ismovable(interacting_with) && prepared_block.completion == 0)
		prepared_block.set_target(interacting_with, user)
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/// Starts or continues the sculpting action on the carving block material
/obj/item/chisel/proc/start_sculpting(mob/living/user)
	user.balloon_alert(user, "正在雕刻雕块...")
	playsound(src, pick(usesound), 75, TRUE)
	sculpting = TRUE
	//How long whole process takes
	var/sculpting_time = 30 SECONDS
	//Single interruptible progress period
	var/sculpting_period = round(sculpting_time / world.icon_size) //this is just so it reveals pixels line by line for each.
	var/interrupted = FALSE
	var/remaining_time = sculpting_time - (prepared_block.completion * sculpting_time)

	var/datum/progressbar/total_progress_bar = new(user, sculpting_time, prepared_block)
	while(remaining_time > 0 && !interrupted)
		if(do_after(user, sculpting_period, target = prepared_block, progress = FALSE))
			var/time_delay = !(remaining_time % SCULPT_SOUND_INCREMENT)
			if(time_delay)
				playsound(src, 'sound/effects/break_stone.ogg', 50, TRUE)
			remaining_time -= sculpting_period
			prepared_block.set_completion((sculpting_time - remaining_time)/sculpting_time)
			total_progress_bar.update(sculpting_time - remaining_time)
		else
			interrupted = TRUE
	total_progress_bar.end_progress()
	if(!interrupted && !QDELETED(prepared_block))
		prepared_block.create_statue()
		user.balloon_alert(user, "雕像完成")
	stop_sculpting(silent = !interrupted)

/// To setup the sculpting target for the carving block
/obj/item/chisel/proc/set_block(obj/structure/carving_block/B, mob/living/user, silent = FALSE)
	prepared_block = B
	tracked_user = user
	RegisterSignal(tracked_user, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	if(!silent)
		user.balloon_alert(user, "select sculpt target")

/obj/item/chisel/dropped(mob/user, silent)
	. = ..()
	stop_sculpting()

/// Cancel the sculpting action
/obj/item/chisel/proc/stop_sculpting(silent = FALSE)
	sculpting = FALSE
	if(prepared_block && prepared_block.completion == 0)
		prepared_block.reset_target()
	prepared_block = null

	if(!silent && tracked_user)
		tracked_user.balloon_alert(tracked_user, "sculpting cancelled!")

	if(tracked_user)
		UnregisterSignal(tracked_user, COMSIG_MOVABLE_MOVED)
		tracked_user = null

/obj/item/chisel/proc/on_moved()
	SIGNAL_HANDLER

	stop_sculpting()

/obj/item/chisel/proc/show_generic_statues_prompt(mob/living/user)
	var/list/choices = list()
	for(var/statue_path in prepared_block.get_possible_statues())
		var/obj/structure/statue/abstract_statue = statue_path
		choices[statue_path] = image(icon = initial(abstract_statue.icon), icon_state = initial(abstract_statue.icon_state))
	if(!choices.len)
		user.balloon_alert(user, "no abstract statues for material!")

	var/choice = show_radial_menu(user, prepared_block, choices, require_near = TRUE)
	if(choice)
		prepared_block.current_preset_type = choice
		var/image/chosen_looks = choices[choice]
		prepared_block.current_target = chosen_looks.appearance
		user.balloon_alert(user, "abstract statue selected")

/obj/structure/carving_block
	name = "雕块"
	desc = "随时可以开始雕刻。"
	icon = 'icons/obj/art/statue.dmi'
	icon_state = "block"
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS | MATERIAL_ADD_PREFIX
	density = TRUE
	material_modifier = 0.5 //50% effectiveness of materials

	/// The thing it will look like - Unmodified resulting statue appearance
	var/current_target
	/// Currently chosen preset statue type
	var/current_preset_type
	//Table of required materials for each non-abstract statue type
	var/static/list/statue_costs
	/// statue completion from 0 to 1.0
	var/completion = 0
	/// Greyscaled target with cutout filter
	var/mutable_appearance/target_appearance_with_filters
	/// HSV color filters parameters
	var/static/list/greyscale_with_value_bump = list(0,0,0, 0,0,0, 0,0,1, 0,0,-0.05)

/obj/structure/carving_block/Destroy()
	current_target = null
	target_appearance_with_filters = null
	return ..()

/obj/structure/carving_block/proc/set_target(atom/movable/target, mob/living/user)
	if(!is_viable_target(user, target))
		return
	if(istype(target,/obj/structure/statue/custom))
		var/obj/structure/statue/custom/original = target
		current_target = original.content_ma
	else
		current_target = target.appearance
	var/mutable_appearance/ma = current_target
	user.balloon_alert(user, "雕刻目标为 [ma.name]")

/obj/structure/carving_block/proc/reset_target()
	current_target = null
	current_preset_type = null
	target_appearance_with_filters = null

/obj/structure/carving_block/update_overlays()
	. = ..()
	if(!target_appearance_with_filters)
		return
	//We're only keeping one instance here that changes in the middle so we have to clone it to avoid managed overlay issues
	var/mutable_appearance/clone = new(target_appearance_with_filters)
	. += clone

/obj/structure/carving_block/proc/is_viable_target(mob/living/user, atom/movable/target)
	//Only things on turfs
	if(!isturf(target.loc))
		user.balloon_alert(user, "无雕刻目标！")
		return FALSE
	//No big icon things
	var/list/icon_dimensions = get_icon_dimensions(target.icon)
	if(icon_dimensions["width"] != world.icon_size || icon_dimensions["height"] != world.icon_size)
		user.balloon_alert(user, "雕刻目标太大了！")
		return FALSE
	return TRUE

/obj/structure/carving_block/proc/create_statue()
	if(current_preset_type)
		var/obj/structure/statue/preset_statue = new current_preset_type(get_turf(src))
		preset_statue.set_custom_materials(custom_materials)
		qdel(src)
	else if(current_target)
		var/obj/structure/statue/custom/new_statue = new(get_turf(src))
		new_statue.set_visuals(current_target)
		new_statue.set_custom_materials(custom_materials)
		var/mutable_appearance/ma = current_target
		new_statue.name = "[ma.name]雕像"
		new_statue.desc = "一尊凿刻雕像，描绘了 [ma.name]."
		qdel(src)

/obj/structure/carving_block/proc/set_completion(value)
	if(!current_target)
		return
	if(!target_appearance_with_filters)
		target_appearance_with_filters = new(current_target)
		// KEEP_APART in case carving block gets KEEP_TOGETHER from somewhere like material texture filters.
		target_appearance_with_filters.appearance_flags |= KEEP_TOGETHER | KEEP_APART
		//Doesn't use filter helpers because MAs aren't atoms
		target_appearance_with_filters.filters = filter(type="color",color=greyscale_with_value_bump,space=FILTER_COLOR_HSV)
	completion = value
	var/static/icon/white = icon('icons/effects/alphacolors.dmi', "white")
	switch(value)
		if(0)
			//delete uncovered and reset filters
			remove_filter("partial_uncover")
			target_appearance_with_filters = null
		else
			var/mask_offset = min(world.icon_size,round(completion * world.icon_size))
			remove_filter("partial_uncover")
			add_filter("partial_uncover", 1, alpha_mask_filter(icon = white, y = -mask_offset))
			target_appearance_with_filters.filters = filter(type="alpha",icon=white,y=-mask_offset,flags=MASK_INVERSE)
	update_appearance()


/// Returns a list of preset statues carvable from this block depending on the custom materials
/obj/structure/carving_block/proc/get_possible_statues()
	. = list()
	if(!statue_costs)
		statue_costs = build_statue_cost_table()
	for(var/statue_path in statue_costs)
		var/list/carving_cost = statue_costs[statue_path]
		var/enough_materials = TRUE
		for(var/required_material in carving_cost)
			if(!has_material_type(required_material, carving_cost[required_material]))
				enough_materials = FALSE
				break
		if(enough_materials)
			. += statue_path

/obj/structure/carving_block/proc/build_statue_cost_table()
	. = list()
	for(var/statue_type in subtypesof(/obj/structure/statue) - /obj/structure/statue/custom)
		var/obj/structure/statue/S = new statue_type()
		if(!S.icon_state || S.abstract_type == S.type || !S.custom_materials)
			continue
		.[S.type] = S.custom_materials
		qdel(S)

/obj/structure/statue/custom
	name = "自定义雕像"
	icon_state = "base"
	obj_flags = CAN_BE_HIT | UNIQUE_RENAME
	appearance_flags = TILE_BOUND | PIXEL_SCALE | KEEP_TOGETHER | LONG_GLIDE //Added keep together in case targets has weird layering
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	/// primary statue overlay
	var/mutable_appearance/content_ma
	var/static/list/greyscale_with_value_bump = list(0,0,0, 0,0,0, 0,0,1, 0,0,-0.05)

/obj/structure/statue/custom/Destroy()
	content_ma = null
	return ..()

/obj/structure/statue/custom/proc/set_visuals(model_appearance)
	if(content_ma)
		QDEL_NULL(content_ma)
	content_ma = new
	content_ma.appearance = model_appearance
	content_ma.pixel_x = 0
	content_ma.pixel_y = 0
	content_ma.alpha = 255

	var/static/list/plane_whitelist = list(FLOAT_PLANE, GAME_PLANE, FLOOR_PLANE)

	/// Ideally we'd have knowledge what we're removing but i'd have to be done on target appearance retrieval
	var/list/overlays_to_keep = list()
	for(var/mutable_appearance/special_overlay as anything in content_ma.overlays)
		var/mutable_appearance/real = new()
		real.appearance = special_overlay
		if(PLANE_TO_TRUE(real.plane) in plane_whitelist)
			overlays_to_keep += real
	content_ma.overlays = overlays_to_keep

	var/list/underlays_to_keep = list()
	for(var/mutable_appearance/special_underlay as anything in content_ma.underlays)
		var/mutable_appearance/real = new()
		real.appearance = special_underlay
		if(PLANE_TO_TRUE(real.plane) in plane_whitelist)
			underlays_to_keep += real
	content_ma.underlays = underlays_to_keep

	content_ma.appearance_flags &= ~KEEP_APART //Don't want this
	content_ma.filters = filter(type="color",color=greyscale_with_value_bump,space=FILTER_COLOR_HSV)
	update_content_planes()
	update_appearance()

/obj/structure/statue/custom/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	if(same_z_layer)
		return ..()
	update_content_planes()
	update_appearance()

/obj/structure/statue/custom/proc/update_content_planes()
	if(!content_ma)
		return
	var/turf/our_turf = get_turf(src)
	// MA's stored in the overlays list are not actually mutable, they've been flattened
	// This proc unflattens them, updates them, and then reapplies
	var/list/created = update_appearance_planes(list(content_ma), GET_TURF_PLANE_OFFSET(our_turf))
	content_ma = created[1]

/obj/structure/statue/custom/update_overlays()
	. = ..()
	if(content_ma)
		. += content_ma

#undef SCULPT_SOUND_INCREMENT
