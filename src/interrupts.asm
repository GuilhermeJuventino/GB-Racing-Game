INCLUDE "defines.inc"

SECTION "Interrupts", ROM0


DisableSTATInterrupts::
    xor a
    ld [rSTAT], a
    ld a, $FD ; $FD = Disable STAT
    ld b, a
    ld a, [rIE]
    and a, b ; Logical AND rIE with $FD to disable STAT Interrupts
    ldh [rIE], a

    ret


EnableSTATInterrupts::
    ld a, $02 ; $02 = Enable STAT
    ld b, a
    ld a, [rIE]
    or a, b ; Logical OR rIE with $02 to enable STAT Interrupts
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
    push af ; Pushing AF to the stack to avoid corruption of whatever value was stored there when this routine is called

    ; Checking if we're on the first scanline
    ldh a, [rLY]
    and a
    jp z, .LYIsZero

.LYIs135:
    ; Don't call next STAT interrupt until scanline 0
    xor a
    ldh [rLYC], a

    ; Turning on LCD and Window Layer, but disabling sprites
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_WIN_ON | LCDC_WIN_9C00 | LCDC_OBJ_OFF | LCDC_OBJ_16
    ldh [hLCDC], a
    ldh [rLCDC], a

    jp StatInterruptEnd

.LYIsZero:
    ; Don't call next STAT interrupt until scanline 135
    ld a, 135
    ldh [rLYC], a

    ; Turning on LCD and Sprites, but keeping window disabled
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_WIN_OFF | LCDC_WIN_9C00 | LCDC_OBJ_ON | LCDC_OBJ_16
    ldh [hLCDC], a
    ldh [rLCDC], a

StatInterruptEnd:
    pop af ; Popping AF back from the stack since the routine is over and we can resume game execution

    reti
