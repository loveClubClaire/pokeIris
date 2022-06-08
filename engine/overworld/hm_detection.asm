 CheckForOverworldHMUse::
	predef GetTileAndCoordsInFrontOfPlayer
	ld a, [wCurMapTileset]
	and a ; OVERWORLD
	jr z, .overworld
	cp GYM
	jr z, .gym
	ld hl, HMWaterTilesets
	ld de, 1
	call IsInArray ; does the current map allow surfing?
	jr c, .waterTileset	
	ret
.overworld
	ld a, [wTileInFrontOfPlayer]
	cp $3d ; cut tree
	jr z, .canCut
	jr .waterTileset
.gym
	ld a, [wTileInFrontOfPlayer]
	cp $50 ; gym cut tree
	jr z, .canCut
.waterTileset
	ld a, [wWalkBikeSurfState] ;No menu if player is already surfing
	cp $02
	jr z, .cantSurf
	ld a, [wTileInFrontOfPlayer]
	ld hl, HMSurfTiles
	ld de, 1
	call IsInArray
	;cp $14 ; water tile
	jr c, .canSurf
	ret

.canCut
	call EnableAutoTextBoxDrawing
	tx_pre_jump OverworldCutText
.canSurf ;Do work here because no text box is drawn if we can't surf
	ld a, [wObtainedBadges] ; badges obtained
	bit 4, a ; does the player have the Soul Badge?
	jr z, .cantSurf
	ld b, $39	;Store the HM we're searching for in b for IsHMInParty
 	call IsHMInParty
 	jr z, .callSurfText
 	;Surfboard item check 
 	ld b, $07
 	predef GetQuantityOfItemInBag
 	ld a, b
	and a
	jr z, .cantSurf
	;;Store surfboard item name into memory 
	ld a, $07
	ld [wd11e], a
	call GetItemName
.callSurfText
	call EnableAutoTextBoxDrawing
	tx_pre_jump OverworldSurfText
.cantSurf
	ret

; tilesets with water (OVERWORLD & GYM belong in this list but are manually checked for earlier hence their removal)
HMWaterTilesets:
	db  FOREST, DOJO, SHIP, SHIP_PORT, CAVERN, FACILITY, PLATEAU
	db $ff ; terminator

; shore tiles
HMSurfTiles:
	db $48, $32, $14
	db $ff ; terminator
	
OverworldCutText:
	TX_ASM
	ld a, [wObtainedBadges] ; badges obtained
	bit 1, a ; does the player have the Cascade Badge?
	jr z, .canNotBeCut

	ld b, $0F	;Store the HM we're searching for in b for IsHMInParty
 	call IsHMInParty
 	jr z, .canBeCut

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
	jp TextScriptEnd

OverworldSurfText:
	TX_ASM
	callba IsSurfingAllowed ;Handles can not surf error messages 
	ld hl, wd728
	bit 1, [hl]
	res 1, [hl]
	jp z, .didNotSurf 
	ld hl, AskToUseSurfText
	call PrintText
	ld a, 1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	cp $01
	jr nz, .didSurf
.didNotSurf
	jp TextScriptEnd

.didSurf
	ld a, SURFBOARD
	ld [wcf91], a
	ld [wPseudoItemID], a
	call UseItem
	ld [wUnusedCC5B], a
	jp TextScriptEnd

;TODO more testing 
;b stores HM being searched for 
;Returns z if HM is found, nz otherwise 
IsHMInParty:
	;Routine which checks if anyone in the party has given HM.
	;Searches list from 0-5 and first pokemon with HM has their name used
	;c counts which move we're looking at 
	;d stores the number of pokemon in the party 
	;e stores which pokemon in the party we're looking at 
	xor a 
	ld e, a
	ld [wWhichPokemon], a
	ld a, [wPartyCount]
	ld d, a
	ld hl, wPartyMons
	ld a, b 					;Preserve value of b for later
	ld bc, $08					;Offset of first attack from wPartyMonX
	add hl, bc
	ld b, a
.checkTeamMovesLoop
	ld a, [hl]
	cp b						;Check if move at hl is the given HM 
	jr z, .foundHM 				;If yes, found HM 
	;ret z 						;If yes, return 
	inc hl 						;Check next move 
	inc c 						;Increment move counter 
	ld a, c 
	cp $0C 						;08 + 4 moves is 0C. If move counter is 0C increment pokemon counter 
	jr nz, .checkTeamMovesLoop  
	ld a, b
	ld bc, $28					;+$28 gets the first move of the next mon in party
	add hl, bc
	ld c, $08 					;Set c back to $08 for move counter compare
	ld b, a
	inc e 
	ld a, e
	ld [wWhichPokemon], a       
	cp a, d 					;If theres more mons to check loop otherwise 
	jr nz, .checkTeamMovesLoop
	inc a 						;Set nz flag and return
	ret			 			    ;No mons know the HM
.foundHM
	call GetPartyMonName2       ;Store mon name at wcd6d
	xor a 						;set z flag as HM was found
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

BoulderCanBeMovedText:
	TX_FAR _BoulderOverworldText
	db "@"

AskToUseStrength:
	TX_FAR _AskToUseStrengthText
	db "@"

UsedStrengthOverworldText:
	TX_FAR _UsedStrengthText
	db "@"

StrengthInUse:
	TX_FAR _StrengthInUseText
	db "@"

AskToUseSurfText:
	TX_FAR _AskToUseSurfText
	db "@"	

OverworldUseStrength::
	ld hl, wd728 				;Check if Strength is already in use 
	bit 0, [hl]
	jr z, .strengthNotInUse
	ld hl, StrengthInUse
	call PrintText
	ret

.strengthNotInUse
	ld a, [wObtainedBadges] 	
	bit 3, a 					;Does the player have the Rainbow Badge?
	jr z, .canNotUseStrength
	ld b, $46					;Store the HM we're searching for in b for IsHMInParty
 	call IsHMInParty
 	jr z, .canUseStrength

.canNotUseStrength
	ld hl, BoulderCanBeMovedText
	call PrintText
	ret

.canUseStrength
	ld a, [wWhichPokemon]
	ld hl, wPartyMonNicks
	call GetPartyMonName
	ld hl, AskToUseStrength
	call PrintText
	ld a, 1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	cp $01
	ret z 						;Return if not using Strength
	ld hl, wd728 				;Set bit to enable Strength
	set 0, [hl]
	ld hl, UsedStrengthOverworldText
	call PrintText
	;Get the ID of pokemon using Strength for the cry
	ld bc, $2C
	ld hl, $d16b
	ld a, [wWhichPokemon]
.cryLoop
	cp $00 
	jr z, .loadCry
	add hl, bc 
	dec a 
	jr .cryLoop
.loadCry
	ld a, [hl]
	call PlayCry
	call Delay3
	ret