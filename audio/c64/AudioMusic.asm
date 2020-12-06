NUMBER_OF_SID_CHIPS = 1

NUMBER_OF_VOICES = 3

MusicEngineV1Vector = zeroPageCounter+0
MusicEngineV2Vector = zeroPageCounter+2
MusicEngineV3Vector = zeroPageCounter+4
!set zeroPageCounter = zeroPageCounter+(NUMBER_OF_VOICES*2)

; C64 MULE music engine.
; This module requires the use of six zero page registers:
; MusicEngineV1Vector,MusicEngineV1Vector+1
; MusicEngineV2Vector,MusicEngineV2Vector+1
; MusicEngineV3Vector,MusicEngineV3Vector+1
;
; It contains several labels that the code utilizing this
; engine will want to call:
; SoundKillAll
;
; Importantly, this block of code contains labels of external
; origin, relating to initial memory values pointing
; to music data.
;
;
; It provides the following major routines:
; InitializeMusic
; ProcessMusic

; The encoding for the music is as follows:
; - The first byte fetched will always contain an index to a note table, based on the lower 6 bits.
; - The first byte's 7th bit indicates a duration change (how much music time this byte takes up).
;   - If a duration change is indicated, a second byte is fetched.
;   - The second byte's value acts as a delay (duration) counter, which is decremented every music engine frame.
;   - While this duration counter is positive, no more bytes from the corresponding voice's music data are processed.
;   - Once the duration is zero (non-positive), music data fetching commences, restarting the cycle with the first byte fetch.
; - The first byte's 6th bit indicates a voice gate change.
;   - High will start the silencing or release of the voice.
;   - Low will either start the voice attack or will maintain the voice's active status.
; - Unless a duration change is made, all byte fetches are considered the 'first' byte.

; - Durations:
;   - $0c: 1/8 note.
;   - $c0: 8 beats rest.
NOTE_LENGTH_1_96TH = 1
NOTE_LENGTH_1_32ND = NOTE_LENGTH_1_96TH * 3 ; 3
NOTE_LENGTH_1_16TH = NOTE_LENGTH_1_32ND * 2 ; 6
NOTE_LENGTH_1_8TH  = NOTE_LENGTH_1_16TH * 2 ; 12
NOTE_LENGTH_1_4TH  = NOTE_LENGTH_1_8TH  * 2 ; 24
NOTE_LENGTH_1_HALF = NOTE_LENGTH_1_4TH  * 2 ; 48
NOTE_LENGTH_1      = NOTE_LENGTH_1_HALF * 2 ; 96

NOTE_CONTROL_LENGTH = %10000000
NOTE_CONTROL_GATE   = %01000000

; Note tables:
; (for music generation--technically music data, as addresses are referenced
; for each voice--likely for respective octaves).

NOTE_C  = 0
NOTE_CS = 1
NOTE_D  = 2
NOTE_DS = 3
NOTE_E  = 4
NOTE_F  = 5
NOTE_FS = 6
NOTE_G  = 7
NOTE_GS = 8
NOTE_A  = 9
NOTE_AS = 10
NOTE_B  = 11

NUMBER_OF_NOTES_IN_OCTAVE = 12
OCTAVE = NUMBER_OF_NOTES_IN_OCTAVE

; HI byte for voice 1 frequency.
NOTE_FREQ_1_C  = $0218 ; C-1
NOTE_FREQ_1_CS = $0238 ; C#-1
NOTE_FREQ_1_D  = $025a ; D-1
NOTE_FREQ_1_DS = $027d ; D#-1
NOTE_FREQ_1_E  = $02a3 ; E-1
NOTE_FREQ_1_F  = $02cc ; F-1
NOTE_FREQ_1_FS = $02f6 ; F#-1
NOTE_FREQ_1_G  = $0323 ; G-1
NOTE_FREQ_1_GS = $0353 ; G#-1
NOTE_FREQ_1_A  = $0386 ; A-1
NOTE_FREQ_1_AS = $03bb ; A#-1
NOTE_FREQ_1_B  = $03f4 ; B-1
NOTE_FREQ_2_C  = $0430 ; C-2
NOTE_FREQ_2_CS = $0470 ; C#-2
NOTE_FREQ_2_D  = $04b4 ; D-2
NOTE_FREQ_2_DS = $04fb ; D#-2
NOTE_FREQ_2_E  = $0547 ; E-2
NOTE_FREQ_2_F  = $0598 ; F-2
NOTE_FREQ_2_FS = $05ed ; F#-2
NOTE_FREQ_2_G  = $0647 ; G-2
NOTE_FREQ_2_GS = $06a7 ; G#-2
NOTE_FREQ_2_A  = $070c ; A-2
NOTE_FREQ_2_AS = $0777 ; A#-2
NOTE_FREQ_2_B  = $07e9 ; B-2
NOTE_FREQ_3_C  = $0861 ; C-3
NOTE_FREQ_3_CS = $08e1 ; C#-3
NOTE_FREQ_3_D  = $0968 ; D-3
NOTE_FREQ_3_DS = $09f7 ; D#-3
NOTE_FREQ_3_E  = $0a8f ; E-3
NOTE_FREQ_3_F  = $0b30 ; F-3
NOTE_FREQ_3_FS = $0bda ; F#-3
NOTE_FREQ_3_G  = $0c8f ; G-3
NOTE_FREQ_3_GS = $0d4e ; G#-3
NOTE_FREQ_3_A  = $0e18 ; A-3
NOTE_FREQ_3_AS = $0eef ; A#-3
NOTE_FREQ_3_B  = $0fd2 ; B-3
NOTE_FREQ_4_C  = $10c3 ; C-4
NOTE_FREQ_4_CS = $11c3 ; C#-4
NOTE_FREQ_4_D  = $12d1 ; D-4
NOTE_FREQ_4_DS = $13ef ; D#-4
NOTE_FREQ_4_E  = $151f ; E-4
NOTE_FREQ_4_F  = $1660 ; F-4
NOTE_FREQ_4_FS = $17b5 ; F#-4
NOTE_FREQ_4_G  = $191e ; G-4
NOTE_FREQ_4_GS = $1a9c ; G#-4
NOTE_FREQ_4_A  = $1c31 ; A-4
NOTE_FREQ_4_AS = $1ddf ; A#-4
NOTE_FREQ_4_B  = $1fa5 ; B-4
NOTE_FREQ_5_C  = $2187 ; C-5
NOTE_FREQ_5_CS = $2386 ; C#-5
NOTE_FREQ_5_D  = $25a2 ; D-5
NOTE_FREQ_5_DS = $27df ; D#-5
NOTE_FREQ_5_E  = $2a3e ; E-5
NOTE_FREQ_5_F  = $2cc1 ; F-5
NOTE_FREQ_5_FS = $2f6b ; F#-5
NOTE_FREQ_5_G  = $323c ; G-5
NOTE_FREQ_5_GS = $3539 ; G#-5
NOTE_FREQ_5_A  = $3863 ; A-5
NOTE_FREQ_5_AS = $3bbe ; A#-5
NOTE_FREQ_5_B  = $3F4b ; B-5
NOTE_FREQ_6_C  = $430f ; C-6
NOTE_FREQ_6_CS = $470c ; C#-6
NOTE_FREQ_6_D  = $4b45 ; D-6
NOTE_FREQ_6_DS = $4fbf ; D#-6
NOTE_FREQ_6_E  = $547d ; E-6
NOTE_FREQ_6_F  = $5983 ; F-6
NOTE_FREQ_6_FS = $5ed6 ; F#-6
NOTE_FREQ_6_G  = $6479 ; G-6
NOTE_FREQ_6_GS = $6a73 ; G#-6
NOTE_FREQ_6_A  = $70c7 ; A-6
NOTE_FREQ_6_AS = $777c ; A#-6
NOTE_FREQ_6_B  = $7e97 ; B-6

NOTE_FREQ_TABLE_HI_1_C
  !byte >NOTE_FREQ_1_C
  !byte >NOTE_FREQ_1_CS
  !byte >NOTE_FREQ_1_D
  !byte >NOTE_FREQ_1_DS
  !byte >NOTE_FREQ_1_E
  !byte >NOTE_FREQ_1_F
  !byte >NOTE_FREQ_1_FS
  !byte >NOTE_FREQ_1_G
  !byte >NOTE_FREQ_1_GS
  !byte >NOTE_FREQ_1_A
  !byte >NOTE_FREQ_1_AS
  !byte >NOTE_FREQ_1_B
  !byte >NOTE_FREQ_2_C
  !byte >NOTE_FREQ_2_CS
  !byte >NOTE_FREQ_2_D
  !byte >NOTE_FREQ_2_DS
  !byte >NOTE_FREQ_2_E
  !byte >NOTE_FREQ_2_F
  !byte >NOTE_FREQ_2_FS
  !byte >NOTE_FREQ_2_G
  !byte >NOTE_FREQ_2_GS
  !byte >NOTE_FREQ_2_A
  !byte >NOTE_FREQ_2_AS
  !byte >NOTE_FREQ_2_B            
  !byte >NOTE_FREQ_3_C
  !byte >NOTE_FREQ_3_CS
  !byte >NOTE_FREQ_3_D
  !byte >NOTE_FREQ_3_DS
  !byte >NOTE_FREQ_3_E
  !byte >NOTE_FREQ_3_F
  !byte >NOTE_FREQ_3_FS
  !byte >NOTE_FREQ_3_G
  !byte >NOTE_FREQ_3_GS
  !byte >NOTE_FREQ_3_A
  !byte >NOTE_FREQ_3_AS
  !byte >NOTE_FREQ_3_B
  !byte >NOTE_FREQ_4_C
  !byte >NOTE_FREQ_4_CS
  !byte >NOTE_FREQ_4_D
  !byte >NOTE_FREQ_4_DS
  !byte >NOTE_FREQ_4_E
  !byte >NOTE_FREQ_4_F
  !byte >NOTE_FREQ_4_FS
  !byte >NOTE_FREQ_4_G
  !byte >NOTE_FREQ_4_GS
  !byte >NOTE_FREQ_4_A
  !byte >NOTE_FREQ_4_AS
  !byte >NOTE_FREQ_4_B
  !byte >NOTE_FREQ_5_C
  !byte >NOTE_FREQ_5_CS
  !byte >NOTE_FREQ_5_D
  !byte >NOTE_FREQ_5_DS
  !byte >NOTE_FREQ_5_E
  !byte >NOTE_FREQ_5_F
  !byte >NOTE_FREQ_5_FS
  !byte >NOTE_FREQ_5_G
  !byte >NOTE_FREQ_5_GS
  !byte >NOTE_FREQ_5_A
  !byte >NOTE_FREQ_5_AS
  !byte >NOTE_FREQ_5_B
  !byte >NOTE_FREQ_6_C
  !byte >NOTE_FREQ_6_CS
  !byte >NOTE_FREQ_6_D
  !byte >NOTE_FREQ_6_DS
  !byte >NOTE_FREQ_6_E
  !byte >NOTE_FREQ_6_F
  !byte >NOTE_FREQ_6_FS
  !byte >NOTE_FREQ_6_G
  !byte >NOTE_FREQ_6_GS
  !byte >NOTE_FREQ_6_A
  !byte >NOTE_FREQ_6_AS
  !byte >NOTE_FREQ_6_B

NOTE_FREQ_TABLE_LO_1_C
  !byte <NOTE_FREQ_1_C
  !byte <NOTE_FREQ_1_CS
  !byte <NOTE_FREQ_1_D
  !byte <NOTE_FREQ_1_DS
  !byte <NOTE_FREQ_1_E
  !byte <NOTE_FREQ_1_F
  !byte <NOTE_FREQ_1_FS
  !byte <NOTE_FREQ_1_G
  !byte <NOTE_FREQ_1_GS
  !byte <NOTE_FREQ_1_A
  !byte <NOTE_FREQ_1_AS
  !byte <NOTE_FREQ_1_B
  !byte <NOTE_FREQ_2_C
  !byte <NOTE_FREQ_2_CS
  !byte <NOTE_FREQ_2_D
  !byte <NOTE_FREQ_2_DS
  !byte <NOTE_FREQ_2_E
  !byte <NOTE_FREQ_2_F
  !byte <NOTE_FREQ_2_FS
  !byte <NOTE_FREQ_2_G
  !byte <NOTE_FREQ_2_GS
  !byte <NOTE_FREQ_2_A
  !byte <NOTE_FREQ_2_AS
  !byte <NOTE_FREQ_2_B 
  !byte <NOTE_FREQ_3_C
  !byte <NOTE_FREQ_3_CS
  !byte <NOTE_FREQ_3_D
  !byte <NOTE_FREQ_3_DS
  !byte <NOTE_FREQ_3_E
  !byte <NOTE_FREQ_3_F
  !byte <NOTE_FREQ_3_FS
  !byte <NOTE_FREQ_3_G
  !byte <NOTE_FREQ_3_GS
  !byte <NOTE_FREQ_3_A
  !byte <NOTE_FREQ_3_AS
  !byte <NOTE_FREQ_3_B
  !byte <NOTE_FREQ_4_C
  !byte <NOTE_FREQ_4_CS
  !byte <NOTE_FREQ_4_D
  !byte <NOTE_FREQ_4_DS
  !byte <NOTE_FREQ_4_E
  !byte <NOTE_FREQ_4_F
  !byte <NOTE_FREQ_4_FS
  !byte <NOTE_FREQ_4_G
  !byte <NOTE_FREQ_4_GS
  !byte <NOTE_FREQ_4_A
  !byte <NOTE_FREQ_4_AS
  !byte <NOTE_FREQ_4_B
  !byte <NOTE_FREQ_5_C
  !byte <NOTE_FREQ_5_CS
  !byte <NOTE_FREQ_5_D
  !byte <NOTE_FREQ_5_DS
  !byte <NOTE_FREQ_5_E
  !byte <NOTE_FREQ_5_F
  !byte <NOTE_FREQ_5_FS
  !byte <NOTE_FREQ_5_G
  !byte <NOTE_FREQ_5_GS
  !byte <NOTE_FREQ_5_A
  !byte <NOTE_FREQ_5_AS
  !byte <NOTE_FREQ_5_B
  !byte <NOTE_FREQ_6_C
  !byte <NOTE_FREQ_6_CS
  !byte <NOTE_FREQ_6_D
  !byte <NOTE_FREQ_6_DS
  !byte <NOTE_FREQ_6_E
  !byte <NOTE_FREQ_6_F
  !byte <NOTE_FREQ_6_FS
  !byte <NOTE_FREQ_6_G
  !byte <NOTE_FREQ_6_GS
  !byte <NOTE_FREQ_6_A
  !byte <NOTE_FREQ_6_AS
  !byte <NOTE_FREQ_6_B

NOTE_FREQ_TABLE_HI_2_C = NOTE_FREQ_TABLE_HI_1_C+(NUMBER_OF_NOTES_IN_OCTAVE*1)
NOTE_FREQ_TABLE_HI_3_C = NOTE_FREQ_TABLE_HI_1_C+(NUMBER_OF_NOTES_IN_OCTAVE*2)
NOTE_FREQ_TABLE_HI_4_C = NOTE_FREQ_TABLE_HI_1_C+(NUMBER_OF_NOTES_IN_OCTAVE*3)
NOTE_FREQ_TABLE_HI_5_C = NOTE_FREQ_TABLE_HI_1_C+(NUMBER_OF_NOTES_IN_OCTAVE*4)
NOTE_FREQ_TABLE_HI_6_C = NOTE_FREQ_TABLE_HI_1_C+(NUMBER_OF_NOTES_IN_OCTAVE*5)

NOTE_FREQ_TABLE_LO_2_C = NOTE_FREQ_TABLE_LO_1_C+(NUMBER_OF_NOTES_IN_OCTAVE*1)
NOTE_FREQ_TABLE_LO_3_C = NOTE_FREQ_TABLE_LO_1_C+(NUMBER_OF_NOTES_IN_OCTAVE*2)
NOTE_FREQ_TABLE_LO_4_C = NOTE_FREQ_TABLE_LO_1_C+(NUMBER_OF_NOTES_IN_OCTAVE*3)
NOTE_FREQ_TABLE_LO_5_C = NOTE_FREQ_TABLE_LO_1_C+(NUMBER_OF_NOTES_IN_OCTAVE*4)
NOTE_FREQ_TABLE_LO_6_C = NOTE_FREQ_TABLE_LO_1_C+(NUMBER_OF_NOTES_IN_OCTAVE*5)



;---------------------------------------
VOICE_1_FREQ_TABLE_HI = NOTE_FREQ_TABLE_HI_1_C
VOICE_1_FREQ_TABLE_LO = NOTE_FREQ_TABLE_LO_1_C

VOICE_2_FREQ_TABLE_HI = NOTE_FREQ_TABLE_HI_1_C
VOICE_2_FREQ_TABLE_LO = NOTE_FREQ_TABLE_LO_1_C

VOICE_3_FREQ_TABLE_HI = NOTE_FREQ_TABLE_HI_1_C
VOICE_3_FREQ_TABLE_LO = NOTE_FREQ_TABLE_LO_1_C

;---------------------------------------
VOICE_1_MUSIC_START
!word          VOICE_1_START_1  ; .

VOICE_1_MUSIC_END
!word          VOICE_1_END_1  ; .

VOICE_2_MUSIC_START
!word          VOICE_2_START_1  ; .

VOICE_2_MUSIC_END
!word          VOICE_2_END_1  ; _

VOICE_3_MUSIC_START
!word          VOICE_3_START_2  ; l

VOICE_3_MUSIC_END
!word          VOICE_3_END_1

; Amount of music engine cycles that a note sustains after attack before being gated.
VOICE_1_TIME_TO_RELEASE
!byte          $1E  ; .
VOICE_2_TIME_TO_RELEASE
!byte          $1E  ; .
VOICE_3_TIME_TO_RELEASE
!byte          $1E  ; .

; Potentially voice 1 note/rest duration (read during data fetch).
VOICE_1_DURATION
!byte          $00  ; .
VOICE_2_DURATION
!byte          $00  ; .
VOICE_3_DURATION
!byte          $0C          ; 1/8th note (held constant for this song)..

VOICE_1_ACTIVE
!byte          $00  ; .
VOICE_2_ACTIVE
!byte          $00  ; .
VOICE_3_ACTIVE
!byte          $00  ; .

VOICE_1_TIME_TO_RELEASE_COUNTER
!byte          $00  ; .
VOICE_2_TIME_TO_RELEASE_COUNTER
!byte          $00  ; .
VOICE_3_TIME_TO_RELEASE_COUNTER
!byte          $00  ; .

; Potentially voice 1 note/rest duration (likely actual persistent value... gets decreased with time).
VOICE_1_DURATION_COUNTER
!byte          $00  ; .
VOICE_2_DURATION_COUNTER
!byte          $00  ; .
VOICE_3_DURATION_COUNTER
!byte          $00  ; .

MUSIC_ENGINE_TEMP_FETCH
!byte          $00  ; .

InitializeMusic
  lda       #$08        ; Set Voice2 Waveform (high nibble) to 8.
  sta       SID_PB2Hi
  sta       SID_PB3Hi
  
  lda       #$00        ; Set Voice2 decay 2ms / attack 6ms.
  sta       SID_AD2
  sta       SID_AD3
  
  lda       #$40        ; Set Voice2 sustain 114ms / release 6ms.
  sta       SID_SUR2
  sta       SID_SUR3
  
  ;lda       #$07        ; Set Voice3 decay 2ms / attack 240ms.
  ;sta       SID_AD3

  lda       #$09        ; Set Voice1 decay 2ms / attack 250ms.
  sta       SID_AD1
  
  lda       #0
  sta       SID_PB2Lo    ; Set Voice2 Waveform (low byte) to 0.
  sta       SID_SUR1     ; Set Voice1 sustain 6m / release 6m.
  ;sta       SID_SUR3     ; Set Voice3 sustain 6m / release 6m.

  
  lda       VOICE_1_MUSIC_START      ; Load music vectors into music engine voice music data vector (counters).
  sta       MusicEngineV1Vector
  lda       VOICE_1_MUSIC_START+1
  sta       MusicEngineV1Vector+1

  lda       VOICE_2_MUSIC_START
  sta       MusicEngineV2Vector
  lda       VOICE_2_MUSIC_START+1
  sta       MusicEngineV2Vector+1

  lda       VOICE_3_MUSIC_START
  sta       MusicEngineV3Vector
  lda       VOICE_3_MUSIC_START+1
  sta       MusicEngineV3Vector+1

  lda       #0
  sta       VOICE_1_ACTIVE ; Disable all voice music processing.
  sta       VOICE_2_ACTIVE
  sta       VOICE_3_ACTIVE

  sta       SID_Ctl1    ; Gate all Voices silent.
  sta       SID_Ctl2
  sta       SID_Ctl3

  lda       #15      ; Set volume 15 (max).
  sta       SID_Amp

  rts

; Start of all voice/music processing.
!zone ProcessMusic
ProcessMusic
.checkVoice1
  lda       VOICE_1_ACTIVE              ; if(VOICE_1_ACTIVE==0)
  beq       A_70EC                      ; {

  jmp       .checkVoice2

A_70EC
  lda       VOICE_1_MUSIC_END           ;   if((MusicEngineV1Vector+1,MusicEngineV1Vector)==VOICE_1_MUSIC_END)
  cmp       MusicEngineV1Vector                        ;   {
  bne       .processVoice1

  lda       VOICE_1_MUSIC_END+1
  cmp       MusicEngineV1Vector+1
  bne       .processVoice1

  lda       VOICE_1_MUSIC_START        ;      if(VOICE_1_MUSIC_START==&VOICE_1_START_2)
  cmp       #<VOICE_1_START_2 ;      {
  bne       A_711F

  lda       VOICE_1_MUSIC_START+1
  cmp       #>VOICE_1_START_2
  bne       A_711F

  lda       #<VOICE_1_START_3 ;         VOICE_1_MUSIC_START = &VOICE_1_START_3
  sta       VOICE_1_MUSIC_START
  lda       #>VOICE_1_START_3
  sta       VOICE_1_MUSIC_START+1

  lda       #<VOICE_2_START_2 ;     VOICE_2_MUSIC_START = &VOICE_2_START_2
  sta       VOICE_2_MUSIC_START
  lda       #>VOICE_2_START_2
  sta       VOICE_2_MUSIC_START+1
                                        ;      }
  jmp       .resetMusicVectors          ;      else [7130]
                                        ;      {
A_711F
  lda       VOICE_1_MUSIC_END           ;        if(VOICE_1_MUSIC_END==&VOICE_1_END_2)
  cmp       #<VOICE_1_END_2    ;        {
  bne       .resetMusicVectors          ;          return SoundKillAll()
                                        ;
  lda       VOICE_1_MUSIC_END+1         ;
  cmp       #>VOICE_1_END_2    ;
  bne       .resetMusicVectors          ;        }
                                        ;
  jmp       SoundKillAll
                                        ;      }

; Reset music engine vectors to currently set base music data vectors.
.resetMusicVectors
  lda       VOICE_1_MUSIC_START        ;      (MusicEngineV1Vector+1,MusicEngineV1Vector)=VOICE_1_MUSIC_START
  sta       MusicEngineV1Vector
  lda       VOICE_1_MUSIC_START+1
  sta       MusicEngineV1Vector+1

  lda       VOICE_2_MUSIC_START        ;      (MusicEngineV2Vector+1,MusicEngineV2Vector)=VOICE_2_MUSIC_START
  sta       MusicEngineV2Vector
  lda       VOICE_2_MUSIC_START+1
  sta       MusicEngineV2Vector+1

  lda       VOICE_3_MUSIC_START        ;      (MusicEngineV3Vector+1,MusicEngineV3Vector)=VOICE_3_MUSIC_START
  sta       MusicEngineV3Vector
  lda       VOICE_3_MUSIC_START+1
  sta       MusicEngineV3Vector+1

  lda       #0                         ;       // Set all voices in music engine to inactive.
  sta       VOICE_1_ACTIVE
  sta       VOICE_2_ACTIVE
  sta       VOICE_3_ACTIVE
                                       ;     }
; Start music data processing (of voice 1).
.processVoice1
  ldy       #0                         ;     Y=0            // Reset Y as counter.
  lda       (MusicEngineV1Vector),y    ;     A=(MusicEngineV1Vector+1,MusicEngineV1Vector)[Y]
  sta       MUSIC_ENGINE_TEMP_FETCH    ;     MUSIC_ENGINE_TEMP_FETCH=A       // Backup this byte for later analysis.
  and       #%00111111                 ;     // Cutoff bits 6 & 7.
  tax                                  ;     // The first six bits of this byte are the music note index.
  lda       VOICE_1_FREQ_TABLE_HI,x    ;     // Load Voice  1 Frequency HI byte.
  sta       SID_S1Hi
  lda       VOICE_1_FREQ_TABLE_LO,x    ;     // Load Voice  1 Frequency LO byte.
  sta       SID_S1Lo
                                       ;     // Now check bit 7.
  bit       MUSIC_ENGINE_TEMP_FETCH    ;     if((MUSIC_ENGINE_TEMP_FETCH & %10000000)>0)
  bpl       A_7180                     ;     {

  iny                                  ;       Y++           // Fetch and store next byte.
  lda       (MusicEngineV1Vector),y    ;       A=(MusicEngineV1Vector+1,MusicEngineV1Vector)[Y]
  sta       VOICE_1_DURATION           ;       VOICE_1_DURATION=A

  inc       MusicEngineV1Vector        ;       (MusicEngineV1Vector+1,MusicEngineV1Vector)++ // Increase music pointer.
  bne       A_7180
  inc       MusicEngineV1Vector+1      ;     }
A_7180
  inc       MusicEngineV1Vector        ;     (MusicEngineV1Vector+1,MusicEngineV1Vector)++ // Increase music pointer.
  bne       A_7186
  inc       MusicEngineV1Vector+1

A_7186                                 ;     // Now check bit 6.      [7186]
  bit       MUSIC_ENGINE_TEMP_FETCH    ;     if((MUSIC_ENGINE_TEMP_FETCH & %01000000)>0)
  bvc       A_7192                     ;     {

  lda       #$00                       ;       // Disable Voice 1.
  sta       SID_Ctl1

  beq       A_7197                     ;     }
                                       ;     else
                                       ;     {
A_7192
  lda       #%0100001                  ;       //Gate Voice 1 and select sawtooth wave.
  sta       SID_Ctl1
                                       ;     }

A_7197
  lda       VOICE_1_TIME_TO_RELEASE    ;     VOICE_1_TIME_TO_RELEASE_COUNTER=VOICE_1_TIME_TO_RELEASE
  sta       VOICE_1_TIME_TO_RELEASE_COUNTER

  lda       VOICE_1_DURATION           ;     VOICE_1_DURATION_COUNTER=VOICE_1_DURATION
  sta       VOICE_1_DURATION_COUNTER

  lda       #1                         ;     VOICE_1_ACTIVE=1
  sta       VOICE_1_ACTIVE
                                       ;   }
.checkVoice2
  lda       VOICE_2_ACTIVE
  beq       A_71B0

  jmp       .checkVoice3

A_71B0
  lda       VOICE_2_MUSIC_END
  cmp       MusicEngineV2Vector
  bne       .processVoice2

  lda       VOICE_2_MUSIC_END+1
  cmp       MusicEngineV2Vector+1
  bne       .processVoice2

  lda       VOICE_2_MUSIC_START          ; // Reset music data address (counter).
  sta       MusicEngineV2Vector
  lda       VOICE_2_MUSIC_START+1
  sta       MusicEngineV2Vector+1

; Start music data processing (of voice 2).
.processVoice2
  ldy       #0
  lda       (MusicEngineV2Vector),y
  sta       MUSIC_ENGINE_TEMP_FETCH
  and       #%00111111
  tax
  lda       VOICE_2_FREQ_TABLE_HI,x    ; Load Voice 2 Frequency HI byte.
  sta       SID_S2Hi
  lda       VOICE_2_FREQ_TABLE_LO,x    ; Load Voice 2 Frequency LO byte.
  sta       SID_S2Lo
  
  bit       MUSIC_ENGINE_TEMP_FETCH
  bpl       A_71EF

  iny
  lda       (MusicEngineV2Vector),y
  sta       VOICE_2_DURATION
  inc       MusicEngineV2Vector
  bne       A_71EF

  inc       MusicEngineV2Vector+1
A_71EF
  inc       MusicEngineV2Vector
  bne       A_71F5

  inc       MusicEngineV2Vector+1
A_71F5
  bit       MUSIC_ENGINE_TEMP_FETCH
  bvc       A_7201

  lda       #$00
  sta       SID_Ctl2
  beq       A_7206

A_7201
  lda       #%01000001  ; Gate Voice 2 and set pulse waveform.
  sta       SID_Ctl2
A_7206
  lda       VOICE_2_TIME_TO_RELEASE
  sta       VOICE_2_TIME_TO_RELEASE_COUNTER

  lda       VOICE_2_DURATION
  sta       VOICE_2_DURATION_COUNTER

  lda       #1
  sta       VOICE_2_ACTIVE

.checkVoice3
  lda       VOICE_3_ACTIVE
  beq       A_721F

  jmp       ProcessMusicDurAndRel

A_721F
  lda       VOICE_3_MUSIC_END
  cmp       MusicEngineV3Vector
  bne       .processVoice3
  
  lda       VOICE_3_MUSIC_END+1
  cmp       MusicEngineV3Vector+1
  bne       .processVoice3

  lda       VOICE_3_MUSIC_START
  sta       MusicEngineV3Vector
  lda       VOICE_3_MUSIC_START+1
  sta       MusicEngineV3Vector+1

; Start music data processing (of voice 3).
.processVoice3
  ldy       #0
  lda       (MusicEngineV3Vector),y
  sta       MUSIC_ENGINE_TEMP_FETCH
  and       #%00111111
  tax
  lda       VOICE_3_FREQ_TABLE_HI,x    ; Load Voice 3 Frequency HI byte.
  sta       SID_S3Hi
  lda       VOICE_3_FREQ_TABLE_LO,x    ; Load Voice 3 Frequency LO byte.
  sta       SID_S3Lo
  
  bit       MUSIC_ENGINE_TEMP_FETCH
  bpl       V3A_71EF

  iny
  lda       (MusicEngineV3Vector),y
  sta       VOICE_3_DURATION
  inc       MusicEngineV3Vector
  bne       V3A_71EF

  inc       MusicEngineV3Vector+1
V3A_71EF
  inc       MusicEngineV3Vector
  bne       V3A_71F5

  inc       MusicEngineV3Vector+1
V3A_71F5
  bit       MUSIC_ENGINE_TEMP_FETCH
  bvc       V3A_7201

  lda       #$00
  sta       SID_Ctl3
  beq       V3A_7206

V3A_7201
  lda       #%01000001
  sta       SID_Ctl3
V3A_7206
  lda       VOICE_3_TIME_TO_RELEASE
  sta       VOICE_3_TIME_TO_RELEASE_COUNTER

  lda       VOICE_3_DURATION
  sta       VOICE_3_DURATION_COUNTER

  lda       #1
  sta       VOICE_3_ACTIVE

; Process music engine voice time to release and duration.
ProcessMusicDurAndRel
  lda       VOICE_1_TIME_TO_RELEASE_COUNTER              ; A=VOICE_1_TIME_TO_RELEASE_COUNTER
  bne       A_7266                                       ; if(A==0)
                                                          ; {
  lda       #$00                                         ;   // Disable Voice 1.
  sta       SID_Ctl1                                     ; }
  beq       A_7269                                       ; else
A_7266                                                     ; {      [7266]
  dec       VOICE_1_TIME_TO_RELEASE_COUNTER              ;   VOICE_1_TIME_TO_RELEASE_COUNTER--
                                                          ; }
A_7269
  lda       VOICE_1_DURATION_COUNTER                     ; A=VOICE_1_DURATION_COUNTER
  cmp       #1                                           ; if(A!=1)
  beq       A_7276                                       ; {

  dec       VOICE_1_DURATION_COUNTER                     ;   VOICE_1_DURATION_COUNTER--
  jmp       J_727E                                       ; }       [727E]
                                                          ; else
A_7276                                                     ; {      [7276]
  lda       #$00                                         ;   A=0 // Disable Voice 1.
  sta       SID_Ctl1
  sta       VOICE_1_ACTIVE                               ;   VOICE_1_ACTIVE=0
                                                          ; }
J_727E
  lda       VOICE_2_TIME_TO_RELEASE_COUNTER
  bne       A_728A

  lda       #$00        ; Disable Voice 2.
  sta       SID_Ctl2
  beq       A_728D
A_728A
  dec       VOICE_2_TIME_TO_RELEASE_COUNTER

A_728D
  lda       VOICE_2_DURATION_COUNTER
  cmp       #1
  beq       A_729A

  dec       VOICE_2_DURATION_COUNTER
  jmp       J_72A2

A_729A
  lda       #$00        ; Disable Voice 2.
  sta       SID_Ctl2
  sta       VOICE_2_ACTIVE

J_72A2
  lda       VOICE_3_TIME_TO_RELEASE_COUNTER
  bne       A_72AE

  lda       #$00        ; Disable Voice 3.
  sta       SID_Ctl3
  beq       A_72B1
A_72AE
  dec       VOICE_3_TIME_TO_RELEASE_COUNTER

A_72B1
  lda       VOICE_3_DURATION_COUNTER
  cmp       #1
  beq       A_72BC

  dec       VOICE_3_DURATION_COUNTER
  rts

A_72BC
  lda       #$00        ; Turn off voice 3 (drums).
  sta       SID_Ctl3
  sta       VOICE_3_ACTIVE
  rts
