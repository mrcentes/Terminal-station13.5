/obj/item/ammo_casing/energy/gravity
	e_cost = 0 // Not possible to use the macro
	fire_sound = 'sound/weapons/wave.ogg'
	select_name = "引力"
	delay = 50
	var/obj/item/gun/energy/gravity_gun/gun
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect

/obj/item/ammo_casing/energy/gravity/Initialize(mapload)
	if(istype(loc,/obj/item/gun/energy/gravity_gun))
		gun = loc
	. = ..()

/obj/item/ammo_casing/energy/gravity/Destroy()
	gun = null
	. = ..()

/obj/item/ammo_casing/energy/gravity/repulse
	projectile_type = /obj/projectile/gravityrepulse
	select_name = "排斥"

/obj/item/ammo_casing/energy/gravity/attract
	projectile_type = /obj/projectile/gravityattract
	select_name = "牵引"

/obj/item/ammo_casing/energy/gravity/chaos
	projectile_type = /obj/projectile/gravitychaos
	select_name = "混乱"


