FuchsiaHouse4Script:
	jp EnableAutoTextBoxDrawing

FuchsiaHouse4TextPointers:
	dw FuchsiaHouse4Text1

FuchsiaHouse4Text1:
	TX_ASM
	call SaveScreenTilesToBuffer2
	ld hl, MoveDeleterText1
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jp z, .forgetMove
	ld hl, FluteNoRoomText
	call PrintText
	jp TextScriptEnd

.forgetMove
	
	ld a, $ff
	ld [wUpdateSpritesEnabled], a
	ld a, TMHM_PARTY_MENU
	ld [wPartyMenuTypeOrMessageID], a
	call DisplayPartyMenu ;DisplayPartyMenu sets c if B is pressed 
	jp c, .cancel 	

	ld hl, wPartyMon1Moves
	ld bc, wPartyMon2Moves - wPartyMon1Moves
	ld a, [wWhichPokemon]
	call AddNTimes
	ld d, h
	ld e, l
	ld b, NUM_MOVES
	;de and hl sotring a pointer to the move location for selected pokemon 

.findEmptyMoveSlotLoop
	ld a, [hl]
	and a
	jr z, .next ;jump if the move is $00 ie null
	inc hl 		;increment HL to check the next move 

	;b is storing NUM_MOVES, so don't jump to findEmptyMoveSlotLoop after 4 iterations
	dec b
	jr nz, .findEmptyMoveSlotLoop

	;At this point, de points to first move, hl points to null data or trainer ID
.next
	;Selcted pokemon moves are at hl, copy them to de, bc times 
	ld h, d
	ld l, e
	ld de, wMoves
	ld bc, NUM_MOVES
	call CopyData
	callab FormatMovesString

.loop
	ld hl, WhichMoveToForgetText ;Do we need to do a bank switch to access this text? How? lol
	call PrintText
	coord hl, 4, 7 
	ld b, 4
	ld c, 14
	call TextBoxBorder 	; Draws a c×b text box at hl
	coord hl, 6, 8
	ld de, wMovesString

	;Set bit 2 flag to 1
	ld a, [hFlags_0xFFF6] 
	set 2, a 			  ; What setting this flag does isn't documented :|
	ld [hFlags_0xFFF6], a
	call PlaceString 	  ; Draws the move String 

	;Set bit 2 flag to 0 (guess placeString needs that bit set)
	ld a, [hFlags_0xFFF6]
	res 2, a
	ld [hFlags_0xFFF6], a

	;Set coordinates for selector arrow + set current menu item to 0 + Set num of menu items (num of moves)
	ld hl, wTopMenuItemY
	ld a, 8
	ld [hli], a ; wTopMenuItemY
	ld a, 5
	ld [hli], a ; wTopMenuItemX
	xor a
	ld [hli], a ; wCurrentMenuItem
	inc hl
	ld a, [wNumMovesMinusOne]
	ld [hli], a ; wMaxMenuItem


	ld a, A_BUTTON | B_BUTTON
	ld [hli], a 	; wMenuWatchedKeys
	ld [hl], 0 		; wLastMenuItem
	ld hl, hFlags_0xFFF6
	set 1, [hl] 		 ;Makes drawn menu double spaced 
	call HandleMenuInput ;Register a stores which button was pressed 
	ld hl, hFlags_0xFFF6
	res 1, [hl]
	bit 1, a
	jp z, .confirm  	
	jp .forgetMove       ;Loops to displaying pokemon window again


.confirm
	ld hl, MrFujiAfterFluteText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jp z, .cancel
	jp .forgetMove

.DebugLoop2
	jr .DebugLoop2


	pop af
	pop hl
	bit 1, a 
	jr nz, .cancel
	push hl
	ld a, [wCurrentMenuItem]
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl]
	push af
	push bc
	call IsMoveHM
	pop bc
	pop de
	ld a, d
	jr c, .hm
	pop hl
	add hl, bc
	and a
	jr .cancel
.hm
	ld hl, HMCantDeleteText
	call PrintText
	pop hl
	;jr .loop



.cancel

	call GBPalWhiteOutWithDelay3
	call RestoreScreenTilesAndReloadTilePatterns
	call LoadGBPal

	ld hl, MrFujiAfterFluteText
	call PrintText

	jp TextScriptEnd


MoveDeleterText1:
	TX_FAR _FuchsiaHouse4Text1
	db "@"
