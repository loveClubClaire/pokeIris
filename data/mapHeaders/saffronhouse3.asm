SaffronHouse3_h:
	db HOUSE ; tileset
	db SAFFRON_HOUSE_3_HEIGHT, SAFFRON_HOUSE_3_WIDTH ; dimensions (y, x)
	dw SaffronHouse3Blocks, SaffronHouse3TextPointers, SaffronHouse3Script ; blocks, texts, scripts
	db 0 ; connections
	dw SaffronHouse3Object ; objects
