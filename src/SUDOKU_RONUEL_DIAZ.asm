;Sudoku In Assembly 
;By: Ronuel Diaz


.model tiny

.code
org 100h

.386

start:
	mov si,0
	mov di,0
	call initialize_seed
	call random_pattern ; random difficulty 
	call display_start_message ;
	call generate_answer ; generates answer array 
	call display_instructions 
	call move_cursor_to_beginning ;this moves the cursor to the top left corner
	call clear_screen 
	call draw_board
	call draw_partial ; draw the static values 
	
update: ;Handles the users input
	call get_input
	cmp ah,4bh ;<
	jz move_left
	cmp ah,4dh ;>
	jz move_right
	cmp ah,48h ;^
	jz move_up
	cmp ah,50h ;v
	jz move_down
	cmp ah,02h
	jnge next_
	cmp ah,0ah
	jnle next_
	add ah,2fh
	mov al,ah
	call insert_into_buff
	cmp bl,1
	jz next_
	call draw_input2
	call erase_error
	call check_complete
	cmp bl,1
	jz complete
	
	
	jmp update
	
	
next_:
    call draw_error	 
	cmp ah,10h ;q
	jnz update
	call clear_screen
    int 20h
    ret
    
complete:
    push si
    push di    
    mov ah,2
    mov dh,5
    mov dl,45
    int 10h
    xor ax,ax
    
    mov ah,9
    sub dx,dx
    mov dx,offset Winner
    int 21h
	
    mov ah,2
    mov dh,13h
    mov dl,0
    int 10h
    xor ax,ax
	
    pop si
    pop di
   
    ret 

       
    
check_complete: ; checks if the board is complete (if complete then correct) 
push si
push di
mov si,0
compl:
    cmp answer_buff[si],'0'
    jz not_compl
    inc si
    cmp si,81
    jnz compl
    mov bx,1
    pop di
    pop si
    ret
    
    
not_compl:
    mov bx,0
    pop di
    pop si
    ret
random_pattern: ; selects a random pattern(difficulty) 
    call rand
    mov ax,rand_buffer
    xor dx,dx
    xor cx,cx
    mov bx,4
    div bx
    mov si,3Ch
    mov ax,si
    mov bx,dx
    mul bx
    mov si,ax
    mov di,0
    
    looper:
        mov cx,pattern[si]
        mov patterns[di],cx
        inc si
        inc si
        inc di
        inc di
        cmp di,3ch
        jnz looper
        
        
    ret 
    
    
    


draw_input2: ;Draw the users input 
    mov ah,09h
    mov bh,0h
    mov bl,072h
    mov cx,1
    int 10h
    ret 
draw_error: ;displays error message when incorrect input 
    push ax
    push si
    push di
    
    mov ah,2
    mov dh,5
    mov dl,45
    int 10h
    xor ax,ax
    
    mov ah,9
    sub dx,dx
    mov dx,offset Error
    int 21h
    
    mov ah,2
    mov dh,6
    mov dl,45
    int 10h
    xor ax,ax
    
    mov ah,9
    sub dx,dx
    mov dx,offset Error2
    int 21h
    
    pop di
    pop si
    call move_cursor
    pop ax
	ret
erase_error: ; gets rid of above error message 
      push si
    push di
    mov ah,2
    mov dh,5
    mov dl,45
    int 10h
    xor ax,ax
    mov ah,9
    mov al,' '
    mov cx,23h
    int 10h
    
     mov ah,2
    mov dh,6
    mov dl,45
    int 10h
    xor ax,ax
    
    mov ah,9
    mov al,' '
    mov cx,23h
    int 10h
    
    pop di
    pop si
    call move_cursor
    
	ret
    
insert_into_buff: ; inserts users input into a temp answer array 
     push si
    push di
    push ax
   
    
    
    xor ax,ax
    xor bx,bx
    xor dx,dx
    xor cx,cx
    mov ax,si
    mov bx,9
    mul bx
    add ax,di
    xchg ax,di
    pop ax
    call check_static
    cmp bx,1
    jz insert_cancel
    
    ;insert the answer check loop. 
     
    call check_row2
    cmp bx,1
    jz insert_cancel
    call check_colm2
    cmp bx,1
    jz insert_cancel
    call check_square2
    cmp bx,1
    jz insert_cancel
    
    
   
    mov answer_buff[di],al
    pop di
    pop si
    mov bx,0
    ret
    
    
    insert_cancel:
    pop di
    pop si
    mov bx,1
    ret

check_row2: ; checks the row constraint for users input 
push di
push si
push ax

mov ax,di
mov bx,9
div bx
mov di,dx
mov cx,0

row_check2: ; loop name 
    mov ax,cx
    mul bx
    add ax,di
    mov si,ax
    pop ax
    
    cmp al,answer_buff[si]
    jz rcheck_canc
    
    push ax
    inc cx
    cmp cx,9
    jnz row_check2
    mov bx,0
    pop ax
    pop si
    pop di
    
    ret
    
    rcheck_canc:
        mov bx,1
        pop si
        pop di
        ret 


check_colm2: ; checks column constrain for user input
push di
push si
push ax

mov ax,di
mov bx,9
div bx
mov si,ax
mov cx,0

colm_check2:
    mov ax,si
    mul bx
    add ax,cx
    mov di,ax
    pop ax
    
    cmp al,answer_buff[di]
    jz ccheck_canc
   
    push ax
    inc cx
    cmp cx,9
    jnz colm_check2
    mov bx,0
    pop ax
    pop si
    pop di
    
    ret
    
    ccheck_canc:
        mov bx,1
        pop si
        pop di
        ret

check_square2:   ;check the square to check if any duplicate values for user input 
push di
push si
push ax

mov ax,di 
mov cx,9
div cx
mov di,dx
xor dx,dx
mov si,ax
mov cx,3
div cx
mov row_buff,si
sub si,dx

mov colm_buff,di
mov square_row_high,si
add square_row_high,2

csq1:
    mov ax,di
    xor dx,dx
    div cx
    sub di,dx
    mov square_colm_high,di
    add square_colm_high,2
    csq2:
       mov ax,si
       mov bx,9
       mul bx
       add ax,di
       mov dx,si
       mov si,ax 

       pop ax
    
       cmp al,answer_buff[si]
       jz csq_cancel
    
       push ax
       mov si,dx
       inc di
       cmp di,square_colm_high
       jle csq2
       mov di,colm_buff
       inc si
       cmp si,square_row_high
       jle csq1
       
      





pop ax
pop si
pop di
mov bx,0
ret

csq_cancel:
    sub ax,2fh
    pop si
    pop di
    mov bx,1
    ret
    

    
    
check_static:; makes sure no static values are changed 
push si
mov si,0
stat1:
    cmp di,patterns[si]
    jz stat_cancel
    inc si
    inc si
    cmp si,3Ch
    jnge stat1
    pop si
    ret
    
    
    stat_cancel:
        mov bx,1
        pop si
        ret   
	
clear_screen:
	mov ax, 0600h        
	mov bh, 01110001b    
	mov cx, 0000h        
	mov dx, 1950h        
	int 10h
	ret
	
move_cursor_to_beginning:; moves cursor to the top corner of the screen 
	mov ah,02h
	mov bh,0
	mov dx,0
	int 10h
	ret
	
draw_board: ; draws the sudoku board template
	mov ah,9
    sub dx,dx
    mov dx,offset first
    int 21h
	mov ah,02h
	mov bh,0
	mov dh,1
	mov dl,3
	int 10h
	ret

draw_numbers: ;; draws the answer array 
    mov pattern_buff,0
	mov si,-1
	loop1:
	    inc si
		mov di,-1
		loop2:
	        inc di
	        
			mov ax,di
			mov bx,si
			mov cx,9
			mul cx
			add ax,bx
			
			
			
			jnz cont
			call draw_answer_array
		    add dx,2
		cont:
			cmp di,8
			jnz loop2
			cmp si,8
			jnz loop1
			ret

draw_partial: ; Draws the pattern
xor ax,ax
xor bx,bx
xor dx,dx
xor cx,cx
mov si,0
mov di,0

part1:
    cmp di,patterns[si]
    jz draw
    inc di
    cmp di,81
    jnge part1
    mov si,0
    mov di,0
    call move_cursor
    ret
    draw:
    call draw_answer_array
    inc si
    inc si
    jmp part1    
        
			  
			 
			

	
draw_answer_array: ;draws physical values 
    xor ax,ax
    xor bx,bx
    xor dx,dx
    xor cx,cx
    push di
    push si
    mov ax,di
    mov bx,9
    div bx 
    mov si,ax
    mov di,dx     
	call move_cursor
	
	pop si
	pop di
	
	mov ah,0h
	mov al,sudoku_answer_array[di] 
	mov answer_buff[di],al
	call draw_input
	ret
	
	
	
draw_input: ;input needs to be at al. 
	mov ah,0ah
	mov cx,1
	int 10h
	ret
	
get_input: ; gets Key presses
	xor ax,ax
	mov ah,0h
	int 16h
	ret
	
	

insert_answer: ; inserts answers that comply with row,colm, and box check into the temp answer array



xor ax,ax
xor cx,cx
xor bx,bx
mov cx,colm_buff
mov ax,row_buff
mov bx,9

mul bx

add ax,cx

xchg ax,di
mov bx , rand_buffer
add sudoku_answer_array[di] , bl
                                       
xchg ax,di

ret





	
move_left:
	cmp di,0
	jz update
	sub di,1
	call move_cursor	
    jmp update
	
move_right:
	cmp di,8
	jz update
	add di,1
	call move_cursor
	jmp update
	
move_up:
	cmp si,0
	jz update
	sub si,1
	call move_cursor
	jmp update
	
move_down:
	cmp si,8
	jz update
	add si,1
	call move_cursor
	jmp update
	
move_cursor:
    xor ax,ax
    xor bx,bx
    xor cx,cx
    xor dx,dx
	mov ah,02h
	mov dh,position_row_array[si]
	mov dl,position_column_array[di]
	int 10h	
	ret       
	
get_entry:
   xor ax,ax
   mov ax,si
   mov bx,9
   mul bx
   add ax,di
   xchg ax,di
   mov bl,sudoku_answer_array[di]
   sub bl,'0'
   xchg ax,di
   ret  
	
generate_answer: ;fills the sudoku answer_array with an array for the puzzle. preset at the beginning of any game. 
mov es,sp
mov si,0
gen1:
    mov counter,0
    mov di,0
    gen2:   
        call rand
        call check_row
        cmp bx,1
        jz incre
        call check_colm
        cmp bx,1
        jz incre
        call check_square
        cmp bx,1
        jz incre
         
        mov row_buff,si
        mov colm_buff,di 
        call insert_answer
        
        inc di
        cmp di,9
		jnz gen2
		inc si
		cmp si,9
		jnz gen1
		mov sp,es
		ret
    incre:
        mov row_buff,si
        mov colm_buff,di
	    cmp counter,limit
	    jz restart
	    add counter,1
	    jmp gen2
    restart: 
        cmp backtracking_counter,backtracking_limit
        jz clrarray
        
        xor ax,ax
        xor cx,cx
        xor bx,bx
        mov cx,colm_buff
        mov ax,row_buff
        mov bx,9
        mul bx
        add ax,cx
        mov di,ax
        sub ax,cx
        sub ax,1
        
        
        clrloop:
            mov sudoku_answer_array[di],'0'
            dec di
            cmp di,ax
            jnz clrloop
        add backtracking_counter,1
        mov colm_buff,0
        jmp gen1
        
        clrarray:
        mov di,80
        
        ers_loop:
        mov sudoku_answer_array[di],'0'
        dec di
        cmp di,-1
        jnz ers_loop 
        
        
        mov colm_buff,0
        mov row_buff,0
        mov si,0
        mov backtracking_counter,0
        jmp gen1

rand: ;random number generator 1-9 (psuedo random>      
    mov  ax, initial_seed
    mov cx,multiplier 
    imul cx
    mov initial_seed,ax
    xor dx,dx
    mov  cx, 9    
    div  cx
    add dx,1       ; here dx contains the remainder of the division - from 1 to 9
	mov rand_buffer,dx
	ret 
; these checks are specific for generating the answer board. 	
check_row:         ; check the row for any duplicate value 
  xor cx,cx
  mov cx,si
  row1:
    call get_entry
    cmp rand_buffer,bx
    jz row_cancel
    dec si
    cmp si,0
    jge row1
    mov bx,0
    mov si,cx
    ret
    row_cancel:
        mov bx,1
        mov si,cx
        ret 
check_colm:     ;check the column for any duplicate value.
  xor cx,cx
  mov cx,di 
  clm1:
    call get_entry
    cmp rand_buffer,bx
    jz colm_cancel
    dec di
    cmp di,0
    jge clm1
    mov bx,0
    mov di,cx
    ret
    colm_cancel:
        mov bx,1
        mov di,cx
        ret  
        
check_square:   ;check the square to check if any duplicate values 
mov row_buff,si
mov colm_buff,di

mov ax,si 
mov cx,3
div cx
sub si,dx
mov square_row_high,si
add square_row_high,2

sq1:
    mov di,colm_buff
    mov ax,di
    xor dx,dx
    div cx
    sub di,dx
    mov square_colm_high,di
    add square_colm_high,2
    sq2:
       call get_entry
       cmp rand_buffer,bx
       jz sq_cancel
       inc di
       cmp di,square_colm_high
       jle sq2
       inc si
       cmp si,square_row_high
       jle sq1
       
      




xchg row_buff,si
xchg colm_buff,di

ret

sq_cancel:
    mov bx,1
    xchg row_buff,si
    xchg colm_buff,di
    ret 
    
    
initialize_seed: ; initialize the rand seed at the beginning 
    mov AH,2CH
    int 21h
    mov initial_seed,dx
    xor dx,dx
    ret
    	
display_start_message:
	mov ah,9
    sub dx,dx
    mov dx,offset WELCOME
    int 21h
	ret

display_instructions:
	mov ah,9
    sub dx,dx
    mov dx,offset instructions
    int 21h
    
loopy:
	call get_input
    cmp ah,01ch
    jnz loopy
    
	ret  
	
first db 201," ===+===+========+===+========+===+=== ",187,10,13,"||   |   |   ||   |   |   ||   |   |   ||",10,13,"||---+---+---||---+---+---||---+---+---||",10,13,"||   |   |   ||   |   |   ||   |   |   ||",10,13,"||---+---+---||---+---+---||---+---+---||",10,13,"||   |   |   ||   |   |   ||   |   |   ||",10,13,"||===+===+===  ===+===+===  ===+===+===||",10,13,"||   |   |   ||   |   |   ||   |   |   ||",10,13,"||---+---+---||---+---+---||---+---+---||",10,13,"||   |   |   ||   |   |   ||   |   |   ||",10,13,"||---+---+---||---+---+---||---+---+---||",10,13,"||   |   |   ||   |   |   ||   |   |   ||",10,13,"||===+===+===  ===+===+===  ===+===+===||",10,13,"||   |   |   ||   |   |   ||   |   |   ||",10,13,"||---+---+---||---+---+---||---+---+---||",10,13,"||   |   |   ||   |   |   ||   |   |   ||",10,13,"||---+---+---||---+---+---||---+---+---||",10,13,"||   |   |   ||   |   |   ||   |   |   ||",10,13,200," ===+===+========+===+========+===+=== ",188,"$"
position_column_array db 3,7,11,16,20,24,29,33,37
position_row_array db 1,3,5,7,9,11,13,15,17	
sudoku_answer_array db 81 dup('0')
answer_buff db 81 dup('0')
multiplier dw 38933
initial_seed dw 1023
rand_buffer dw 0  
counter dw 0 
backtracking_limit EQU 10
backtracking_counter dw 0  
limit equ 80
row_buff dw 0
colm_buff dw 0
square_colm_high dw 0
square_row_high dw 0 

pattern_buff dw 0
patterns dw 30 dup(0)
pattern dw 2,4,5,8,9,14,16,18,29,30,34,36,37,43,44,46,50,51,62,71,72,75,76,78,-1,-1,-1,-1,-1,-1
         dw 12,14,15,16,19,22,23,24,26,29,31,34,35,45,46,49,51,54,56,57,58,61,64,65,66,68,-1,-1,-1,-1
         dw 3,7,16,17,21,22,23,26,29,31,35,37,40,43,45,49,51,54,57,58,59,63,64,73,77,-1,-1,-1,-1,-1
         dw 3,6,7,9,13,14,16,17,19,23,30,32,33,34,35,45,46,47,48,50,57,61,63,64,66,67,71,73,74,77
WELCOME db "Prepraring Sudoku Board Please Wait...",10,13,"$" 

Error db "Sorry you cant make that move$"
Error2 db "check your rows,colmns, and boxes$"  

Winner db "Congrats you did it!$"
Instructions db "Q:QUIT",10,13,"Arrow Keys: Move Cursor",10,13,"1-9: Place Number Pressed",10,13,"Press Enter to Begin$"
end start