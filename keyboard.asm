.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
extern printf: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "On screen keyboard",0
area_width EQU 640
area_height EQU 480
area DD 0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc


;prima linie: cifre (+ backspace)
button_1_x EQU 80
button_1_y EQU 80

button_2_x EQU 120
button_2_y EQU 80

button_3_x EQU 160
button_3_y EQU 80

button_4_x EQU 200
button_4_y EQU 80

button_5_x EQU 240
button_5_y EQU 80

button_6_x EQU 280
button_6_y EQU 80

button_7_x EQU 320
button_7_y EQU 80

button_8_x EQU 360
button_8_y EQU 80

button_9_x EQU 400
button_9_y EQU 80

button_0_x EQU 440
button_0_y EQU 80

button_backspace_x EQU 480
button_backspace_y EQU 80
button_backspace_width EQU 100
button_backspace_height EQU 40

;a doua linie 
button_Q_x EQU 100
button_Q_y EQU 120

button_w_x EQU 140
button_w_y EQU 120

button_E_x EQU 180
button_E_y EQU 120

button_R_x EQU 220
button_R_y EQU 120

button_T_x EQU 260
button_T_y EQU 120

button_Y_x EQU 300
button_Y_y EQU 120

button_U_x EQU 340
button_U_y EQU 120

button_I_x EQU 380
button_I_y EQU 120

button_O_x EQU 420
button_O_y EQU 120

button_P_x EQU 460
button_P_y EQU 120


;a treia linie (+enter)
button_A_x EQU 120
button_A_y EQU 160

button_S_x EQU 160
button_S_y EQU 160

button_D_x EQU 200
button_D_y EQU 160

button_F_x EQU 240
button_F_y EQU 160

button_G_x EQU 280
button_G_y EQU 160

button_H_x EQU 320
button_H_y EQU 160

button_J_x EQU 360
button_J_y EQU 160

button_K_x EQU 400
button_K_y EQU 160

button_L_x EQU 440
button_L_y EQU 160

button_enter_x EQU 480
button_enter_y EQU 160
button_enter_width EQU 100
button_enter_height EQU 40

;a patra linie
button_Z_x EQU 140
button_Z_y EQU 200

button_X_x EQU 180
button_X_y EQU 200

button_C_x EQU 220
button_C_y EQU 200

button_V_x EQU 260
button_V_y EQU 200

button_B_x EQU 300
button_B_y EQU 200

button_N_x EQU 340
button_N_y EQU 200

button_M_x EQU 380
button_M_y EQU 200

button_size EQU 40 

afisaj_x DD 100
afisaj_y DD 300

lines DD 1

litere DD 11 dup(0)

format DB "x = %d, y = %d", 13, 10, 0

format_eroare DB "Eroare: nr de linii este < 1", 13, 10, 0
format_mesaj DB "Nu avem caractere scrise pe linia %d", 13, 10, 0
format_eroare2 DB "Eroare: nr de litere de pe linia %d este < 0", 13, 10, 0

limite DB "Limitele ferestrei au fost depasite", 13, 10, 0

ecran_colorat DD 0

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text_gri proc
	push ebp
	mov ebp, esp
	pusha
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_gri
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_gri:
	mov dword ptr [edi], 0D3D3D3h  ;gri
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text_gri endp

make_text_roz proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit_2
	cmp eax, 'Z'
	jg make_digit_2
	sub eax, 'A'
	lea esi, letters
	jmp draw_text_2
make_digit_2:
	cmp eax, '0'
	jl make_space_2
	cmp eax, '9'
	jg make_space_2
	sub eax, '0'
	lea esi, digits
	jmp draw_text_2
make_space_2:	
	mov eax, 26
	lea esi, letters
	
draw_text_2:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii_2:
	mov edi, [ebp+arg2] 
	mov eax, [ebp+arg4]
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] 
	shl eax, 2 
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane_2:
	cmp byte ptr [esi], 0
	je simbol_pixel_roz
	mov dword ptr [edi], 0
	jmp simbol_pixel_next_2
simbol_pixel_roz:
	mov dword ptr [edi], 0FFC0CBh  ;roz
simbol_pixel_next_2:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane_2
	pop ecx
	loop bucla_simbol_linii_2
	popa
	mov esp, ebp
	pop ebp
	ret
make_text_roz endp


make_text_gri_macro macro symbol, drawArea, x, y  
	push y
	push x
	push drawArea
	push symbol
	call make_text_gri
	add esp, 16
endm

make_text_roz_macro macro symbol, drawArea, x, y  
	push y
	push x
	push drawArea
	push symbol
	call make_text_roz
	add esp, 16
endm

line_horizontal macro x, y, len, color
local bucla_line
	mov eax, y ;EAX = y
	mov ebx, area_width
	mul ebx ;EAX = y * area_width
	add eax, x; EAX = y * area_width + x
	shl eax, 2; EAX = (y * area_width + x)*4
	add eax, area
	mov ecx, len
bucla_line:
	mov dword ptr[eax], color
	add eax, 4 ;ne deplasam la dreapta cu o pozitie
	loop bucla_line
endm


line_vertical macro x, y, len, color
local bucla_line
	mov eax, y ;EAX = y
	mov ebx, area_width
	mul ebx ;EAX = y * area_width
	add eax, x; EAX = y * area_width + x
	shl eax, 2; EAX = (y * area_width + x)*4
	add eax, area
	mov ecx, len
bucla_line:
	mov dword ptr[eax], color
	add eax, area_width * 4 ; ne deplasam in jos
	loop bucla_line
endm

draw_button macro x, y, len, color
	line_horizontal x, y, len, color
	line_horizontal x, y + len, len, color
	line_vertical x, y, len, color
	line_vertical x + len, y, len, color
endm

draw_rectangle macro x, y, width, height, color
	line_horizontal x, y, width, color
	line_horizontal x, y + height, width, color
	line_vertical x, y, height, color
	line_vertical x + width, y, height, color
endm

button_press_1 macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  ;comparam cu latura din stanga 
	jl button_fail_1     ;daca e in stanga decat latura din stanga, sigur nu s-a dat click in interior
	cmp eax, button_x + len  ;comparam cu latura din dreapta
	jg button_fail_1     ;daca e in mai in dreapta decat latura din dreapta, sigur nu s-a dat click in interior
	mov eax, y
	cmp eax, button_y
	jl button_fail_1
	cmp eax, button_y + len
	jg button_fail_1
	mov ebx, lines  
	inc litere[ebx]
endm

button_press_2 macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x   
	jl button_fail_2   
	cmp eax, button_x + len  
	jg button_fail_2     
	mov eax, y
	cmp eax, button_y
	jl button_fail_2
	cmp eax, button_y + len
	jg button_fail_2
	mov ebx, lines
	inc litere[ebx]
endm

button_press_3 macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x   
	jl button_fail_3   
	cmp eax, button_x + len  
	jg button_fail_3     
	mov eax, y
	cmp eax, button_y
	jl button_fail_3
	cmp eax, button_y + len
	jg button_fail_3
	mov ebx, lines
	inc litere[ebx]
endm

button_press_4 macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x   
	jl button_fail_4   
	cmp eax, button_x + len  
	jg button_fail_4     
	mov eax, y
	cmp eax, button_y
	jl button_fail_4
	cmp eax, button_y + len
	jg button_fail_4
	mov ebx, lines
	inc litere[ebx]
endm

button_press_5 macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x   
	jl button_fail_5   
	cmp eax, button_x + len  
	jg button_fail_5     
	mov eax, y
	cmp eax, button_y
	jl button_fail_5
	cmp eax, button_y + len
	jg button_fail_5
	mov ebx, lines
	inc litere[ebx]
endm

button_press_6 macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x   
	jl button_fail_6   
	cmp eax, button_x + len  
	jg button_fail_6    
	mov eax, y
	cmp eax, button_y
	jl button_fail_6
	cmp eax, button_y + len
	jg button_fail_6
	mov ebx, lines
	inc litere[ebx]
endm

button_press_7 macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_7   
	cmp eax, button_x + len  
	jg button_fail_7     
	mov eax, y
	cmp eax, button_y
	jl button_fail_7
	cmp eax, button_y + len
	jg button_fail_7
	mov ebx, lines
	inc litere[ebx]
endm

button_press_8 macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x   
	jl button_fail_8   
	cmp eax, button_x + len  
	jg button_fail_8    
	mov eax, y
	cmp eax, button_y
	jl button_fail_8
	cmp eax, button_y + len
	jg button_fail_8
	mov ebx, lines
	inc litere[ebx]
endm

button_press_9 macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x   
	jl button_fail_9   
	cmp eax, button_x + len  
	jg button_fail_9     
	mov eax, y
	cmp eax, button_y
	jl button_fail_9
	cmp eax, button_y + len
	jg button_fail_9
	mov ebx, lines
	inc litere[ebx]
endm

button_press_0 macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x   
	jl button_fail_0   
	cmp eax, button_x + len  
	jg button_fail_0    
	mov eax, y
	cmp eax, button_y
	jl button_fail_0
	cmp eax, button_y + len
	jg button_fail_0
	mov ebx, lines
	inc litere[ebx]
endm

button_press_Q macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x   
	jl button_fail_Q   
	cmp eax, button_x + len  
	jg button_fail_Q    
	mov eax, y
	cmp eax, button_y
	jl button_fail_Q
	cmp eax, button_y + len
	jg button_fail_Q
	mov ebx, lines
	inc litere[ebx]
endm

button_press_W macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x   
	jl button_fail_W   
	cmp eax, button_x + len  
	jg button_fail_W    
	mov eax, y
	cmp eax, button_y
	jl button_fail_W
	cmp eax, button_y + len
	jg button_fail_W
	mov ebx, lines
	inc litere[ebx]
endm

button_press_E macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_E     
	cmp eax, button_x + len
	jg button_fail_E    
	mov eax, y
	cmp eax, button_y
	jl button_fail_E
	cmp eax, button_y + len
	jg button_fail_E
	mov ebx, lines
	inc litere[ebx]
endm

button_press_R macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_R     
	cmp eax, button_x + len  
	jg button_fail_R   
	mov eax, y
	cmp eax, button_y
	jl button_fail_R
	cmp eax, button_y + len
	jg button_fail_R
	mov ebx, lines
	inc litere[ebx]
endm

button_press_T macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_T     
	cmp eax, button_x + len  
	jg button_fail_T
	mov eax, y
	cmp eax, button_y
	jl button_fail_T
	cmp eax, button_y + len
	jg button_fail_T
	mov ebx, lines
	inc litere[ebx]
endm

button_press_Y macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_Y    
	cmp eax, button_x + len  
	jg button_fail_Y
	mov eax, y
	cmp eax, button_y
	jl button_fail_Y
	cmp eax, button_y + len
	jg button_fail_Y
	mov ebx, lines
	inc litere[ebx]
endm 

button_press_U macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_U    
	cmp eax, button_x + len  
	jg button_fail_U
	mov eax, y
	cmp eax, button_y
	jl button_fail_U
	cmp eax, button_y + len
	jg button_fail_U
	mov ebx, lines
	inc litere[ebx]
endm

button_press_I macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_I    
	cmp eax, button_x + len  
	jg button_fail_I
	mov eax, y
	cmp eax, button_y
	jl button_fail_I
	cmp eax, button_y + len
	jg button_fail_I
	mov ebx, lines
	inc litere[ebx]
endm

button_press_O macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_O     
	cmp eax, button_x + len  
	jg button_fail_O
	mov eax, y
	cmp eax, button_y
	jl button_fail_O
	cmp eax, button_y + len
	jg button_fail_O
	mov ebx, lines
	inc litere[ebx]
endm

button_press_P macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_P     
	cmp eax, button_x + len  
	jg button_fail_P
	mov eax, y
	cmp eax, button_y
	jl button_fail_P
	cmp eax, button_y + len
	jg button_fail_P
	mov ebx, lines
	inc litere[ebx]
endm

button_press_A macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_A    
	cmp eax, button_x + len  
	jg button_fail_A
	mov eax, y
	cmp eax, button_y
	jl button_fail_A
	cmp eax, button_y + len
	jg button_fail_A
	mov ebx, lines
	inc litere[ebx]
endm

button_press_S macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_S     
	cmp eax, button_x + len  
	jg button_fail_S
	mov eax, y
	cmp eax, button_y
	jl button_fail_S
	cmp eax, button_y + len
	jg button_fail_S
	mov ebx, lines
	inc litere[ebx]
endm

button_press_D macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_D   
	cmp eax, button_x + len  
	jg button_fail_D
	mov eax, y
	cmp eax, button_y
	jl button_fail_D
	cmp eax, button_y + len
	jg button_fail_D
	mov ebx, lines
	inc litere[ebx]
endm

button_press_F macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_F    
	cmp eax, button_x + len  
	jg button_fail_F
	mov eax, y
	cmp eax, button_y
	jl button_fail_F
	cmp eax, button_y + len
	jg button_fail_F
	mov ebx, lines
	inc litere[ebx]
endm

button_press_G macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_G     
	cmp eax, button_x + len  
	jg button_fail_G
	mov eax, y
	cmp eax, button_y
	jl button_fail_G
	cmp eax, button_y + len
	jg button_fail_G
	mov ebx, lines
	inc litere[ebx]
endm

button_press_H macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_H   
	cmp eax, button_x + len  
	jg button_fail_H
	mov eax, y
	cmp eax, button_y
	jl button_fail_H
	cmp eax, button_y + len
	jg button_fail_H
	mov ebx, lines
	inc litere[ebx]
endm

button_press_J macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_J    
	cmp eax, button_x + len  
	jg button_fail_J
	mov eax, y
	cmp eax, button_y
	jl button_fail_J
	cmp eax, button_y + len
	jg button_fail_J
	mov ebx, lines
	inc litere[ebx]
endm

button_press_K macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_K     
	cmp eax, button_x + len  
	jg button_fail_K
	mov eax, y
	cmp eax, button_y
	jl button_fail_K
	cmp eax, button_y + len
	jg button_fail_K
	mov ebx, lines
	inc litere[ebx]
endm

button_press_L macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_L     
	cmp eax, button_x + len  
	jg button_fail_L
	mov eax, y
	cmp eax, button_y
	jl button_fail_L
	cmp eax, button_y + len
	jg button_fail_L
	mov ebx, lines
	inc litere[ebx]
endm

button_press_Z macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_Z    
	cmp eax, button_x + len  
	jg button_fail_Z
	mov eax, y
	cmp eax, button_y
	jl button_fail_Z
	cmp eax, button_y + len
	jg button_fail_Z
	mov ebx, lines
	inc litere[ebx]
endm

button_press_X macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_X     
	cmp eax, button_x + len  
	jg button_fail_X
	mov eax, y
	cmp eax, button_y
	jl button_fail_X
	cmp eax, button_y + len
	jg button_fail_X
	mov ebx, lines
	inc litere[ebx]
endm

button_press_C macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_C     
	cmp eax, button_x + len  
	jg button_fail_C
	mov eax, y
	cmp eax, button_y
	jl button_fail_C
	cmp eax, button_y + len
	jg button_fail_C
	mov ebx, lines
	inc litere[ebx]
endm

button_press_V macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_V     
	cmp eax, button_x + len  
	jg button_fail_V
	mov eax, y
	cmp eax, button_y
	jl button_fail_V
	cmp eax, button_y + len
	jg button_fail_V
	mov ebx, lines
	inc litere[ebx]
endm

button_press_B macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_B     
	cmp eax, button_x + len  
	jg button_fail_B
	mov eax, y
	cmp eax, button_y
	jl button_fail_B
	cmp eax, button_y + len
	jg button_fail_B
	mov ebx, lines
	inc litere[ebx]
endm

button_press_N macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_N     
	cmp eax, button_x + len  
	jg button_fail_N
	mov eax, y
	cmp eax, button_y
	jl button_fail_N
	cmp eax, button_y + len
	jg button_fail_N
	mov ebx, lines
	inc litere[ebx]
endm

button_press_M macro x, y, len, button_x, button_y
	mov eax, x 
	cmp eax, button_x  
	jl button_fail_M     
	cmp eax, button_x + len  
	jg button_fail_M
	mov eax, y
	cmp eax, button_y
	jl button_fail_M
	cmp eax, button_y + len
	jg button_fail_M
	mov ebx, lines
	inc litere[ebx]
endm

button_press_backspace macro x, y, width, height, button_x, button_y
	mov eax, x 
	cmp eax, button_x   
	jl button_fail_backspace
	cmp eax, button_x + width 
	jg button_fail_backspace   
	mov eax, y
	cmp eax, button_y
	jl button_fail_backspace
	cmp eax, button_y + height
	jg button_fail_backspace
endm

button_press_enter macro x, y, width, height, button_x, button_y
	mov eax, x 
	cmp eax, button_x   
	jl button_fail_enter
	cmp eax, button_x + width 
	jg button_fail_enter  
	mov eax, y
	cmp eax, button_y
	jl button_fail_enter
	cmp eax, button_y + height
	jg button_fail_enter
endm

colorare_ecran macro color
local c1, c2
	pusha
	mov eax, area
	mov ecx, area_width
c1:
	pusha
	mov ecx, area_height
c2:
	mov dword ptr[eax], color
	add eax,[area_width * 4]
	loop c2
	popa
	add eax,4
	loop c1
	popa
endm

colorare_buton macro x, y, len, color
local colorare
	mov esi, y + 1
	mov edi, 0
colorare:
	line_horizontal x + 1, esi, len - 1, color
	add esi, 1
	inc edi
	cmp edi, len - 1
	jne colorare
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click, 3 - s-a apasat o tasta)
; arg2 - x (in cazul apasarii unei taste, x contine codul ascii al tastei care a fost apasata)
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
	
evt_click:
	button_press_1 [ebp + arg2], [ebp + arg3], button_size, button_1_x, button_1_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro '1', area, afisaj_x, afisaj_y 
	add afisaj_x, 10
	
button_fail_1:	
	button_press_2 [ebp + arg2], [ebp + arg3], button_size, button_2_x, button_2_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro '2', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_2:
	button_press_3 [ebp + arg2], [ebp + arg3], button_size, button_3_x, button_3_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro '3', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_3:
	button_press_4 [ebp + arg2], [ebp + arg3], button_size, button_4_x, button_4_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro '4', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_4:
	button_press_5 [ebp + arg2], [ebp + arg3], button_size, button_5_x, button_5_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro '5', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_5:
	button_press_6 [ebp + arg2], [ebp + arg3], button_size, button_6_x, button_6_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro '6', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_6:
	button_press_7 [ebp + arg2], [ebp + arg3], button_size, button_7_x, button_7_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro '7', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_7:
	button_press_8 [ebp + arg2], [ebp + arg3], button_size, button_8_x, button_8_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro '8', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere	
	
button_fail_8:
	button_press_9 [ebp + arg2], [ebp + arg3], button_size, button_9_x, button_9_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro '9', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_9:
	button_press_0 [ebp + arg2], [ebp + arg3], button_size, button_0_x, button_0_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro '0', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_0:
	button_press_Q [ebp + arg2], [ebp + arg3], button_size, button_Q_x, button_Q_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'Q', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_Q:
	button_press_W [ebp + arg2], [ebp + arg3], button_size, button_W_x, button_W_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'W', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_W:
	button_press_E [ebp + arg2], [ebp + arg3], button_size, button_E_x, button_E_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'E', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_E:
	button_press_R [ebp + arg2], [ebp + arg3], button_size, button_R_x, button_R_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'R', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_R:
	button_press_T [ebp + arg2], [ebp + arg3], button_size, button_T_x, button_T_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'T', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_T:
	button_press_Y [ebp + arg2], [ebp + arg3], button_size, button_Y_x, button_Y_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'Y', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_Y:
	button_press_U [ebp + arg2], [ebp + arg3], button_size, button_U_x, button_U_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'U', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_U:
	button_press_I [ebp + arg2], [ebp + arg3], button_size, button_I_x, button_I_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'I', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_I:
	button_press_O [ebp + arg2], [ebp + arg3], button_size, button_O_x, button_O_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'O', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_O:
	button_press_P [ebp + arg2], [ebp + arg3], button_size, button_P_x, button_P_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'P', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_P:
	button_press_A [ebp + arg2], [ebp + arg3], button_size, button_A_x, button_A_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'A', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_A:
	button_press_S [ebp + arg2], [ebp + arg3], button_size, button_S_x, button_S_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'S', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_S:
	button_press_D [ebp + arg2], [ebp + arg3], button_size, button_D_x, button_D_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'D', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_D:
	button_press_F [ebp + arg2], [ebp + arg3], button_size, button_F_x, button_F_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'F', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_F:
	button_press_G [ebp + arg2], [ebp + arg3], button_size, button_G_x, button_G_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'G', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_G:
	button_press_H [ebp + arg2], [ebp + arg3], button_size, button_H_x, button_H_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'H', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_H:
	button_press_J [ebp + arg2], [ebp + arg3], button_size, button_J_x, button_J_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'J', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_J:
	button_press_K [ebp + arg2], [ebp + arg3], button_size, button_K_x, button_K_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'K', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_K:
	button_press_L [ebp + arg2], [ebp + arg3], button_size, button_L_x, button_L_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'L', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_L:
	button_press_Z [ebp + arg2], [ebp + arg3], button_size, button_Z_x, button_Z_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'Z', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_Z:
	button_press_X [ebp + arg2], [ebp + arg3], button_size, button_X_x, button_X_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'X', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_X:
	button_press_C [ebp + arg2], [ebp + arg3], button_size, button_C_x, button_C_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'C', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere 
	
button_fail_C:
	button_press_V [ebp + arg2], [ebp + arg3], button_size, button_V_x, button_V_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'V', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_V:
	button_press_B [ebp + arg2], [ebp + arg3], button_size, button_B_x, button_B_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'B', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_B:
	button_press_N [ebp + arg2], [ebp + arg3], button_size, button_N_x, button_N_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'N', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_N:
	button_press_M [ebp + arg2], [ebp + arg3], button_size, button_M_x, button_M_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	make_text_roz_macro 'M', area, afisaj_x, afisaj_y 
	add afisaj_x, 10 
	jmp afisare_litere
	
button_fail_M:
	button_press_backspace [ebp + arg2], [ebp + arg3], button_backspace_width, button_backspace_height, button_backspace_x, button_backspace_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	cmp lines, 1
	jg exista_mai_multe_linii
	;daca a trecut de jump-ul de mai sus => lines <= 1
	cmp lines, 1
	jl eroare
	;daca a trecut de jump-ul de mai sus => lines = 1
	mov ebx, lines
	cmp litere[ebx], 0   ;verific daca litere[lines] = 0; daca da, se sare la eticheta1
	je eticheta1
	cmp litere[ebx], 0  ; daca litere[lines] > 0 sar la eticheta2
	jg eticheta2
	;daca a trecut de ultimele doua jump-uri, inseamna ca litere[lines] < 0 => eroare
	jmp eroare2
	
eticheta1:
	mov afisaj_x, 100
	mov afisaj_y, 300
	jmp afisare_litere
	
eticheta2:
	sub afisaj_x, 10
	make_text_roz_macro ' ', area, afisaj_x, afisaj_y
	dec litere[ebx] 
	jmp afisare_litere
	
exista_mai_multe_linii:
	;lines > 1
	mov ebx, lines
	cmp litere[ebx], 1
	je eticheta3  ; avem un singur caracter pe linie
	mov ebx, lines
	cmp litere[ebx], 1
	jg eticheta4
	mov ebx, lines
	cmp litere[ebx], 0 
	je mesaj
	mov ebx, lines
	cmp litere[ebx], 0
	jl eroare2
	
eticheta3:	
	sub afisaj_x, 10
	make_text_roz_macro ' ', area, afisaj_x, afisaj_y
	sub afisaj_y, 18  ;ne mutam cu o linie mai sus
	mov ebx, lines
	mov litere[ebx], 0
	dec lines
	mov ecx, lines 	;calculam valoarea lui x dupa formula: afisaj_x = 100 + litere[lines]*10
	mov eax, litere[ecx]   
	mov ebx, 10
	mul ebx
	add eax, 100          
	mov afisaj_x, eax
	jmp afisare_litere
	
eticheta4:
	sub afisaj_x, 10
	make_text_roz_macro ' ', area, afisaj_x, afisaj_y
	mov ebx, lines
	dec litere[ebx]
	jmp afisare_litere
	
eroare:
	push offset format_eroare 	;lines nu poate fi mai mic decat 1
	call printf
	add esp, 4
	jmp afisare_litere

mesaj:
	jmp eticheta3 	;litere[lines] = 0 => nu avem caractere scrise pe linia respectiva 
	
eroare2: 
	;litere[lines] < 0  
	mov ebx, lines
	push ebx
	push offset format_eroare2
	call printf
	add esp, 8
	jmp afisare_litere
	
button_fail_backspace:
	button_press_enter [ebp + arg2], [ebp + arg3], button_enter_width, button_enter_height, button_enter_x, button_enter_y
	cmp afisaj_x, 640
	jge cross_boundaries
	cmp afisaj_y, 480
	jge cross_boundaries 
	inc lines
	add afisaj_y, 18
	mov afisaj_x, 100
	jmp afisare_litere
	
button_fail_enter:
	jmp afisare_litere
	
cross_boundaries:
	push offset limite
	call printf
	add esp, 4
	jmp afisare_litere	

evt_timer:
	inc counter
	
afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_roz_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_roz_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_roz_macro edx, area, 10, 10
	
	
	;colorare ecran
	cmp ecran_colorat, 0 
	jne continua
	colorare_ecran 0FFC0CBh
	mov ecran_colorat, 1
continua:		
	mov ecran_colorat, 1
	
	
	;scriem un mesaj
	make_text_roz_macro 'O', area, 210, 10
	make_text_roz_macro 'N', area, 220, 10
	
	make_text_roz_macro ' ', area, 230, 10
	
	make_text_roz_macro 'S', area, 240, 10
	make_text_roz_macro 'C', area, 250, 10
	make_text_roz_macro 'R', area, 260, 10
	make_text_roz_macro 'E', area, 270, 10
	make_text_roz_macro 'E', area, 280, 10
	make_text_roz_macro 'N', area, 290, 10
	
	make_text_roz_macro ' ', area, 300, 10
	
	make_text_roz_macro 'K', area, 310, 10
	make_text_roz_macro 'E', area, 320, 10
	make_text_roz_macro 'Y', area, 330, 10
	make_text_roz_macro 'B', area, 340, 10
	make_text_roz_macro 'O', area, 350, 10
	make_text_roz_macro 'A', area, 360, 10
	make_text_roz_macro 'R', area, 370, 10
	make_text_roz_macro 'D', area, 380, 10

	;prima linie - colorare butoane
	colorare_buton button_1_x, button_1_y, button_size, 0D3D3D3h
	colorare_buton button_2_x, button_2_y, button_size, 0D3D3D3h
	colorare_buton button_3_x, button_3_y, button_size, 0D3D3D3h
	colorare_buton button_4_x, button_4_y, button_size, 0D3D3D3h
	colorare_buton button_5_x, button_5_y, button_size, 0D3D3D3h
	colorare_buton button_6_x, button_6_y, button_size, 0D3D3D3h
	colorare_buton button_7_x, button_7_y, button_size, 0D3D3D3h
	colorare_buton button_8_x, button_8_y, button_size, 0D3D3D3h
	colorare_buton button_9_x, button_9_y, button_size, 0D3D3D3h
	colorare_buton button_0_x, button_0_y, button_size, 0D3D3D3h
	colorare_buton button_backspace_x, button_backspace_y, button_backspace_height + 1, 0D3D3D3h
	colorare_buton button_backspace_x + button_backspace_height, button_backspace_y, button_backspace_height + 1, 0D3D3D3h
	colorare_buton button_backspace_x + button_backspace_height * 3 / 2, button_backspace_y, button_backspace_height + 1, 0D3D3D3h
	
	;prima linie - desenare butoane
	draw_button button_1_x, button_1_y, button_size, 0
	draw_button button_2_x, button_2_y, button_size, 0
	draw_button button_3_x, button_3_y, button_size, 0
	draw_button button_4_x, button_4_y, button_size, 0
	draw_button button_5_x, button_5_y, button_size, 0
	draw_button button_6_x, button_6_y, button_size, 0
	draw_button button_7_x, button_7_y, button_size, 0
	draw_button button_8_x, button_8_y, button_size, 0
	draw_button button_9_x, button_9_y, button_size, 0
	draw_button button_0_x, button_0_y, button_size, 0
	draw_rectangle button_backspace_x, button_backspace_y, button_backspace_width, button_backspace_height, 0
	
	
	;a doua linie - desenare butoane
	draw_button button_Q_x, button_Q_y, button_size, 0
	draw_button button_W_x, button_W_y, button_size, 0
	draw_button button_E_x, button_E_y, button_size, 0
	draw_button button_R_x, button_R_y, button_size, 0
	draw_button button_T_x, button_T_y, button_size, 0
	draw_button button_Y_x, button_Y_y, button_size, 0
	draw_button button_U_x, button_U_y, button_size, 0
	draw_button button_I_x, button_I_y, button_size, 0
	draw_button button_O_x, button_O_y, button_size, 0
	draw_button button_P_x, button_P_y, button_size, 0
	
	
	;a doua linie - colorare butoane
	colorare_buton button_Q_x, button_Q_y, button_size, 0D3D3D3h
	colorare_buton button_W_x, button_W_y, button_size, 0D3D3D3h
	colorare_buton button_E_x, button_E_y, button_size, 0D3D3D3h
	colorare_buton button_R_x, button_R_y, button_size, 0D3D3D3h
	colorare_buton button_T_x, button_T_y, button_size, 0D3D3D3h
	colorare_buton button_Y_x, button_Y_y, button_size, 0D3D3D3h
	colorare_buton button_U_x, button_U_y, button_size, 0D3D3D3h
	colorare_buton button_I_x, button_I_y, button_size, 0D3D3D3h
	colorare_buton button_O_x, button_O_y, button_size, 0D3D3D3h
	colorare_buton button_P_x, button_P_y, button_size, 0D3D3D3h

	
	;a treia linie - colorare butoane
	colorare_buton button_A_x, button_A_y, button_size, 0D3D3D3h
	colorare_buton button_S_x, button_S_y, button_size, 0D3D3D3h
	colorare_buton button_D_x, button_D_y, button_size, 0D3D3D3h
	colorare_buton button_F_x, button_F_y, button_size, 0D3D3D3h
	colorare_buton button_G_x, button_G_y, button_size, 0D3D3D3h
	colorare_buton button_H_x, button_H_y, button_size, 0D3D3D3h
	colorare_buton button_J_x, button_J_y, button_size, 0D3D3D3h
	colorare_buton button_K_x, button_K_y, button_size, 0D3D3D3h
	colorare_buton button_L_x, button_L_y, button_size, 0D3D3D3h
	colorare_buton button_enter_x, button_enter_y, button_enter_height + 1, 0D3D3D3h
	colorare_buton button_enter_x + button_enter_height, button_enter_y, button_enter_height + 1, 0D3D3D3h
	colorare_buton button_enter_x + button_enter_height * 3 / 2, button_enter_y, button_enter_height + 1, 0D3D3D3h
	
	
	;a treia linie - desenare butoane
	draw_button button_A_x, button_A_y, button_size, 0
	draw_button button_S_x, button_S_y, button_size, 0
	draw_button button_D_x, button_D_y, button_size, 0
	draw_button button_F_x, button_F_y, button_size, 0
	draw_button button_G_x, button_G_y, button_size, 0
	draw_button button_H_x, button_H_y, button_size, 0
	draw_button button_J_x, button_J_y, button_size, 0
	draw_button button_K_x, button_K_y, button_size, 0
	draw_button button_L_x, button_L_y, button_size, 0
	draw_rectangle button_enter_x, button_enter_y, button_enter_width, button_enter_height, 0

	
	;a patra linie - desenare butoane
	draw_button button_Z_x, button_Z_y, button_size, 0
	draw_button button_X_x, button_X_y, button_size, 0
	draw_button button_C_x, button_C_y, button_size, 0
	draw_button button_V_x, button_V_y, button_size, 0
	draw_button button_B_x, button_B_y, button_size, 0
	draw_button button_N_x, button_N_y, button_size, 0
	draw_button button_M_x, button_M_y, button_size, 0
	
	
	;a patra linie - colorare butoane
	colorare_buton button_Z_x, button_Z_y, button_size, 0D3D3D3h
	colorare_buton button_X_x, button_X_y, button_size, 0D3D3D3h
	colorare_buton button_C_x, button_C_y, button_size, 0D3D3D3h
	colorare_buton button_V_x, button_V_y, button_size, 0D3D3D3h
	colorare_buton button_B_x, button_B_y, button_size, 0D3D3D3h
	colorare_buton button_N_x, button_N_y, button_size, 0D3D3D3h
	colorare_buton button_M_x, button_M_y, button_size, 0D3D3D3h

	
	;text - prima linie
	make_text_gri_macro '1', area, button_1_x + 15, button_1_y + 10
	make_text_gri_macro '2', area, button_2_x + 15, button_2_y + 10
	make_text_gri_macro '3', area, button_3_x + 15, button_3_y + 10
	make_text_gri_macro '4', area, button_4_x + 15, button_4_y + 10
	make_text_gri_macro '5', area, button_5_x + 15, button_5_y + 10
	make_text_gri_macro '6', area, button_6_x + 15, button_6_y + 10
	make_text_gri_macro '7', area, button_7_x + 15, button_7_y + 10
	make_text_gri_macro '8', area, button_8_x + 15, button_8_y + 10
	make_text_gri_macro '9', area, button_9_x + 15, button_9_y + 10
	make_text_gri_macro '0', area, button_0_x + 15, button_0_y + 10
	make_text_gri_macro 'B', area, button_backspace_x + 5, button_backspace_y + 10
	make_text_gri_macro 'A', area, button_backspace_x + 15, button_backspace_y + 10
	make_text_gri_macro 'C', area, button_backspace_x + 25, button_backspace_y + 10
	make_text_gri_macro 'K', area, button_backspace_x + 35, button_backspace_y + 10
	make_text_gri_macro 'S', area, button_backspace_x + 45, button_backspace_y + 10
	make_text_gri_macro 'P', area, button_backspace_x + 55, button_backspace_y + 10
	make_text_gri_macro 'A', area, button_backspace_x + 65, button_backspace_y + 10
	make_text_gri_macro 'C', area, button_backspace_x + 75, button_backspace_y + 10
	make_text_gri_macro 'E', area, button_backspace_x + 85, button_backspace_y + 10
	
	
	;text - a doua linie
	make_text_gri_macro 'Q', area, button_Q_x + 15, button_Q_y + 10
	make_text_gri_macro 'W', area, button_W_x + 15, button_W_y + 10
	make_text_gri_macro 'E', area, button_E_x + 15, button_E_y + 10
	make_text_gri_macro 'R', area, button_R_x + 15, button_R_y + 10
	make_text_gri_macro 'T', area, button_T_x + 15, button_T_y + 10
	make_text_gri_macro 'Y', area, button_Y_x + 15, button_Y_y + 10
	make_text_gri_macro 'U', area, button_U_x + 15, button_U_y + 10
	make_text_gri_macro 'I', area, button_I_x + 15, button_I_y + 10
	make_text_gri_macro 'O', area, button_O_x + 15, button_O_y + 10
	make_text_gri_macro 'P', area, button_P_x + 15, button_P_y + 10
	
	
	;text - a treia linie
	make_text_gri_macro 'A', area, button_A_x + 15, button_A_y + 10
	make_text_gri_macro 'S', area, button_S_x + 15, button_S_y + 10
	make_text_gri_macro 'D', area, button_D_x + 15, button_D_y + 10
	make_text_gri_macro 'F', area, button_F_x + 15, button_F_y + 10
	make_text_gri_macro 'G', area, button_G_x + 15, button_G_y + 10
	make_text_gri_macro 'H', area, button_H_x + 15, button_H_y + 10
	make_text_gri_macro 'J', area, button_J_x + 15, button_J_y + 10
	make_text_gri_macro 'K', area, button_K_x + 15, button_K_y + 10
	make_text_gri_macro 'L', area, button_L_x + 15, button_L_y + 10
	make_text_gri_macro 'E', area, button_enter_x + 25, button_enter_y + 10
	make_text_gri_macro 'N', area, button_enter_x + 35, button_enter_y + 10
	make_text_gri_macro 'T', area, button_enter_x + 45, button_enter_y + 10
	make_text_gri_macro 'E', area, button_enter_x + 55, button_enter_y + 10
	make_text_gri_macro 'R', area, button_enter_x + 65, button_enter_y + 10
	
	
	;text - a patra linie
	make_text_gri_macro 'Z', area, button_Z_x + 15, button_Z_y + 10
	make_text_gri_macro 'X', area, button_X_x + 15, button_X_y + 10
	make_text_gri_macro 'C', area, button_C_x + 15, button_C_y + 10
	make_text_gri_macro 'V', area, button_V_x + 15, button_V_y + 10
	make_text_gri_macro 'B', area, button_B_x + 15, button_B_y + 10
	make_text_gri_macro 'N', area, button_N_x + 15, button_N_y + 10
	make_text_gri_macro 'M', area, button_M_x + 15, button_M_y + 10
	
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
