RedsHouse1FScript:
	jp EnableAutoTextBoxDrawing

RedsHouse1FTextPointers:
	dw RedsHouse1FText1
	dw RedsHouse1FText2
	dw RedsHouse1FText3

RedsHouse1FText1: ; Mom
	TX_ASM

	CheckEvent EVENT_GOT_POKEDEX		;Have Pokedex
	jr z, .check
	CheckEvent EVENT_GOT_RUNNING_SHOES	;Do not have running shoes
	jr nz, .check

	ld hl, MomRunningShoesText
	call PrintText
	SetEvent EVENT_GOT_RUNNING_SHOES
	jp .done

.check
	ld a, [wd72e]
	bit 3, a
	jr nz, .heal ; if player has received a Pokémon from Oak, heal team
	ld hl, MomWakeUpText
	call PrintText
	jr .done
.heal
	call MomHealPokemon
.done
	jp TextScriptEnd

MomWakeUpText:
	TX_FAR _MomWakeUpText
	db "@"

MomRunningShoesText:
	TX_FAR _MomRunningShoesText
	db "@"

MomHealPokemon:
	ld hl, MomHealText1
	call PrintText
	call GBFadeOutToWhite
	call ReloadMapData
	predef HealParty
	ld a, MUSIC_PKMN_HEALED
	ld [wNewSoundID], a
	call PlaySound
.next
	ld a, [wChannelSoundIDs]
	cp MUSIC_PKMN_HEALED
	jr z, .next
	ld a, [wMapMusicSoundID]
	ld [wNewSoundID], a
	call PlaySound
	call GBFadeInFromWhite
	ld hl, MomHealText2
	jp PrintText

MomHealText1:
	TX_FAR _MomHealText1
	db "@"
MomHealText2:
	TX_FAR _MomHealText2
	db "@"

RedsHouse1FText2: ; Mr. Mime
	TX_ASM
	ld a, $2A
	call GetCryData
	call PlaySound
	ld hl, MrMimeText1
	call PrintText
	jp TextScriptEnd

MrMimeText1:
	TX_FAR _MrMimeText
	db "@"

RedsHouse1FText3: ; TV
	TX_ASM
	ld a, [wSpriteStateData1 + 9]
	cp SPRITE_FACING_UP
	ld hl, TVWrongSideText
	jr nz, .notUp
	ld hl, StandByMeText
	ld a, [wPlayerGender]
	cp $01
	jr nz, .notUp
	ld hl, WizardOfOzText
.notUp
	call PrintText
	jp TextScriptEnd

StandByMeText:
	TX_FAR _StandByMeText
	db "@"

TVWrongSideText:
	TX_FAR _TVWrongSideText
	db "@"

WizardOfOzText:
	TX_FAR _WizardOfOzText
	db "@"


