FuchsiaHouse4_h:
	db HOUSE ; tileset
	db FUCHSIA_HOUSE_4_HEIGHT, FUCHSIA_HOUSE_4_WIDTH ; dimensions (y, x)
	dw FuchsiaHouse4Blocks, FuchsiaHouse4TextPointers, FuchsiaHouse4Script ; blocks, texts, scripts
	db 0 ; connections
	dw FuchsiaHouse4Object ; objects
