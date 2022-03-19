; Blinking LED: every 1008 ms 
; 
; Created: 18/03/2022 12:42:45
; Author : Andrés Alippi
;
; I extracted an example from book "AVR Microcontroller and Embedded Systems" and modified it.

; .INCLUDE "tn85def.inc"
.EQU		COUNTER = 127			;auxiliar counter for extra delay

.ORG		0x0						;location for reset
			RJMP		MAIN			
.ORG		0x16					;location for Timer0 overflow 
			RJMP		T0_OV_ISR	;jump to ISR for Timer0

.ORG		0x100
MAIN:		LDI		R20, HIGH(RAMEND)
			OUT		SPH, R20
			LDI		R20, LOW(RAMEND)
			OUT		SPL, R20		;initialize stack
			SBI		DDRB, 1			;PB1 as an output (onboard led on my sparkfun ATtiny85)

			LDI		R20, (1<<TOIE0)
			OUT		TIMSK, R20		;enable Timer0 overflow interrupt
			SEI						;set I (enable interrupts globally)

			LDI		R20, 0			;timer value for 32us ((1 / 8x10e6) x 256) 
			OUT		TCNT0, R20		;load Timer0 with 0 (TCNT0 will count from 0 to 255)
			LDI		R20, 0x04
			OUT		TCCR0B, R20		;Normal, internal clock 8MHz, prescaler x 256
			LDI		R20, 0x00

			LDI		R21, COUNTER	;R21 = 127 (decimal)
			
;------------------- Infinite Loop
LOOP:		
			RJMP	LOOP

;------------------- ISR for Timer0 (it is executed every 8192us)
.ORG		0x200
T0_OV_ISR:	
			DEC		R21
			BRNE	T0_REINIT
			RCALL	TOGGLE

T0_REINIT:	LDI		R16, 0			;timer value for 32us
			OUT		TCNT0, R16		;load Timer0 with 0 (for next round)
			RETI					;return from interrupt

TOGGLE:		
			IN		R16, PORTB		;read PORTB
			LDI		R17, 0x02		;00000010 for toggling PB1
			EOR		R16, R17
			OUT		PORTB, R16		;toggle PB0
			LDI		R21, COUNTER	;R21 = 127 (decimal)
			RET
