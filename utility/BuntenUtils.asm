; ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦ S U B R O U T I N E ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
; input                                                                      
; A: left operand                                                            
; Y: right operand                                                           
; output                                                                     
; Y/A, PARAM2/PARAM3: A * Y                                                
; Attributes: hidden                                                         
mul8BitsBy8Bits:              ; ...                                          
  STA   PARAM1               ; PARAM1 = A // MPD                           
  STY   PARAM2               ; PARAM2 = Y // MPR                           
  LDA   #0                    ; A = 0                                        
  STA   PARAM3               ; PARAM3 = 0 // PRODL                         
  LDX   #8                    ; X = 8                                        
loc_113A:                     ; ...                                          
  LSR   PARAM2               ; do {                                         
                              ;   PARAM2 >>C                                
  BCC   loc_1141              ;   if (C == 1) {                              
  CLC                         ;     C = 0                                    
  ADC   PARAM1               ;     A += PARAM1                             
                              ;   }                                          
loc_1141:                     ; ...                                          
  ROR                        ;   A C>>C                                     
  ROR   PARAM3               ;   PARAM3 C>>C                               
  DEX                         ;   X --                                       
  BNE   loc_113A              ; } while (X != 0)                             
  TAY                         ; Y = A // PRODH                               
  STA   PARAM2               ; PARAM2 = A                                  
  LDA   PARAM3               ; A = PARAM3 // PRODL                         
  RTS                                                                        
; End of function mul8BitsBy8Bits                                            
; ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦ S U B R O U T I N E ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
; input                                                                      
; X: Divisor                                                                
; Y/A: Numerator                                                            
; output                                                                     
; Y: Remainder                                                                   
; A: Result                                                                
; Attributes: hidden                                                         
div8Bits:                     ; ...                                          
  STX   PARAM1               ; PARAM1 = X // Divisor                      
  STA   PARAM2               ; PARAM2 = A // Result                      
  TYA                         ; A = Y // remainder = numerator                  
  LDX   #8                    ; X = 8 // nb bits                             
loc_1154:                     ; ...                                          
  ASL   PARAM2               ; do {                                         
                              ;   PARAM2 C<< // shift results            
  ROL                        ;   ROL A C<<C                                 
  CMP   PARAM1                                                              
  BCC   loc_115F              ;   if (A >= PARAM1) {                        
  SBC   PARAM1               ;     A  -= PARAM1                            
  INC   PARAM2               ;     PARAM2 ++                               
                              ;   }                                          
loc_115F:                     ; ...                                          
  DEX                         ;   X --                                       
  BNE   loc_1154              ; } while (X != 0)                             
  TAY                         ; Y = A       // Remainder                         
  LDA   PARAM2               ; A = PARAM2 // Result                      
  RTS                                                                        
; End of function div8Bits                                                   

; ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦ S U B R O U T I N E ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
; input                                                                      
; Y/A: Numerator 16 bits                                                    
; X:   Divisor                                                              
; output                                                                     
; Y/A, PARAM3/PARAM2: Result                                             
;      PARAM5/PARAM4: Remainder                                                
;                                                                            
; Y/A /= X                                                                   
div16Bits:                    ; ...                                          
  STX   PARAM1               ; PARAM1 = X // Divisor                      
  STA   PARAM2               ; PARAM2 = A // Numerator                    
  STY   PARAM3               ; PARAM3 = Y // Numerator +1                 
  LDA   #0                                                                   
  STA   PARAM4               ; PARAM4 = 0 // Remainder                         
  STA   PARAM5               ; PARAM5 = 0 // Remainder +1                      
  LDX   #16                   ; X = 16                                       
  CLC                                                                        
loc_11B1:                     ; ...                                          
  ROL   PARAM2               ; do {                                         
                              ;   PARAM2 <<                                 
  ROL   PARAM3               ;   PARAM3 <<                                 
  ROL   PARAM4               ;   PARAM4 <<                                 
  ROL   PARAM5               ;   PARAM5 <<                                 
  SEC                                                                        
  LDA   PARAM4                                                              
  SBC   PARAM1               ;   A = PARAM4 - PARAM1                      
  TAY                         ;   Y = A                                      
  LDA   PARAM5                                                              
  SBC   #0                    ;   A = PARAM5 - 0                            
  BCC   loc_11C9              ;   if (A >= 0) {                              
  STY   PARAM4               ;     PARAM4 = Y                              
  STA   PARAM5               ;     PARAM5 = A                              
                              ;   }                                          
loc_11C9:                     ; ...                                          
  DEX                         ;   X --                                       
  BNE   loc_11B1              ; } while (X != 0)                             
  ROL   PARAM2               ; PARAM2 <<                                   
  ROL   PARAM3               ; PARAM3 <<                                   
  LDA   PARAM2               ; A = PARAM2                                  
  LDY   PARAM3               ; Y = PARAM3                                  
  RTS                                                                        
; End of function div16Bits                                                  

; ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦ S U B R O U T I N E ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
; input                                                                      
; Y/A                                                                        
; X                                                                          
; output                                                                     
; Y/A, PARAM2, PARAM1: Y/A *= X                                            
;                                                                            
; Multiplie Y/A par X                                                        
mul16BitsBy8Bits:             ; ...                                          
  STA   PARAM3               ; PARAM3 = A                                  
  STY   PARAM4               ; PARAM4 = Y                                  
  LDA   #0                                                                   
  STA   PARAM1               ; PARAM1 = 0                                  
  STA   PARAM2               ; PARAM2 = 0                                  
  CPX   #0                                                                   
  BEQ   loc_13B1              ; if (X != 0) {                                
loc_13A1:                     ; ...                                          
  LDA   PARAM3               ;   do {                                       
  CLC                                                                        
  ADC   PARAM1                                                              
  STA   PARAM1                                                              
  LDA   PARAM4                                                              
  ADC   PARAM2                                                              
  STA   PARAM2               ;     PARAM2/PARAM1 += PARAM4/PARAM3       
  DEX                         ;     X --                                     
  BNE   loc_13A1              ;   } while (X != 0)                           
                              ;   // PARAM2/PARAM1 = (PARAM4/PARAM3) * X 
loc_13B1:                     ; ...                                          
  LDA   PARAM1               ; }                                            
                              ; A = PARAM1                                  
  LDY   PARAM2               ; Y = PARAM2                                  
  RTS                         ; return                                       
; End of function mul16BitsBy8Bits                                           

; ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦ S U B R O U T I N E ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
; input                                                                      
; A: value                                                                   
; Y: fluctuation                                                             
;                                                                            
; output                                                                     
; A, PARAM2: partie entiere signée de la variation                          
; PARAM1: partie numérique                                                  
;                                                                            
; Si Y=0 alors pas de variation                                              
; Si Y=1 alors                                                               
;   A = A + int ( 1/2 * binomial [-6.0; 6.0] )                               
; Si Y>=2 alors                                                              
;   A = A + int ( (Y-1) * binomial [-6.0; 6.0] )                             
;                                                                            
; Utilisée pour:                                                             
; - prix du smithore                                                         
; - production                                                               
; - nb de terres à vendre                                                    
;                                                                            
; Répartition:                                                               
; -4:  0.013%                                                                
; -3:  0.562%                                                                
; -2:  6.248%                                                                
; -1: 24.303%                                                                
;  0: 37.748%                                                                
;  1: 24.303%                                                                
;  2:  6.248%                                                                
;  3:  0.562%                                                                
;  4:  0.013%                                                                
;calcBinomial:                 ; ...                                          
;  CPY   #0                                                                   
;  BEQ   locret_12B7           ; if (Y == 0)                                  
;                              ;   return                                     
;  STY   PARAM5               ; PARAM5 = Y                                  
;  STA   byte_9B               ; byte_9B = A                                  
;  LDA   #0                                                                   
;  STA   PARAM1               ; PARAM1 = 0                                  
;  STA   PARAM2               ; PARAM2 = 0                                  
;  STA   PARAM3               ; PARAM3 = 0                                  
;  LDY   #12                   ; Y = 12                                       
;loc_1266:                     ; ...                                          
;  LDA   OS_SKREST_RANDOM      ; for (Y=12; Y!=0; Y--) {                      
;  CLC                                                                        
;  ADC   PARAM1                                                              
;  STA   PARAM1                                                              
;  LDA   #0                                                                   
;  ADC   PARAM2                                                              
;  STA   PARAM2               ;   PARAM2/PARAM1 += $00/random [0; 255]     
;  DEY                         ;   Y --                                       
;  BNE   loc_1266              ; }                                            
;                              ; // PARAM2/PARAM1 = random [0; 3060]        
;  LDA   PARAM1                                                              
;  SEC                                                                        
;  SBC   #$FA                                                                 
;  STA   PARAM1                                                              
;  LDA   PARAM2                                                              
;  SBC   #5                                                                   
;  STA   PARAM2               ; PARAM2/PARAM1 -= $05FA // 1530             
;                              ; // PARAM2/PARAM1 = random [-1530; 1530]    
;  LDY   PARAM5               ; Y = PARAM5                                  
;  LDA   PARAM1                                                              
;  STA   PARAM3                                                              
;  LDA   PARAM2                                                              
;  STA   PARAM4               ; PARAM4/PARAM3 = PARAM2/PARAM1            
;  DEY                         ; Y = PARAM5 - 1                              
;  BEQ   loc_12A5              ; // si PARAM5 == 2 alors *1 et tout sauter   
;                              ; if (PARAM5 != 2) {                          
;                              ;   // si PARAM5 == 1 alors *1/2 et sauter en partie                                                                       
;                              ;   if (PARAM5 != 1) { // *1/2                
;  CPY   #1                    ;     //ici si Y>=2                            
;  BEQ   loc_12AA                                                             
;loc_1295:                     ; ...                                          
;  LDA   PARAM3               ;     do {                                     
;  CLC                                                                        
;  ADC   PARAM1                                                              
;  STA   PARAM1                                                              
;  LDA   PARAM4                                                              
;  ADC   PARAM2                                                              
;  STA   PARAM2               ;       PARAM2/PARAM1 += PARAM4/PARAM3     
;  DEY                         ;       Y --                                   
;  BNE   loc_1295              ;     } while (Y != 0)                         
;                              ;     // PARAM2/PARAM1 *= PARAM5            
;                              ;   }                                          
;loc_12A5:                     ; ...                                          
;  ASL   A                                                                    
;  ROR   PARAM2                                                              
;  ROR   PARAM1               ;   PARAM2/PARAM1 C>>C                       
;                              ;   PARAM2/PARAM1 /= 2 // en gardant le bit de signe                                                                      
;                              ;   // PARAM2/PARAM1 *= (PARAM5 - 1)        
;                              ; }                                            
;loc_12AA:                     ; ...                                          
;  LDA   PARAM1                                                              
;  CMP   #129                                                                 
;  BCC   loc_12B2              ; // arrondir au sup si PARAM1 > 128          
;                              ; if (PARAM1 > 128) {                         
;  INC   PARAM2               ;   PARAM2 ++                                 
;                              ; }                                            
;loc_12B2:                     ; ...                                          
;  LDA   PARAM2                                                              
;  CLC                                                                        
;  ADC   byte_9B               ; A = PARAM2 + byte_9B                        
;locret_12B7:                  ; ...                                          
;  RTS                                                                        
; End of function calcBinomial                                               

