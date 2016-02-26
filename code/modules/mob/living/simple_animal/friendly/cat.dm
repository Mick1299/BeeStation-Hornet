//Cat
/mob/living/simple_animal/pet/cat
	name = "cat"
	desc = "Kitty!!"
	icon = 'icons/mob/pets.dmi'
	icon_state = "cat2"
	icon_living = "cat2"
	icon_dead = "cat2_dead"
	gender = MALE
	speak = list("Meow!", "Esp!", "Purr!", "HSSSSS")
	speak_emote = list("purrs", "meows")
	emote_hear = list("meows", "mews")
	emote_see = list("shakes its head", "shivers")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	ventcrawler = 2
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_SMALL
	minbodytemp = 200
	maxbodytemp = 400
	unsuitable_atmos_damage = 1
	species = /mob/living/simple_animal/pet/cat
	childtype = /mob/living/simple_animal/pet/cat/kitten
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab = 2)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	var/turns_since_scan = 0
	var/mob/living/simple_animal/mouse/movement_target
	gold_core_spawnable = 2

/mob/living/simple_animal/pet/cat/space
	name = "space cat"
	desc = "It's a cat... in space!"
	icon_state = "spacecat"
	icon_living = "spacecat"
	icon_dead = "spacecat_dead"
	unsuitable_atmos_damage = 0
	minbodytemp = TCMB
	maxbodytemp = T0C + 40

/mob/living/simple_animal/pet/cat/kitten
	name = "kitten"
	desc = "D'aaawwww"
	icon_state = "kitten"
	icon_living = "kitten"
	icon_dead = "kitten_dead"
	gender = NEUTER
	density = 0
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL

//RUNTIME IS ALIVE! SQUEEEEEEEE~
/mob/living/simple_animal/pet/cat/Runtime
	name = "Runtime"
	desc = "Tends to show up in the strangest of places."
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	gender = FEMALE
	gold_core_spawnable = 0
	var/list/family = list()
	var/lives = 9
	var/memory_saved = 0

/mob/living/simple_animal/pet/cat/Runtime/New()
	if(lives > 9)
		desc += " Looks like a cat with [lives] lives left."
	Read_Memory()
	..()

/mob/living/simple_animal/pet/cat/Runtime/Life()
	if(!stat && ticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		Write_Memory()
	..()

/mob/living/simple_animal/pet/cat/Runtime/death()
	if(!memory_saved)
		Write_Memory(1)
	..()

/mob/living/simple_animal/pet/cat/Runtime/proc/Read_Memory()
	var/savefile/S = new /savefile("data/npc_saves/Runtime.sav")
	S["family"] 			>> family
	S["lives"]				>> lives

	if(isnull(family))
		family = list()

	if(isnull(lives))
		lives = 9

	if(lives <= 0)
		lives = 10 //Lowers to 9 in Write_Memory
		Write_Memory(1)
		qdel(src)

	for(var/cat_type in family)
		if(family[cat_type] > 0)
			for(var/i in 1 to family[cat_type])
				new cat_type(loc)

/mob/living/simple_animal/pet/cat/Runtime/proc/Write_Memory(dead)
	var/savefile/S = new /savefile("data/npc_saves/Runtime.sav")
	if(dead)
		S["lives"] 				<< lives - 1
	family = list()
	for(var/mob/living/simple_animal/pet/cat/C in mob_list)
		if(istype(C,type) || C.stat || !C.butcher_results) //That last one is a work around for hologram cats
			continue
		if(C.type in family)
			family[C.type] += 1
		else
			family[C.type] = 1
	S["family"]				<< family
	memory_saved = 1


/mob/living/simple_animal/pet/cat/Proc
	name = "Proc"
	gold_core_spawnable = 0

/mob/living/simple_animal/pet/cat/Life()
	if(!stat && !buckled)
		if(prob(1))
			emote("me", 1, pick("stretches out for a belly rub.", "wags its tail."))
			icon_state = "[icon_living]_rest"
			resting = 1
		else if (prob(1))
			emote("me", 1, pick("sits down.", "crouches on its hind legs."))
			icon_state = "[icon_living]_sit"
			resting = 1
		else if (prob(1))
			if (resting)
				emote("me", 1, pick("gets up and meows.", "walks around."))
				icon_state = "[icon_living]"
				resting = 0
			else
				emote("me", 1, pick("grooms its fur.", "twitches its whiskers."))

	//MICE!
	if((src.loc) && isturf(src.loc))
		if(!stat && !resting && !buckled)
			for(var/mob/living/simple_animal/mouse/M in view(1,src))
				if(!M.stat && Adjacent(M))
					emote("me", 1, "splats \the [M]!")
					M.splat()
					movement_target = null
					stop_automated_movement = 0
					break
			for(var/obj/item/toy/cattoy/T in view(1,src))
				if (T.cooldown < (world.time - 400))
					emote("me", 1, "bats \the [T] around with its paw!")
					T.cooldown = world.time

	..()

	make_babies()

	if(!stat && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 5)
			walk_to(src,0)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				for(var/mob/living/simple_animal/mouse/snack in oview(src,3))
					if(isturf(snack.loc) && !snack.stat)
						movement_target = snack
						break
			if(movement_target)
				stop_automated_movement = 1
				walk_to(src,movement_target,0,3)

/mob/living/simple_animal/pet/cat/attack_hand(mob/living/carbon/human/M)
	. = ..()
	switch(M.a_intent)
		if("help")
			wuv(1, M)
		if("harm")
			wuv(-1, M)

/mob/living/simple_animal/pet/cat/proc/wuv(change, mob/M)
	if(change)
		if(change > 0)
			if(M && stat != DEAD)
				flick_overlay(image('icons/mob/animal.dmi', src, "heart-ani2", MOB_LAYER+1), list(M.client), 20)
				emote("me", 1, "purrs!")
		else
			if(M && stat != DEAD)
				emote("me", 1, "hisses!")
