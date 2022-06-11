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
	ld hl, MoveDeleterText2				
	call PrintText
	jp TextScriptEnd
.forgetMove
	ld a, $ff
	ld [wUpdateSpritesEnabled], a
	ld a, DELETE_PARTY_MENU
	ld [wPartyMenuTypeOrMessageID], a
	call DisplayPartyMenu 				;DisplayPartyMenu sets c if B is pressed 
	jp c, .cancel 	
	ld hl, wPartyMon1Moves
	ld bc, wPartyMon2Moves - wPartyMon1Moves
	ld a, [wWhichPokemon]
	call AddNTimes
	ld d, h
	ld e, l
	ld b, NUM_MOVES
	;de and hl storing a pointer to the move location for selected pokemon 
.findEmptyMoveSlotLoop
	ld a, [hl]
	and a
	jr z, .oneMoveCheck   ;jump if the move is $00 ie null
	inc hl 				  ;increment HL to check the next move 
	;b is storing NUM_MOVES, so don't jump to findEmptyMoveSlotLoop after 4 iterations
	dec b
	jr nz, .findEmptyMoveSlotLoop
	;if Pokémon only has one move, prevent player from removing it 
.oneMoveCheck
	ld a, $03 
	sub a, b
	and a 
	jr nz, .next 
	ld hl, MoveDeleterText7 
	call PrintText
	jr .forgetMove
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
	ld hl, MoveDeleterText3 
	call PrintText
	coord hl, 4, 7 
	ld b, 4
	ld c, 14
	call TextBoxBorder 	  ; Draws a c×b text box at hl
	coord hl, 6, 8
	ld de, wMovesString
	ld a, [hFlags_0xFFF6] ; Set bit 2 flag to 1
	set 2, a 			  ; What setting this flag does isn't documented :|
	ld [hFlags_0xFFF6], a
	call PlaceString 	  ; Draws the move String 
	ld a, [hFlags_0xFFF6] ; Set bit 2 flag to 0 (guess placeString needs that bit set)
	res 2, a
	ld [hFlags_0xFFF6], a
	;Set coordinates for selector arrow + set current menu item to 0 + Set num of menu items (num of moves)
	ld hl, wTopMenuItemY
	ld a, 8
	ld [hli], a 		  ; wTopMenuItemY
	ld a, 5
	ld [hli], a           ; wTopMenuItemX
	xor a
	ld [hli], a 		  ; wCurrentMenuItem
	inc hl
	ld a, [wNumMovesMinusOne]
	ld [hli], a 		  ; wMaxMenuItem
	ld a, A_BUTTON | B_BUTTON
	ld [hli], a 		  ; wMenuWatchedKeys
	ld [hl], 0 			  ; wLastMenuItem
	ld hl, hFlags_0xFFF6
	set 1, [hl] 		  ;Makes drawn menu double spaced 
	call HandleMenuInput  ;Register a stores which button was pressed 
	ld hl, hFlags_0xFFF6
	res 1, [hl]
	bit 1, a
	jp z, .confirm  	
	jp .forgetMove        ;Loops to displaying pokemon window again
.confirm 				  ;Copies selected move name from wMovesString to wTempMoveNameBuffer	 
	ld hl, wCurrentMenuItem
	ld b, [hl]
	push bc 		   	 ;Pop this when we delete a move (so we know which move is deleted)
	ld b, 0
	ld c, 0
	inc [hl]
	ld hl, wMovesString
.nameLoop
	ld a, b
	push hl
	ld hl, wCurrentMenuItem
	xor a, [hl]
	pop hl 
	jr z, .copy
	ld d, h
	ld e, l 
	ld c, 0 
.charLoop
	ld a, [hli]
	inc c
	xor a, $4e 			;$4e is the line break char, used here to delineate between different moves 
	jr nz, .charLoop
	inc b
	jr .nameLoop
.copy
	dec hl 
	ld [hl], "@"        ;"@" character temporarally replaces $4e 
	push hl 			;so copied data has a terminator and doesn't print garbage
	ld b, 0
	ld h, d 
	ld l, e 
	ld de, wTempMoveNameBuffer
	call CopyData
	pop hl
	ld [hl], $4e
	ld hl, MoveDeleterText4
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	pop bc 				;this will always pop bc of the stack regardless if the player cancled or not 
	jp nz, .cancel
	push bc 			;we'll need this later if the player didn't cancel 
;forgetMove
	ld de, wPartyMons 
	ld a, $08 			;$08 is the number of bytes away from wPartyMons the first move is located 
	add a, e 
	ld e, a
	ld a, [wWhichPokemon]
	ld c, a
.monLoop 				;Calculate memory location of selected pokemon 
	ld a, c 
	and a 
	jr z, .moveLoop 
	dec c 
	ld a, $2C 			;$2C is the number of bytes a party mon takes up, adding 2C gets us the next pokemon
	add a, e 
	jr nc, .noCarry 
	inc d 
.noCarry 
	ld e, a 
	jr .monLoop 
.moveLoop  				;Calculate memory location of selected pokemon's setlected move 
	ld a, b 			;de stores address to selected pokemons first move, b the move we selected 
	and a 
	jr z, .deleteMove 
	dec b 
	inc de 
	jr .moveLoop
.deleteMove  			;Delete move at calculated address 
	xor a 
	ld [de], a
.shiftMoves 			;Shift all lower moves up one 
	pop bc 				;b stores selected move index 
	ld a, $03 			; 3 - move index == number of swaps we need to do 
	sub a, b
	and a 
	jr z, .success 		;Don't shift anything if we're removing the fourth move  
	ld b, a 
	ld h, d
	ld l, e
	inc hl 
	ld c, $01
	push bc 			;b stores # of shifts, c stores $01 
	push hl 			;hl stores pointer to next move 
	push de 			;bc stores pointer to removed move 
.shiftLoop
	ld a, [hl]
	ld [de], a
	dec b 
	inc hl 
	inc de 
	ld a, b
	and a 
	jr nz, .shiftLoop   ;loop until b is 0 
	dec hl 
	xor a 
	ld [hl], a 			;zero out the last move (so we don't have double moves)
;PP shift 
	ld a, c  			;if c is 0 we've already shifted pp 
	and a 
	jr z, .success
	ld bc, $15 			;pp data is $15 bytes away from move data
	pop hl 				;so we add $15 to hl and de 
	add hl, bc 			;yes we are doing some stack trickery here to save some cycles 
	ld d, h 
	ld e, l 
	pop hl 
	add hl, bc 
	pop bc 
	dec c 				;dec c so we don't shift things 15 bytes after pp! 
	jr .shiftLoop		;shift the pp values
.cancel
	ld hl, MoveDeleterText6
	push hl 
	jr .end
.success
	ld hl, wTempMoveNameBuffer 	
	ld bc, 11 			;Replace the last character with @ so it prints correctly 
	add hl, bc 			;This only effects 17/167 moves, I'm saying its worthwhile
	ld [hl], "@"
	ld hl, MoveDeleterText8
	push hl 
.end 
	call GBPalWhiteOutWithDelay3
	call RestoreScreenTilesAndReloadTilePatterns
	call LoadGBPal
	pop hl 
	call PrintText
	jp TextScriptEnd


MoveDeleterText1:
	TX_FAR _FuchsiaHouse4Text1
	db "@"

MoveDeleterText2:
	TX_FAR _FuchsiaHouse4Text2
	db "@"

MoveDeleterText3:
	TX_FAR _FuchsiaHouse4Text3
	db "@"

MoveDeleterText4:
	TX_FAR _FuchsiaHouse4Text4
	db "@"

MoveDeleterText5:
	TX_FAR _FuchsiaHouse4Text5
	db "@"

MoveDeleterText6:
	TX_FAR _FuchsiaHouse4Text6
	db "@"

MoveDeleterText7:
	TX_FAR _FuchsiaHouse4Text7
	db "@"

MoveDeleterText8:
	TX_FAR _FuchsiaHouse4Text8
	db "@"
