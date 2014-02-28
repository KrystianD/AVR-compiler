rjmp	.+36     	; 0x26 <__ctors_end>
rjmp	.+62     	; 0x42 <__bad_interrupt>
rjmp	.+60     	; 0x42 <__bad_interrupt>
rjmp	.+58     	; 0x42 <__bad_interrupt>
rjmp	.+86     	; 0x60 <__vector_4>
rjmp	.+54     	; 0x42 <__bad_interrupt>
rjmp	.+52     	; 0x42 <__bad_interrupt>
rjmp	.+50     	; 0x42 <__bad_interrupt>
rjmp	.+48     	; 0x42 <__bad_interrupt>
rjmp	.+46     	; 0x42 <__bad_interrupt>
rjmp	.+44     	; 0x42 <__bad_interrupt>
rjmp	.+42     	; 0x42 <__bad_interrupt>
rjmp	.+40     	; 0x42 <__bad_interrupt>
rjmp	.+38     	; 0x42 <__bad_interrupt>
rjmp	.+36     	; 0x42 <__bad_interrupt>
rjmp	.+34     	; 0x42 <__bad_interrupt>
rjmp	.+32     	; 0x42 <__bad_interrupt>
rjmp	.+30     	; 0x42 <__bad_interrupt>
rjmp	.+28     	; 0x42 <__bad_interrupt>

__ctors_end:
  eor	r1, r1
  out	0x3f, r1	; 63
  ldi	r28, 0xDF	; 223
  out	0x3d, r28	; 61

__do_clear_bss:
  ldi	r17, 0x00	; 0
  ldi	r26, 0x60	; 96
  ldi	r27, 0x00	; 0
  rjmp	.+2      	; 0x38 <.do_clear_bss_start>

do_clear_bss_loop:
  st	X+, r1

do_clear_bss_start:
  cpi	r26, 0x69	; 105
  cpc	r27, r17
  brne	.-8      	; 0x36 <.do_clear_bss_loop>
  rcall	.+292    	; 0x164 <main>
  rjmp	.+334    	; 0x190 <_exit>

__bad_interrupt:
  rjmp	.-68     	; 0x0 <__vectors>

ToggleCtrl:
  lds	r24, 0x0060
  cpse	r24, r1
  rjmp	.+10     	; 0x56 <ToggleCtrl+0x12>
  ldi	r24, 0x01	; 1
  sts	0x0060, r24
  cbi	0x11, 6	; 17
  rjmp	.+6      	; 0x5c <ToggleCtrl+0x18>
  sts	0x0060, r1
  sbi	0x11, 6	; 17
  cbi	0x12, 6	; 18
  ret

__vector_4:
  push	r1
  push	r0
  in	r0, 0x3f	; 63
  push	r0
  eor	r1, r1
  push	r18
  push	r19
  push	r20
  push	r21
  push	r22
  push	r23
  push	r24
  push	r25
  push	r26
  push	r27
  push	r30
  push	r31
  in	r18, 0x08	; 8
  lds	r24, 0x0063
  lds	r25, 0x0064
  adiw	r24, 0x01	; 1
  sts	0x0064, r25
  sts	0x0063, r24
  lds	r24, 0x0061
  lds	r25, 0x0062
  sbrs	r18, 5
  rjmp	.+66     	; 0xe4 <__stack+0x5>
  or	r24, r25
  breq	.+86     	; 0xfc <__stack+0x1d>
  lds	r24, 0x0063
  lds	r25, 0x0064
  sbiw	r24, 0x33	; 51
  brcs	.+40     	; 0xda <__vector_4+0x7a>
  lds	r24, 0x0065
  lds	r25, 0x0066
  lds	r26, 0x0067
  lds	r27, 0x0068
  adiw	r24, 0x01	; 1
  adc	r26, r1
  adc	r27, r1
  sts	0x0065, r24
  sts	0x0066, r25
  sts	0x0067, r26
  sts	0x0068, r27
  rcall	.-150    	; 0x44 <ToggleCtrl>
  sts	0x0062, r1
  sts	0x0061, r1
  rjmp	.+24     	; 0xfc <__stack+0x1d>
  or	r24, r25
  brne	.+20     	; 0xfc <__stack+0x1d>
  ldi	r24, 0x01	; 1
  ldi	r25, 0x00	; 0
  sts	0x0062, r25
  sts	0x0061, r24
  sts	0x0064, r1
  sts	0x0063, r1
  pop	r31
  pop	r30
  pop	r27
  pop	r26
  pop	r25
  pop	r24
  pop	r23
  pop	r22
  pop	r21
  pop	r20
  pop	r19
  pop	r18
  pop	r0
  out	0x3f, r0	; 63
  pop	r0
  pop	r1
  reti

UpdateLEDs:
  cbi	0x12, 5	; 18
  cbi	0x12, 2	; 18
  cbi	0x1b, 1	; 27
  lds	r24, 0x0065
  lds	r25, 0x0066
  lds	r26, 0x0067
  lds	r27, 0x0068
  andi	r24, 0x03	; 3
  eor	r25, r25
  eor	r26, r26
  eor	r27, r27
  cpi	r24, 0x02	; 2
  cpc	r25, r1
  cpc	r26, r1
  cpc	r27, r1
  breq	.+22     	; 0x15c <UpdateLEDs+0x3e>
  cpi	r24, 0x03	; 3
  cpc	r25, r1
  cpc	r26, r1
  cpc	r27, r1
  breq	.+16     	; 0x160 <UpdateLEDs+0x42>
  sbiw	r24, 0x01	; 1
  cpc	r26, r1
  cpc	r27, r1
  breq	.+8      	; 0x160 <UpdateLEDs+0x42>
  sbi	0x12, 5	; 18
  ret
  sbi	0x1b, 1	; 27
  ret
  sbi	0x12, 2	; 18
  ret

main:
  ldi	r24, 0x0B	; 11
  out	0x2e, r24	; 46
  ldi	r24, 0x7D	; 125
  ldi	r25, 0x00	; 0
  out	0x2b, r25	; 43
  out	0x2a, r24	; 42
  ldi	r24, 0x40	; 64
  out	0x39, r24	; 57
  sei
  sbi	0x11, 5	; 17
  sbi	0x11, 2	; 17
  sbi	0x1a, 1	; 26
  sbi	0x11, 6	; 17
  cbi	0x12, 6	; 18
  ldi	r24, 0xCF	; 207
  ldi	r25, 0x07	; 7
  sbiw	r24, 0x01	; 1
  brne	.-4      	; 0x184 <main+0x20>
  rjmp	.+0      	; 0x18a <main+0x26>
  nop
  rcall	.-112    	; 0x11e <UpdateLEDs>
  rjmp	.-16     	; 0x180 <main+0x1c>

_exit:
  cli

__stop_program:
  rjmp	.-2      	; 0x192 <__stop_program>

