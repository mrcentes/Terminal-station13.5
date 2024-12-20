/obj/machinery/computer/arcade/amputation
	name = "医疗博格的截肢大冒险"
	desc = "屏幕上显示出一台浸染鲜血的医疗赛博. \
		它上方的对话气泡写道, \"把手伸进机器里来，如果你不是<b>懦夫!</b>的话.\""
	icon_state = "arcade"
	circuit = /obj/item/circuitboard/computer/arcade/amputation
	interaction_flags_machine = NONE //borgs can't play, but the illiterate can.

/obj/machinery/computer/arcade/amputation/attack_tk(mob/user)
	return //that's a pretty damn big guillotine

/obj/machinery/computer/arcade/amputation/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!iscarbon(user))
		return
	to_chat(user, span_warning("You move your hand towards the machine, and begin to hesitate as a bloodied guillotine emerges from inside of it..."))
	user.played_game()
	var/obj/item/bodypart/chopchop = user.get_active_hand()
	if(do_after(user, 5 SECONDS, target = src, extra_checks = CALLBACK(src, PROC_REF(do_they_still_have_that_hand), user, chopchop)))
		playsound(src, 'sound/weapons/slice.ogg', 25, TRUE, -1)
		to_chat(user, span_userdanger("The guillotine drops on your arm, and the machine sucks it in!"))
		chopchop.dismember()
		qdel(chopchop)
		user.mind?.adjust_experience(/datum/skill/gaming, 100)
		user.won_game()
		playsound(src, 'sound/arcade/win.ogg', 50, TRUE)
		new /obj/item/stack/arcadeticket((get_turf(src)), rand(6,10))
		to_chat(user, span_notice("[src] dispenses a handful of tickets!"))
		return
	if(!do_they_still_have_that_hand(user, chopchop))
		to_chat(user, span_warning("The guillotine drops, but your hand seems to be gone already!"))
		playsound(src, 'sound/weapons/slice.ogg', 25, TRUE, -1)
	else
		to_chat(user, span_notice("You (wisely) decide against putting your hand in the machine."))
	user.lost_game()

///Makes sure the user still has their starting hand, preventing the user from pulling the arm out and still getting prizes.
/obj/machinery/computer/arcade/amputation/proc/do_they_still_have_that_hand(mob/user, obj/item/bodypart/chopchop)
	if(QDELETED(chopchop) || chopchop.owner != user)
		return FALSE
	return TRUE

///Dispenses wrapped gifts instead of arcade prizes, also known as the ancap christmas tree
/obj/machinery/computer/arcade/amputation/festive
	name = "医疗博格的节日截肢大冒险"
	desc = "屏幕上显示出一台浸染鲜血还带着圣诞帽的医疗赛博. \
		它上方的对话气泡写道, \"把手伸进机器里来，如果你不是<b>懦夫!</b>的话.\""
	prize_override = list(/obj/item/gift/anything = 1)
