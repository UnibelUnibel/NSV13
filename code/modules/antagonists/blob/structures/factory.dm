/obj/structure/blob/factory
	name = "zarodnia"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_factory"
	desc = "struktura z gęstych, grzybich pnączy."
	max_integrity = 200
	health_regen = 1
	point_return = 25
	resistance_flags = LAVA_PROOF
	var/list/spores = list()
	var/mob/living/simple_animal/hostile/blob/blobbernaut/naut = null
	var/max_spores = 3
	var/spore_delay = 0
	var/spore_cooldown = 80 //8 seconds between spores and after spore death


/obj/structure/blob/factory/scannerreport()
	if(naut)
		return "W tym momencie podtrzymuje grzybonautę i jest bardzo podatna na obrażenia oraz nie wytwarza zarodników."
	return "Wytwarza zarodniki co kilka sekund."

/obj/structure/blob/factory/Destroy()
	for(var/mob/living/simple_animal/hostile/blob/blobspore/spore in spores)
		if(spore.factory == src)
			spore.factory = null
	if(naut)
		naut.factory = null
		to_chat(naut, "<span class='userdanger'>Twoja zarodnia została zniszczona! Czujesz jak umierasz!</span>")
		naut.throw_alert("nofactory", /atom/movable/screen/alert/nofactory)
	spores = null
	return ..()

/obj/structure/blob/factory/Be_Pulsed()
	. = ..()
	if(naut)
		return
	if(spores.len >= max_spores)
		return
	if(spore_delay > world.time)
		return
	flick("blob_factory_glow", src)
	spore_delay = world.time + spore_cooldown
	var/mob/living/simple_animal/hostile/blob/blobspore/BS = new/mob/living/simple_animal/hostile/blob/blobspore(src.loc, src)
	if(overmind) //if we don't have an overmind, we don't need to do anything but make a spore
		BS.overmind = overmind
		BS.update_icons()
		overmind.blob_mobs.Add(BS)

/obj/structure/blob/factory/lone //A blob factory that functions without a pulses

/obj/structure/blob/factory/lone/Initialize(mapload, owner_overmind)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/blob/factory/lone/process()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/structure/blob/factory/lone, Be_Pulsed)), 10 SECONDS, TIMER_UNIQUE)

/obj/structure/blob/factory/lone/Be_Pulsed()
	. = ..()

/obj/structure/blob/node/lone/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()
