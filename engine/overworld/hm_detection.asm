CheckForOverworldHMUse::
	predef GetTileAndCoordsInFrontOfPlayer
	ld a, [wCurMapTileset]
	and a ; OVERWORLD
	jr z, .overworld
	cp GYM
	jr nz, .nothingToCut
	ld a, [wTileInFrontOfPlayer]
	cp $50 ; gym cut tree
	jr nz, .nothingToCut
	jr .canCut
.overworld
	dec a
	ld a, [wTileInFrontOfPlayer]
	cp $3d ; cut tree
	jr z, .canCut
.nothingToCut
	ret
.canCut
	call EnableAutoTextBoxDrawing
	tx_pre_jump OverworldHMText
	
OverworldHMText:
	TX_ASM
	ld a, [wObtainedBadges] ; badges obtained
	bit 1, a ; does the player have the Cascade Badge?
	jr z, .canNotBeCut
;TODO more testing 

	;Routine which checks if anyone in the party has cut.
	;Searches list from 0-5 and first pokemon with cut has their name used
	;c counts which move we're looking at 
	;d stores the number of pokemon in the party 
	;e stores which pokemon in the party we're looking at 
	xor a 
	ld e, a
	ld [wWhichPokemon], a
	ld a, [wPartyCount]
	ld d, a
	ld hl, wPartyMons
	ld bc, $08					;Offset of first attack from wPartyMonX
	add hl, bc
.checkTeamMovesLoop
	ld a, [hl]
	cp $0F						;Check if move at hl is cut 
	jr z, .canBeCut 			;If yes, ask if player wants to cut 
	inc hl 						;Check next move 
	inc bc 						;Increment move counter 
	ld a, c 
	cp $0C 						;08 + 4 moves is 0C. If move counter is 0C increment pokemon counter 
	jr nz, .checkTeamMovesLoop  
	ld bc, $28					;+$28 gets the first move of the next mon in party
	add hl, bc
	ld bc, $08 					;Set bc back to $08 for move counter compare
	inc e 
	ld a, e
	ld [wWhichPokemon], a       
	cp a, d 					;If theres more mons to check loop otherwise 
	jr nz, .checkTeamMovesLoop
	jr .canNotBeCut 			;No mons know cut 


.canNotBeCut
	ld hl, TreeCanBeCutText
	call PrintText
	jr z, .didNotCut
	
.canBeCut
	ld hl, AskToUseCutText
	call PrintText
	ld a, 1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	cp $01
	jr nz, .didCut
.didNotCut
	jp TextScriptEnd

.didCut
	ld [wCutTile], a
	ld a, 1
	ld [wActionResultOrTookBattleTurn], a ; used cut
	ld a, [wWhichPokemon]
	ld hl, wPartyMonNicks
	call GetPartyMonName
	ld hl, UsedCutOverworldText
	call PrintText
	ld a, $ff
	ld [wUpdateSpritesEnabled], a
	callab InitCutAnimOAM
	ld de, CutTreeBlockSwaps
	callab ReplaceTreeTileBlock
	callab RedrawMapView
	callab AnimCut
	ld a, $1
	ld [wUpdateSpritesEnabled], a
	ld a, SFX_CUT
	call PlaySound
	call UpdateSprites
	ret

UsedCutOverworldText:
	TX_FAR _UsedCutText
	db "@"

TreeCanBeCutText:
	TX_FAR _TreeCanBeCutText
	db "@"

AskToUseCutText:
	TX_FAR _AskToUseCutText
	db "@"	
