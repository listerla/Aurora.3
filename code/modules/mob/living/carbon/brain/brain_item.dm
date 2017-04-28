/obj/item/organ/brain
	name = "brain"
	health = 400 //They need to live awhile longer than other organs. Is this even used by organ code anymore?
	desc = "A piece of juicy meat found in a person's head."
	organ_tag = "brain"
	parent_organ = "head"
	vital = 1
	icon_state = "brain2"
	force = 1.0
	w_class = 2.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = list(TECH_BIO = 3)
	attack_verb = list("attacked", "slapped", "whacked")
	var/mob/living/carbon/brain/brainmob = null
	var/lobotomized = 0
	var/can_lobotomize = 1

/obj/item/organ/pariah_brain
	name = "brain remnants"
	desc = "Did someone tread on this? It looks useless for cloning or cyborgification."
	organ_tag = "brain"
	parent_organ = "head"
	icon = 'icons/mob/alien.dmi'
	icon_state = "chitin"
	vital = 1

/obj/item/organ/brain/xeno
	name = "thinkpan"
	desc = "It looks kind of like an enormous wad of purple bubblegum."
	icon = 'icons/mob/alien.dmi'
	icon_state = "chitin"

/obj/item/organ/brain/New()
	..()
	health = config.default_brain_health
	spawn(5)
		if(brainmob && brainmob.client)
			brainmob.client.screen.len = null //clear the hud

/obj/item/organ/brain/Destroy()
	if(brainmob)
		qdel(brainmob)
		brainmob = null
	..()

/obj/item/organ/brain/proc/transfer_identity(var/mob/living/carbon/H)
	name = "\the [H]'s [initial(src.name)]"
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna.Clone()
	brainmob.timeofhostdeath = H.timeofdeath
	if(H.mind)
		H.mind.transfer_to(brainmob)

	brainmob << "<span class='notice'>You feel slightly disoriented. That's normal when you're just a [initial(src.name)].</span>"
	callHook("debrain", list(brainmob))

/obj/item/organ/brain/examine(mob/user) // -- TLE
	..(user)
	if(brainmob && brainmob.client)//if thar be a brain inside... the brain.
		user << "You can feel the small spark of life still left in this one."
	else
		user << "This one seems particularly lifeless. Perhaps it will regain some of its luster later.."

/obj/item/organ/brain/removed(var/mob/living/user)

	name = "[owner.real_name]'s brain"

	var/mob/living/simple_animal/borer/borer = owner.has_brain_worms()

	if(borer)
		borer.detatch() //Should remove borer if the brain is removed - RR

	var/obj/item/organ/brain/B = src
	if(istype(B) && istype(owner))
		B.transfer_identity(owner)

	..()

/obj/item/organ/brain/replaced(var/mob/living/target)

	if(target.key)
		target.ghostize()

	if(brainmob)
		if(brainmob.mind)
			brainmob.mind.transfer_to(target)
		else
			target.key = brainmob.key
	..()

/obj/item/organ/brain/proc/lobotomize(mob/user as mob)
	lobotomized = 1

	if(owner)
		owner << "<span class='danger'>As part of your brain is drilled out, you feel your past self, your memories, your very being slip away...</span>"
		owner << "<b>You have been lobotomized. Your memories and your former life have been surgically removed from your brain, and while you are lobotomized you remember nothing that ever came before this moment.</b>"

	else if(brainmob)
		brainmob << "<span class='danger'>As part of your brain is drilled out, you feel your past self, your memories, your very being slip away...</span>"
		brainmob << "<b>You have been lobotomized. Your memories and your former life have been surgically removed from your brain, and while you are lobotomized you remember nothing that ever came before this moment.</b>"

	return

/obj/item/organ/brain/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/surgicaldrill))
		if(!lobotomized)
			user.visible_message("<span class='danger'>[user] drills [src] deftly with [W], severing part of the brain!</span>")
			lobotomize(user)
		else
			user << "<span class='notice'>The brain has already been operated on!</span>"
	..()

/obj/item/organ/brain/process()
	..()

	if(!owner)
		return

	if(lobotomized && (owner.getBrainLoss() < 50)) //lobotomized brains cannot be healed with chemistry. Part of the brain is irrevocably missing. Can be fixed magically with cloning, ofc.
		owner.setBrainLoss(50)

/obj/item/organ/brain/slime
	name = "slime core"
	desc = "A complex, organic knot of jelly and crystalline particles."
	robotic = 2
	icon = 'icons/mob/slimes.dmi'
	icon_state = "green slime extract"
	can_lobotomize = 0

/obj/item/organ/brain/golem
	name = "chelm"
	desc = "A tightly furled roll of paper, covered with indecipherable runes."
	robotic = 2
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	can_lobotomize = 0
