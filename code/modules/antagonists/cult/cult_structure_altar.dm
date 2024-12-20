/// Some defines for items the cult altar can create.
#define ELDRITCH_WHETSTONE "血教灵魂石"
#define CONSTRUCT_SHELL "建筑者躯壳"
#define UNHOLY_WATER "邪水瓶"

// Cult altar. Gives out consumable items.
/obj/structure/destructible/cult/item_dispenser/altar
	name = "祭坛"
	desc = "用于供奉Nar'Sie的血腥祭坛."
	cult_examine_tip = "可用于创建血教灵魂石，建筑者躯壳以及邪水瓶."
	icon_state = "talismanaltar"
	break_message = "<span class='warning'>祭坛破碎，只留下被诅咒者的哀号!</span>"

/obj/structure/destructible/cult/item_dispenser/altar/setup_options()
	var/static/list/altar_items = list(
		ELDRITCH_WHETSTONE = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/antags/cult/items.dmi', icon_state = "cult_sharpener"),
			OUTPUT_ITEMS = list(/obj/item/sharpener/cult),
			),
		CONSTRUCT_SHELL = list(
			PREVIEW_IMAGE = image(icon = 'icons/mob/shells.dmi', icon_state = "construct_cult"),
			OUTPUT_ITEMS = list(/obj/structure/constructshell),
			),
		UNHOLY_WATER = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/drinks/bottles.dmi', icon_state = "unholyflask"),
			OUTPUT_ITEMS = list(/obj/item/reagent_containers/cup/beaker/unholywater),
			),
	)

	options = altar_items

/obj/structure/destructible/cult/item_dispenser/altar/succcess_message(mob/living/user, obj/item/spawned_item)
	to_chat(user, span_cult_italic("你跪在[src]前，你的信仰被回报以[spawned_item]!"))

#undef ELDRITCH_WHETSTONE
#undef CONSTRUCT_SHELL
#undef UNHOLY_WATER
