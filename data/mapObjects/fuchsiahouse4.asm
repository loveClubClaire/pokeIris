FuchsiaHouse4Object:
	db $a ; border block

	db 2 ; warps
	warp 2, 7, 9, -1
	warp 3, 7, 9, -1

	db 0 ; signs

	db 1 ; objects
	object SPRITE_CABLE_CLUB_WOMAN,  2,  3, STAY, NONE, 1 ; person

	; warp-to
	warp_to 2, 7, FUCHSIA_HOUSE_4_WIDTH
	warp_to 3, 7, FUCHSIA_HOUSE_4_WIDTH
