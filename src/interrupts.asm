INCLUDE "defines.inc"

SECTION "Interrupts", ROM0


DisableSTATInterrupts::
    xor a
    ld [rSTAT], a
    di

    ret


EnableSTATInterrupts::
    ;ld a, IE_STAT
    ld a, $02
    ld b, a
    ld a, [rIE]
    or a, b
    ldh [rIE], a
    xor a
    ldh [rIF], a
    ei
    
    ; This makes our STAT interrupt occur when current scanline is equal to the rLYC register
    ld a, STAT_LYC
    ldh [rSTAT], a

    ; Starting with the first scanline,
    ; The first STAT interrupt to be called when rLY = 0
    xor a
    ld [rLYC], a

    ret


SECTION "STAT Interrupt", ROM0[$0048]


StatInterrupt:
    push af

    ; Checking if we're on the first scanline
    ldh a, [rLY]
    and a
    jp z, .LYCIsZero

.LYCIs136:
    ; Don't call next STAT interrupt until scanline 8
    xor a
    ldh [rLYC], a

    ; Turning on LCD and Window Layer, but disabling sprites
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_WIN_ON | LCDC_WIN_9C00 | LCDC_OBJ_OFF | LCDC_OBJ_16
    ldh [hLCDC], a
    ldh [rLCDC], a

    jp StatInterruptEnd

.LYCIsZero:
    ; Don't call next STAT interrupt until scanline 8
    ld a, 136
    ldh [rLYC], a

    ; Turning on LCD and Sprites, but keeping window disabled
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_WIN_OFF | LCDC_WIN_9C00 | LCDC_OBJ_ON | LCDC_OBJ_16
    ldh [hLCDC], a
    ldh [rLCDC], a

StatInterruptEnd:
    pop af

    reti
