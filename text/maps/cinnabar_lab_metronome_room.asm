_TM35PreReceiveText::
	text "Tch-tch-tch!"
	line "I made a cool TM!"

	para "It can cause all"
	line "kinds of fun!"
	prompt

_ReceivedTM35Text::
	text "<PLAYER> received "
	line "@"
	TX_RAM wcf4b
	text "!@@"

_TM35ExplanationText::
	text "Tch-tch-tch!"
	line "That's the sound"
	cont "of a METRONOME!"

	para "It tweaks your"
	line "#MON's brain"
	cont "into using moves"
	cont "it doesn't know!"
	done

_TM35NoRoomText::
	text "Your pack is"
	line "crammed full!"
	done

_Lab3Text2::
	text "EEVEE can evolve"
	line "into 1 of 3 kinds"
	cont "of #MON."
	done

_Lab3Text3::
	text "There's an e-mail"
	line "message!"

	para "..."

	para "The 3 legendary"
	line "bird #MON are"
	cont "ARTICUNO, ZAPDOS"
	cont "and MOLTRES."

	para "Their whereabouts"
	line "are unknown."

	para "We plan to explore"
	line "the cavern close"
	cont "to CERULEAN."

	para "From: #MON"
	line "RESEARCH TEAM"

	para "..."
	done

_Lab3Text5::
	text "An amber pipe!"
	done

_TradeEvoText1::

	text "I research the"
	line "evolution of"
	cont "#MON!"
	
	para "My new invention"
	line "evolves them"
	cont "without trading!"

	para "Whatya say, wanna"
	line "give it a try?"
	done	

_TradeEvoText2::
	text "Oh... Well if you"
	line "change your mind."
	done
	

_TradeEvoText3::
	text "It won't have any"
	line "effect."
	prompt
	done

_TradeEvoText4::
	text "Another success!"
	done
	

_TradeEvoText5::
	text "My machine needs"
	line "to recharge..."

	para "Go walk around"
	line "for a while."
	done
	