; hello.a51 -- 'Hello World' on serial console.
;
; This small program is meant to be run on a light52 MCU on actual hardware,
; as a first sanity check.
;
; This version of the program does not use interrupts.
;
; If this program runs and displays its message on a terminal, you may then be
; sure that your development environment is working.
    
    
        ; Include the definitions for the light52 derivative
        $nomod51
        $include (light52.mcu)
    
        ;-- Data variable definitions ------------------------------------------
        
        ; These are general purpose variables for use in subroutines.
        ; They must be saved and restored before use.
        var0    data    030h        
    
        ; We'll place the stack above the reg banks and bit addressable area,
        ; leaving some space for our stuff (030h to 03fh).
        stack   set     040h
    
        ;-- Macros -------------------------------------------------------------
    
    
        ;-- Reset & interrupt vectors ------------------------------------------

        org     00h
        ljmp    start               ;
        org     03h
        ljmp    irq_unused
        org     0bh
        ljmp    irq_timer
        org     13h
        ljmp    irq_unused
        org     1bh
        ljmp    irq_unused
        org     23h
        ljmp    irq_uart

        ;-- Main test program --------------------------------------------------
        org     30h
start:

        ; Set up stack.
        mov     SP,#stack
        
        ; Clear ports P0 and P1, bearing in mind that on the demo platform,
        ; P0 is looped back into P2 and P1 to P3, and P1 is also connected to
        ; the external irq inputs.
        mov     P0,#000h
        mov     P1,#000h

        ; Initialize serial port...
        ; (actually, leave it with its default configuration: 19200-8-N-1)

        ; ...and dump the hello string to the serial port.
        mov     DPTR,#text0
        call    po_cstr

        ; End of test program, enter single-instruction endless loop.
        ; The timer will keep triggering interrupts indefinitely.
quit:   ajmp    $

; po_char:  Print character in ACC to console.
po_char:
        mov     SBUF,a
        ; We need to skip TXRDY check if this is going to run on a simulation.
        ; Otherwise run times would be impractically long.
        ifndef SIMULATED_UART
po_char_loop:
        jnb     TXRDY,po_char_loop
        endif
        ret

; po_cstr:  Prints zero-terminated string at XCODE:DPTR to console.
;           Returns after the whole string has been output.
po_cstr:
        push    var0
        mov     var0,#000h
po_cstr_loop:
        mov     a,var0
        inc     var0
        movc    a,@a+DPTR
        jz      po_cstr_done
        call    po_char
        sjmp    po_cstr_loop
po_cstr_done:
        pop     var0
        ret

        ; Unused interrupt routines, will never be reached.
irq_unused:
        reti
irq_uart:
        reti
irq_timer:
        reti

text0:  db      'Hello World!',13,10,00h,00h
        end
