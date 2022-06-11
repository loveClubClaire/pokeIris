Lab3Script:
	jp EnableAutoTextBoxDrawing

Lab3TextPointers:
	dw Lab3Text1
	dw Lab3Text2
	dw Lab3Text3
	dw Lab3Text4
	dw Lab3Text5
	dw Lab3Text6

Lab3Text1:
	TX_ASM
	CheckEvent EVENT_GOT_TM35
	jr nz, .asm_e551a
	ld hl, TM35PreReceiveText
	call PrintText
	lb bc, TM_35, 1
	call GiveItem
	jr nc, .BagFull
	ld hl, ReceivedTM35Text
	call PrintText
	SetEvent EVENT_GOT_TM35
	jr .asm_eb896
.BagFull
	ld hl, TM35NoRoomText
	call PrintText
	jr .asm_eb896
.asm_e551a
	ld hl, TM35ExplanationText
	call PrintText
.asm_eb896
	jp TextScriptEnd

TM35PreReceiveText:
	TX_FAR _TM35PreReceiveText
	db "@"

ReceivedTM35Text:
	TX_FAR _ReceivedTM35Text
	TX_SFX_ITEM_1
	db "@"

TM35ExplanationText:
	TX_FAR _TM35ExplanationText
	db "@"

TM35NoRoomText:
	TX_FAR _TM35NoRoomText
	db "@"

Lab3Text2:
	TX_FAR _Lab3Text2
	db "@"

Lab3Text4:
Lab3Text3:
	TX_FAR _Lab3Text3
	db "@"

Lab3Text5:
	TX_FAR _Lab3Text5
	db "@"

TradeEvoText1:
	TX_FAR _TradeEvoText1
	db "@"

TradeEvoText2:
	TX_FAR _TradeEvoText2
	db "@"

TradeEvoText3:
	TX_FAR _TradeEvoText3
	db "@"

TradeEvoText4:
	TX_FAR _TradeEvoText4
	db "@"

TradeEvoText5:
	TX_FAR _TradeEvoText5
	db "@"

Lab3Text6:
	TX_ASM
	call SaveScreenTilesToBuffer2
	ld hl, TradeEvoText1 
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jp z, .evolveTradeMon
	ld hl, TradeEvoText2		           		
	call PrintText
	jp TextScriptEnd
.evolveTradeMon

	;Initalize "which mons able" memory with 0 & 1 respectivally 
	xor a
	ld [wUnusedDA38], a
	inc a
	rrc a
	ld [wUnusedCD3D], a

	ld a, $1C
	ld [wEvoStoneItemID], a
	ld a, EVO_STONE_PARTY_MENU
	ld [wPartyMenuTypeOrMessageID], a
	ld a, $ff
	ld [wUpdateSpritesEnabled], a
	call DisplayPartyMenu ;DisplayPartyMenu sets c if B is pressed 
	;pop bc 				;?
	jr c, .canceledTradeEvo
	;ld a, b
	;ld [wcf91], a
	;load which mons can be evolved into c, 0 into b, whichMon into a
	ld a, [wUnusedDA38]
	ld c, a
	xor a
	ld b, a
	ld a, [wWhichPokemon] ;wWhichPokemon is postion in party 
	;shift until mon selected is bit 0 in c
.shiftLoop
	cp b
	jr z, .loopEnd
	sra c
	dec a 
	jr .shiftLoop
.loopEnd
	;if bit 0 is set, evolve mon, else don't 
	bit 0, c
	jr z, .noEffectTrade
	jr .canceledTradeEvo
	ld [wUnusedD08A], a
	ld a, $01
	ld [wForceEvolution], a
	ld a, SFX_HEAL_AILMENT
	call PlaySoundWaitForCurrent
	call WaitForSoundToFinish
	callab TryEvolvingMon ; try to evolve pokemon
	ld a, [wEvolutionOccurred]
	and a
	jr z, .noEffectTrade
	;pop af
	;ld [wWhichPokemon], a
.noEffectTrade
	ld hl, TradeEvoText3 ; TODO 
	call PrintText
	jp TextScriptEnd
.canceledTradeEvo
	call GBPalWhiteOutWithDelay3
	call RestoreScreenTilesAndReloadTilePatterns
	call LoadGBPal
	ld hl, TradeEvoText4 ; TODO 
	call PrintText
	jp TextScriptEnd



