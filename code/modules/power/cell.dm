#define CELL_DRAIN_TIME 35
#define CELL_POWER_GAIN 60
#define CELL_POWER_DRAIN 750

/**
 * # Power cell
 *
 * Batteries.
 */
/obj/item/stock_parts/cell
	name = "电池"
	desc = "可充电的电池."
	icon = 'icons/obj/machines/cell_charger.dmi'
	icon_state = "cell"
	inhand_icon_state = "cell"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	force = 5
	throwforce = 5
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*7, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.5)
	grind_results = list(/datum/reagent/lithium = 15, /datum/reagent/iron = 5, /datum/reagent/silicon = 5)
	///Current charge in cell units
	var/charge = 0
	///Maximum charge in cell units
	var/maxcharge = STANDARD_CELL_CHARGE
	///If the cell has been booby-trapped by injecting it with plasma. Chance on use() to explode.
	var/rigged = FALSE
	///If the power cell was damaged by an explosion, chance for it to become corrupted and function the same as rigged.
	var/corrupted = FALSE
	///how much power is given every tick in a recharger
	var/chargerate = STANDARD_CELL_CHARGE * 0.1
	///If true, the cell will state it's maximum charge in it's description
	var/ratingdesc = TRUE
	///If it's a grown that acts as a battery, add a wire overlay to it.
	var/grown_battery = FALSE
	///What charge lige sprite to use, null if no light
	var/charge_light_type = "standard"
	///What connector sprite to use when in a cell charger, null if no connectors
	var/connector_type = "standard"
	///Does the cell start without any charge?
	var/empty = FALSE

/obj/item/stock_parts/cell/get_cell()
	return src

/obj/item/stock_parts/cell/Initialize(mapload, override_maxcharge)
	. = ..()
	create_reagents(5, INJECTABLE | DRAINABLE)
	if (override_maxcharge)
		maxcharge = override_maxcharge
	rating = max(round(maxcharge / (STANDARD_CELL_CHARGE * 10), 1), 1)
	if(!charge)
		charge = maxcharge
	if(empty)
		charge = 0
	if(ratingdesc)
		desc += " 这个的功率是[display_energy(maxcharge)][prob(10) ? ", 你不应该吞下去" : ""]." //joke works better if it's not on every cell
	update_appearance()

	RegisterSignal(src, COMSIG_ITEM_MAGICALLY_CHARGED, PROC_REF(on_magic_charge))
	var/static/list/loc_connections = list(
		COMSIG_ITEM_MAGICALLY_CHARGED = PROC_REF(on_magic_charge),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/**
 * Signal proc for [COMSIG_ITEM_MAGICALLY_CHARGED]
 *
 * If we, or the item we're located in, is subject to the charge spell, gain some charge back
 */
/obj/item/stock_parts/cell/proc/on_magic_charge(datum/source, datum/action/cooldown/spell/charge/spell, mob/living/caster)
	SIGNAL_HANDLER

	// This shouldn't be running if we're not being held by a mob,
	// or if we're not within an object being held by a mob, but just in case...
	if(!ismovable(loc))
		return

	. = COMPONENT_ITEM_CHARGED

	if(prob(80))
		maxcharge -= STANDARD_CELL_CHARGE * 0.2

	if(maxcharge <= 1) // Div by 0 protection
		maxcharge = 1
		. |= COMPONENT_ITEM_BURNT_OUT

	charge = maxcharge
	update_appearance()

	// Guns need to process their chamber when we've been charged
	if(isgun(loc))
		var/obj/item/gun/gun_loc = loc
		gun_loc.process_chamber()

	// The thing we're in might have overlays or icon states for whether the cell is charged
	if(!ismob(loc))
		loc.update_appearance()

	return .

/obj/item/stock_parts/cell/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignals(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT), PROC_REF(on_reagent_change))
	RegisterSignal(reagents, COMSIG_QDELETING, PROC_REF(on_reagents_del))

/// Handles properly detaching signal hooks.
/obj/item/stock_parts/cell/proc/on_reagents_del(datum/reagents/reagents)
	SIGNAL_HANDLER
	UnregisterSignal(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT, COMSIG_QDELETING))
	return NONE

/obj/item/stock_parts/cell/update_overlays()
	. = ..()
	if(grown_battery)
		. += mutable_appearance('icons/obj/machines/cell_charger.dmi', "grown_wires")
	if((charge < 0.01) || !charge_light_type)
		return
	. += mutable_appearance('icons/obj/machines/cell_charger.dmi', "cell-[charge_light_type]-o[(percent() >= 99.5) ? 2 : 1]")

/obj/item/stock_parts/cell/vv_edit_var(vname, vval)
	if(vname == NAMEOF(src, charge))
		charge = clamp(vval, 0, maxcharge)
		return TRUE
	if(vname == NAMEOF(src, maxcharge))
		if(charge > vval)
			charge = vval
	if(vname == NAMEOF(src, corrupted) && vval && !corrupted)
		corrupt(TRUE)
		return TRUE
	return ..()


/obj/item/stock_parts/cell/proc/percent() // return % charge of cell
	return 100 * charge / maxcharge

// use power from a cell
/obj/item/stock_parts/cell/use(used, force)
	if(rigged && used > 0)
		explode()
		return FALSE
	if(!force && charge < used)
		return FALSE
	charge = max(charge - used, 0)
	if(!istype(loc, /obj/machinery/power/apc))
		SSblackbox.record_feedback("tally", "cell_used", 1, type)
	return TRUE

// recharge the cell
/obj/item/stock_parts/cell/proc/give(amount)
	if(rigged && amount > 0)
		explode()
		return 0
	if(maxcharge < amount)
		amount = maxcharge
	var/power_used = min(maxcharge-charge,amount)
	charge += power_used
	return power_used

/obj/item/stock_parts/cell/examine(mob/user)
	. = ..()
	// SKYRAT EDIT ADDITION
	if(ratingdesc && !microfusion_readout)
		. += "这个的额定是[display_energy(maxcharge)], 你不应该吞下去."
	// SKYRAT EDIT END
	if(rigged)
		. += span_danger("这个电池好像有毛病!")
	// SKYRAT EDIT ADDITION
	else if(microfusion_readout)
		. += "电荷计读数为 [charge]/[maxcharge] MF."
	// SKYRAT EDIT END
	else
		. += "电荷计读数为 [CEILING(percent(), 0.1)]%." //so it doesn't say 0% charge when the overlay indicates it still has charge

/obj/item/stock_parts/cell/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user]正在舔[src]的电极! 这是一种自杀行为!"))
	return FIRELOSS

/obj/item/stock_parts/cell/proc/on_reagent_change(datum/reagents/holder, ...)
	SIGNAL_HANDLER
	rigged = (corrupted || holder.has_reagent(/datum/reagent/toxin/plasma, 5)) ? TRUE : FALSE //has_reagent returns the reagent datum
	return NONE


/obj/item/stock_parts/cell/proc/explode()
	if(!charge)
		return
	var/range_devastation = -1 //round(charge/11000)
	var/range_heavy = round(sqrt(charge)/60)
	var/range_light = round(sqrt(charge)/30)
	var/range_flash = range_light
	if(!range_light)
		rigged = FALSE
		corrupt()
		return

	message_admins("[ADMIN_LOOKUPFLW(usr)] has triggered a rigged/corrupted power cell explosion at [AREACOORD(loc)].")
	usr?.log_message("triggered a rigged/corrupted power cell explosion", LOG_GAME)
	usr?.log_message("triggered a rigged/corrupted power cell explosion", LOG_VICTIM, log_globally = FALSE)

	//explosion(T, 0, 1, 2, 2)
	explosion(src, devastation_range = range_devastation, heavy_impact_range = range_heavy, light_impact_range = range_light, flash_range = range_flash)
	qdel(src)

/obj/item/stock_parts/cell/proc/corrupt(force)
	charge /= 2
	maxcharge = max(maxcharge/2, chargerate)
	if (force || prob(10))
		rigged = TRUE //broken batterys are dangerous
		corrupted = TRUE

/obj/item/stock_parts/cell/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	charge -= 1000 / severity
	if (charge < 0)
		charge = 0

/obj/item/stock_parts/cell/ex_act(severity, target)
	. = ..()
	if(QDELETED(src))
		return FALSE

	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				corrupt()
		if(EXPLODE_LIGHT)
			if(prob(25))
				corrupt()

	return TRUE

/obj/item/stock_parts/cell/attack_self(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/internal/stomach/maybe_stomach = H.get_organ_slot(ORGAN_SLOT_STOMACH)

		if(istype(maybe_stomach, /obj/item/organ/internal/stomach/ethereal))

			var/charge_limit = ETHEREAL_CHARGE_DANGEROUS - CELL_POWER_GAIN
			var/obj/item/organ/internal/stomach/ethereal/stomach = maybe_stomach
			if((stomach.drain_time > world.time) || !stomach)
				return
			if(charge < CELL_POWER_DRAIN)
				to_chat(H, span_warning("[src]没有足够的电量!"))
				return
			if(stomach.crystal_charge > charge_limit)
				to_chat(H, span_warning("你的充能已满!"))
				return
			to_chat(H, span_notice("你开始笨拙地将电能从[src]导入你的身体."))
			stomach.drain_time = world.time + CELL_DRAIN_TIME
			if(do_after(user, CELL_DRAIN_TIME, target = src))
				if((charge < CELL_POWER_DRAIN) || (stomach.crystal_charge > charge_limit))
					return
				if(istype(stomach))
					to_chat(H, span_notice("你从[src]得到一些电力，在这个过程中浪费了一些。"))
					stomach.adjust_charge(CELL_POWER_GAIN)
					charge -= CELL_POWER_DRAIN //you waste way more than you receive, so that ethereals cant just steal one cell and forget about hunger
				else
					to_chat(H, span_warning("你不能从[src]充能!"))
			return


/obj/item/stock_parts/cell/blob_act(obj/structure/blob/B)
	SSexplosions.high_mov_atom += src

/obj/item/stock_parts/cell/proc/get_electrocute_damage()
	if(charge >= 1000)
		return clamp(20 + round(charge/25000), 20, 195) + rand(-5,5)
	else
		return 0

/obj/item/stock_parts/cell/get_part_rating()
	return maxcharge * 10 + charge

/obj/item/stock_parts/cell/attackby_storage_insert(datum/storage, atom/storage_holder, mob/user)
	var/obj/item/mod/control/mod = storage_holder
	return !(istype(mod) && mod.open)

/* Cell variants*/
/obj/item/stock_parts/cell/empty
	empty = TRUE

/obj/item/stock_parts/cell/crap
	name = "Nanotrasen牌可充AA电池"
	desc = "你无法超越等离子." //TOTALLY TRADEMARK INFRINGEMENT
	maxcharge = STANDARD_CELL_CHARGE * 0.5
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*0.4)

/obj/item/stock_parts/cell/crap/empty
	empty = TRUE

/obj/item/stock_parts/cell/upgraded
	name = "升级电池"
	desc = "一个比普通电池容量稍高的先进电池!"
	maxcharge = STANDARD_CELL_CHARGE * 2.5
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*0.5)
	chargerate = STANDARD_CELL_CHARGE

/obj/item/stock_parts/cell/upgraded/plus
	name = "升级电池+"
	desc = "比基本型号容量更高的先进电池!"
	maxcharge = STANDARD_CELL_CHARGE * 5

/obj/item/stock_parts/cell/secborg
	name = "安保赛博可充D电池"
	maxcharge = STANDARD_CELL_CHARGE * 0.6
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*0.4)

/obj/item/stock_parts/cell/secborg/empty
	empty = TRUE

/obj/item/stock_parts/cell/mini_egun
	name = "微型能量枪电池"
	maxcharge = STANDARD_CELL_CHARGE * 0.6

/obj/item/stock_parts/cell/hos_gun
	name = "X-01微型能量枪电池"
	maxcharge = STANDARD_CELL_CHARGE * 1.2

/obj/item/stock_parts/cell/pulse //200 pulse shots
	name = "脉冲步枪电池"
	maxcharge = STANDARD_CELL_CHARGE * 40
	chargerate = STANDARD_CELL_CHARGE * 1.5

/obj/item/stock_parts/cell/pulse/carbine //25 pulse shots
	name = "脉冲卡宾枪电池"
	maxcharge = STANDARD_CELL_CHARGE * 5

/obj/item/stock_parts/cell/pulse/pistol //10 pulse shots
	name = "脉冲手枪电池"
	maxcharge = STANDARD_CELL_CHARGE * 2

/obj/item/stock_parts/cell/ninja
	name = "黑电池"
	icon_state = "bscell"
	maxcharge = STANDARD_CELL_CHARGE * 10
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*0.6)
	chargerate = STANDARD_CELL_CHARGE * 2

/obj/item/stock_parts/cell/high
	name = "大功率电池"
	icon_state = "hcell"
	maxcharge = STANDARD_CELL_CHARGE * 10
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*0.6)
	chargerate = STANDARD_CELL_CHARGE * 1.5

/obj/item/stock_parts/cell/high/empty
	empty = TRUE

/obj/item/stock_parts/cell/super
	name = "高功率电池"
	icon_state = "scell"
	maxcharge = STANDARD_CELL_CHARGE * 20
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT * 3)
	chargerate = STANDARD_CELL_CHARGE * 2

/obj/item/stock_parts/cell/super/empty
	empty = TRUE

/obj/item/stock_parts/cell/hyper
	name = "超功率电池"
	icon_state = "hpcell"
	maxcharge = STANDARD_CELL_CHARGE * 30
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT * 4)
	chargerate = STANDARD_CELL_CHARGE * 3

/obj/item/stock_parts/cell/hyper/empty
	empty = TRUE

/obj/item/stock_parts/cell/bluespace
	name = "蓝空电池"
	desc = "一种可充电的跨维电池."
	icon_state = "bscell"
	maxcharge = STANDARD_CELL_CHARGE * 40
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*6)
	chargerate = STANDARD_CELL_CHARGE * 4

/obj/item/stock_parts/cell/bluespace/empty
	empty = TRUE

/obj/item/stock_parts/cell/infinite
	name = "极功率电池"
	icon_state = "icell"
	maxcharge = INFINITY //little disappointing if you examine it and it's not huge
	custom_materials = list(/datum/material/glass=HALF_SHEET_MATERIAL_AMOUNT)
	chargerate = INFINITY
	ratingdesc = FALSE

/obj/item/stock_parts/cell/infinite/use(used)
	return TRUE

/obj/item/stock_parts/cell/infinite/abductor
	name = "虚空核心"
	desc = "一种外星能量电池，能凭空产生能量."
	icon = 'icons/obj/antags/abductor.dmi'
	icon_state = "cell"
	maxcharge = STANDARD_CELL_CHARGE * 50
	ratingdesc = FALSE

/obj/item/stock_parts/cell/infinite/abductor/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	return ..()

/obj/item/stock_parts/cell/potato
	name = "土豆电池"
	desc = "一种可充电的淀粉基电池."
	icon = 'icons/obj/service/hydroponics/harvest.dmi'
	icon_state = "potato"
	charge = 100
	maxcharge = STANDARD_CELL_CHARGE * 0.3
	charge_light_type = null
	connector_type = null
	custom_materials = null
	grown_battery = TRUE //it has the overlays for wires
	custom_premium_price = PAYCHECK_CREW

/obj/item/stock_parts/cell/emproof
	name = "抗电磁脉冲电池"
	desc = "一种抗电磁脉冲电池."
	maxcharge = STANDARD_CELL_CHARGE * 0.5

/obj/item/stock_parts/cell/emproof/Initialize(mapload)
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF)
	return ..()

/obj/item/stock_parts/cell/emproof/empty
	empty = TRUE

/obj/item/stock_parts/cell/emproof/corrupt()
	return

/obj/item/stock_parts/cell/emproof/slime
	name = "抗电磁脉冲史莱姆核心"
	desc = "注入等离子体的黄色史莱姆核心，它的有机性质使它对电磁脉冲免疫."
	icon = 'icons/mob/simple/slimes.dmi'
	icon_state = "yellow slime extract"
	custom_materials = null
	maxcharge = STANDARD_CELL_CHARGE * 5
	charge_light_type = null
	connector_type = "slimecore"

/obj/item/stock_parts/cell/beam_rifle
	name = "光束步枪电容器"
	desc = "一种能在瞬间提供大量能量的高功率电容器."
	maxcharge = STANDARD_CELL_CHARGE * 50
	chargerate = STANDARD_CELL_CHARGE * 5 //Extremely energy intensive

/obj/item/stock_parts/cell/beam_rifle/corrupt()
	return

/obj/item/stock_parts/cell/beam_rifle/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	charge = clamp((charge-(10000/severity)),0,maxcharge)

/obj/item/stock_parts/cell/emergency_light
	name = "微型电池"
	desc = "一个很小的能量电池，容量很低；用于照明装置，在停电时为其供电."
	maxcharge = STANDARD_CELL_CHARGE * 0.12 //Emergency lights use 0.2 W per tick, meaning ~10 minutes of emergency power from a cell
	custom_materials = list(/datum/material/glass = SMALL_MATERIAL_AMOUNT*0.2)
	w_class = WEIGHT_CLASS_TINY

/obj/item/stock_parts/cell/emergency_light/Initialize(mapload)
	. = ..()
	var/area/area = get_area(src)
	if(area)
		if(!area.lightswitch || !area.light_power)
			charge = 0 //For naturally depowered areas, we start with no power

/obj/item/stock_parts/cell/crystal_cell
	name = "晶体电池"
	desc = "由结晶等离子体制成的高功率电池"
	icon_state = "crystal_cell"
	maxcharge = STANDARD_CELL_CHARGE * 50
	chargerate = 0
	charge_light_type = null
	connector_type = "crystal"
	custom_materials = null
	grind_results = null

/obj/item/stock_parts/cell/inducer_supply
	maxcharge = STANDARD_CELL_CHARGE * 5

#undef CELL_DRAIN_TIME
#undef CELL_POWER_GAIN
#undef CELL_POWER_DRAIN
