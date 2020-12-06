;------------------------------------------------------------------                                             
!zone MemoryCopy
MemoryCopy
  ldx PARAM2

  ldy #0
.MemoryCopyLoop

  ; Decrement 16-bit size/counter.
  txa
  bne .decrementSizeLo
  lda PARAM3
  beq .MemoryCopyEnd
.decrementSizeHi
  dec PARAM3
.decrementSizeLo
  dex
  
.CopyByte
  ; Copy one byte.
  lda (ZEROPAGE_POINTER_1),y
  sta (ZEROPAGE_POINTER_2),y
  
  ; Increment Y index.
  iny
  bne .MemoryCopyLoop
  
  ; if Y index wraps around.
  ; Increment hi-byte of source/destination addresses 
  inc ZEROPAGE_POINTER_1+1
  inc ZEROPAGE_POINTER_2+1

  jmp .MemoryCopyLoop
  
.MemoryCopyEnd
  rts
  
;------------------------------------------------------------------                                             
; !zone MemoryCopyToRegister
; MemoryCopyToRegister
;   ldy #0
; .MemoryCopyLoop
; 
;   ; Decrement 16-bit size/counter.
;   lda PARAM1
;   bne .decrementSizeLo
;   lda PARAM2
;   beq .MemoryCopyEnd
; .decrementSizeHi
;   dec PARAM2
; .decrementSizeLo
;   dec PARAM1
;   
; .CopyByte
;   ; Copy one byte.
;   tya
;   tax
;   lda (ZEROPAGE_POINTER_1),y
;   ldy #0
;   sta (ZEROPAGE_POINTER_2),y
;   ;sta VRAM_ADDRESS_REG
;   txa
;   tay
;   
;   ; Increment Y index.
;   iny
;   bne .MemoryCopyLoop
;   
;   ; if Y index wraps around.
;   ; Increment hi-byte of source address 
;   inc ZEROPAGE_POINTER_1+1
; 
;   jmp .MemoryCopyLoop
;   
; .MemoryCopyEnd
;   rts

;------------------------------------------------------------------                                             
!zone MemoryFill
MemoryFill
  ldx PARAM2

  ldy #0
.MemoryFillLoop

  ; Decrement 16-bit size/counter.
  txa
  bne .decrementSizeLo
  lda PARAM3
  beq .MemoryFillEnd
.decrementSizeHi
  dec PARAM3
.decrementSizeLo
  dex
  
.SetByte
  ; Copy one byte.
  lda PARAM1
  sta (ZEROPAGE_POINTER_2),y
  
  ; Increment Y index.
  iny
  bne .MemoryFillLoop
  
  ; if Y index wraps around.
  ; Increment hi-byte of destination address 
  inc ZEROPAGE_POINTER_2+1
  
  jmp .MemoryFillLoop
  
.MemoryFillEnd
  rts
