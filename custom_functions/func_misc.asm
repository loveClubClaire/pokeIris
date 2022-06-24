; This function called to store PKMN Levels. Usually at the beginning of battle.
StorePKMNLevels:
	push hl
	push de
	ld a, [wPartyCount]	;1 to 6
	ld b, a	;use b for countdown
	ld hl, wPartyMon1Level
	ld de, wStartBattleLevels
.loopStorePKMNLevels
	ld a, [hl]
	ld [de], a	
	dec b
	jr z, .doneStorePKMNLevels
	push bc
	ld bc, wPartyMon2 - wPartyMon1
	add hl, bc
	inc de
	pop bc
	jr .loopStorePKMNLevels
.doneStorePKMNLevels
	pop de
	pop hl
	ret

PrintNumPKMNInBox:
	;get mon count for currentMenu box, stored in a
	ld de, wBoxMonCounts
	ld a, [wCurrentMenuItem]
	add a, e
	ld e, a
	ld a, [de]
	;Make the first digit 0 or 1 or just print 20
	ld d, " "
	cp $0A
	jr c, .printFirstDigit
	ld d, "1"
	cp $14
	jr c, .printFirstDigit
	;If box full, print 20 without doing math
	coord hl, 14, 16
	ld [hl], "0"
	coord hl, 13, 16
	ld [hl], "2"
	ret
.printFirstDigit
	coord hl, 13, 16
	ld [hl], d
	cp $0A
	jr c, .printSecondDigit
	sub $0A
.printSecondDigit
	add $F6 		;F6 is Hex for the 0 character and adding it to a gets us the needed digit
	coord hl, 14, 16
	ld [hl], a
	ret