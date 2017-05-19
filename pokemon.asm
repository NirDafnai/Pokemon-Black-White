IDEAl
MODEL small
STACK 100h
DATASEG
			;stats;
	enemyCurrentHealth db 1
	playerCurrentHealth db 10
	playerPokemonLevel db 2
	enemyPokemonLevel db 1
	PlayerMaxHealth db 10
	enemyMaxHealth db 1
			;end stats;
	filename db 'test.bmp',0
	filehandle dw ?
	Header db 54 dup (0)
	Palette db 256*4 dup (0)
	ScrLine db 320 dup (0)
			;OUTPUT;
	ErrorMsg db 'Error', 13, 10,'$'
	combatMsg db 'Combat has begun$'
	menuMsg1 db 'Hello Player, press w to walk, and x to exit$'
	menuMsg2 db 'Press a to attack$'
	menuMsg3 db 'Press any key to continue...$'
	menuMsg4 db 'Press any key to switch turns...$'
	linefeed db 13, 10, "$"
	playerPokemonName db 'Pikachu$'
	pokemonNameMessage db 'Your Pokemon: $'
	playerHealthMessage db 'Pokemon health: $'
	playerEXPMessage db 'Pokemon experience is: $'
	playerLevelMessage db 'Pokemon level is: $'
	enemyPokemonName db 'Rattata$'
	enemyPokemonNameMsg db 'Enemy Pokemon Name: $'
	enemyPokemonLvlMsg db 'Enemy Pokemon Level: $'
	enemyPokemonHealthMsg db 'Enemy Pokemon health: $'
	switchTurnMsg db 'Press any key to switch turns.$'
	playerDmgMSG db 'You inflicted: $'
	enemyDmgMSG db 'The enemy inflicted: $'
	DmgMSG db ' DMG$'
			;end OUTPUT;
	playerPokemonDamage db 1
	playerEXP db 0
	playerMaxEXP db 10
	levelHealthMultiplier db 5
	enemyPokemonDamage db 1
	DMG db 0
	
	turn db 0
CODESEG
;push something to dedicate place for the random number in the stack and then call the procedure, pop to get the random number
proc randomGenerate
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	mov ah, 00h  ; interrupts to get system time        
	int 1Ah      ; CX:DX now hold number of clock ticks since midnight      
	mov  ax, dx
	xor  dx, dx
	mov  cx, 10    
	div  cx       ; now dx contains the remainder of the division - from 0 to 9
	xor bx, bx
	mov [bp+4], dx
	;mov [randomNumber], dl
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret
endp randomGenerate
proc combat
	enemyHealth equ [bp+4]
	playerHealth equ [bp+6]
	turn01 equ [bp+8]
	push bp
	mov bp, sp
	push dx
	push ax
	push bx
	push offset enemyCurrentHealth
	push offset enemyMaxHealth
	push offset levelHealthMultiplier
	push offset enemyPokemonLevel
	push offset playerPokemonLevel
	call generateEnemyStats
jumpToTurn:
	mov bx, turn01
	cmp [byte ptr bx], 0
	je playerTurn
	jne enemyTurn
playerTurn:
	call resetScreen
	call displayStats
	; new line
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	mov dx, offset menuMsg2
	mov ah, 09h
	int 21h
retry:
	mov ah, 07h
	int 21h
	cmp al, 'a'
	jne retry
	push offset DMG
	push ax
	call randomGenerate ;random number is in the stack segment
	push offset enemyCurrentHealth
	call attack
	call resetScreen
	call displayStats
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	push offset DMG
	call displayPlayerDMG
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	mov ah, 09
	mov dx, offset menuMsg4
	int 21h
	mov ah, 07h
	int 21h
	jmp check
enemyTurn:
	push offset DMG
	push ax
	call randomGenerate
	push offset playerCurrentHealth
	call attack
	call resetScreen
	call displayStats
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	push offset DMG
	call displayEnemyDMG
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	mov ah, 09
	mov dx, offset menuMsg3
	int 21h
	mov ah, 07h
	int 21h
check:
	mov bx, turn01
	xor [byte ptr bx], 1
	mov bx, enemyHealth
	cmp [byte ptr bx], 0
	jg checkPlayerHealth
	jmp finish2
checkPlayerHealth:
	mov bx, playerHealth
	cmp [byte ptr bx], 0
	jg jumpToTurn
finish2:
	pop bx
	pop ax
	pop dx
	pop bp
	ret 6
endp combat
proc attack
	DMG3 equ [bp+8]
	randomNumberVar equ [bp+6]
	health equ [bp+4]
	push bp
	mov bp, sp
	push ax
	push bx
	mov ax, randomNumberVar
	mov bx, DMG3
	mov [byte ptr bx], al
	mov bx, health
	cmp [byte ptr bx], al
	jb noHealthLeft
	sub [bx], al
	jmp finish
noHealthLeft:
	mov [byte ptr bx], 0
finish:
	pop bx
	pop ax
	pop bp
	ret 6
endp attack
proc menu
	push dx
	push ax
	call resetScreen
	mov dx, offset menuMsg1
	mov ah, 9h
	int 21h
	; new line
	mov ah, 09
	mov dx, offset linefeed
	int 21h
retry1:
	mov ah, 07h
	int 21h
	cmp al, 'w'
	je walk1
	cmp al, 'x'
	je exit
	jne retry1
	walk1:
	push ax
	call randomGenerate
	pop ax ;ax has the random number
	cmp ax, 4 
	jb retry1
	push offset turn
	push offset playerCurrentHealth
	push offset enemyCurrentHealth
	call combat
noCombat:
	pop ax
	pop dx
	ret
endp menu
proc displayStats
	push dx
	push ax
	;player pokemon stats
	mov dx, offset pokemonNameMessage
	mov ah, 9h
	int 21h
	mov dx, offset playerPokemonName
	mov ah, 9h
	int 21h
	; new line
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	mov dx, offset playerLevelMessage
	mov ah, 9h
	int 21h
	xor ax, ax
	mov al, [playerPokemonLevel]
	mov dl, 10
	div dl
	mov dl, al
	add dl, '0' 
	mov ah, 02h
	int 21h
	xor ax, ax
	mov al, [playerPokemonLevel]
	mov dl, 10
	div dl
	mov dl, ah
	add dl, '0'
	mov ah, 02h
	int 21h
	; new line
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	mov dx, offset playerHealthMessage
	mov ah, 9h
	int 21h
	xor ax, ax
	mov al, [playerCurrentHealth]
	mov dl, 10
	div dl
	mov dl, al
	add dl, '0' 
	mov ah, 02h
	int 21h
	xor ax, ax
	mov al, [playerCurrentHealth]
	mov dl, 10
	div dl
	mov dl, ah
	add dl, '0'
	mov ah, 02h
	int 21h
	mov dl, '/'
	mov ah, 02h
	int 21h
	xor ax, ax
	mov al, [playerMaxHealth]
	mov dl, 10
	div dl
	mov dl, al
	add dl, '0' 
	mov ah, 02h
	int 21h
	xor ax, ax
	mov al, [playerMaxHealth]
	mov dl, 10
	div dl
	mov dl, ah
	add dl, '0'
	mov ah, 02h
	int 21h
	; new line
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	mov dx, offset playerEXPMessage
	mov ah, 9h
	int 21h
	xor ax, ax
	mov al, [playerEXP]
	mov dl, 10
	div dl
	mov dl, al
	add dl, '0' 
	mov ah, 02h
	int 21h
	xor ax, ax
	mov al, [playerEXP]
	mov dl, 10
	div dl
	mov dl, ah
	add dl, '0'
	mov ah, 02h
	int 21h
	mov dl, '/'
	mov ah, 02h
	int 21h
	xor ax, ax
	mov al, [playerMaxEXP]
	mov dl, 10
	div dl
	mov dl, al
	add dl, '0' 
	mov ah, 02h
	int 21h
	xor ax, ax
	mov al, [playerMaxEXP]
	mov dl, 10
	div dl
	mov dl, ah
	add dl, '0'
	mov ah, 02h
	int 21h
	;end player pokemon stats
	;enemy pokemon stats
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	mov dx, offset enemyPokemonNameMsg
	mov ah, 9h
	int 21h
	mov dx, offset enemyPokemonName
	mov ah, 9h
	int 21h
	; new line
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	mov dx, offset enemyPokemonLvlMsg
	mov ah, 9h
	int 21h
	xor ax, ax
	mov al, [enemyPokemonLevel]
	mov dl, 10
	div dl
	mov dl, al
	add dl, '0' 
	mov ah, 02h
	int 21h
	xor ax, ax
	mov al, [enemyPokemonLevel]
	mov dl, 10
	div dl
	mov dl, ah
	add dl, '0'
	mov ah, 02h
	int 21h
	; new line
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	mov dx, offset enemyPokemonHealthMsg
	mov ah, 9h
	int 21h
	xor ax, ax
	mov al, [enemyCurrentHealth]
	mov dl, 10
	div dl
	mov dl, al
	add dl, '0' 
	mov ah, 02h
	int 21h
	xor ax, ax
	mov al, [enemyCurrentHealth]
	mov dl, 10
	div dl
	mov dl, ah
	add dl, '0'
	mov ah, 02h
	int 21h
	mov dl, '/'
	mov ah, 02h
	int 21h
	xor ax, ax
	mov al, [enemyMaxHealth]
	mov dl, 10
	div dl
	mov dl, al
	add dl, '0' 
	mov ah, 02h
	int 21h
	xor ax, ax
	mov al, [enemyMaxHealth]
	mov dl, 10
	div dl
	mov dl, ah
	add dl, '0'
	mov ah, 02h
	int 21h
	;end enemy pokemon stats
	pop ax
	pop dx
	ret
endp displayStats
proc resetScreen
	push ax
	mov ax, 3
	int 10h
	pop ax
	ret
endp resetScreen
proc generateEnemyStats
	pokemonLevel equ [bp+4]
	enemyLevel equ [bp+6]
	levelMultiplier equ [bp+8]
	maxEnemyHealth equ [bp+10]
	enemyCurrHealth equ [bp+12]
	;
	push bp
	mov bp, sp
	push ax
	push bx
	xor ax, ax
	mov bx, pokemonLevel
	mov al, [byte ptr bx]
	mov bx, enemyLevel
	mov [byte ptr bx], al
	mov bx, levelMultiplier
	mov ah, [byte ptr bx]
	mul ah
	mov bx, maxEnemyHealth
	mov [byte ptr bx], al
	mov bx, enemyCurrHealth
	mov [byte ptr bx], al
	pop bx
	pop ax
	pop bp
	ret 10
endp generateEnemyStats
proc displayPlayerDMG
	DMG1 equ [bp+4]
	push bp
	mov bp,sp
	push dx
	push ax
	push bx
	mov ah, 09h
	mov bl, 0Eh
	mov bh, 0
	mov cx, 20
	int 10h
	mov ah, 09h
	mov dx, offset playerDmgMSG
	int 21h
	mov bx, DMG1
	mov dl, [byte ptr bx]
	add dl, '0'
	mov ah, 02h
	int 21h
	mov ah, 09h
	mov dx, offset DmgMSG
	int 21h
	pop bx
	pop ax
	pop dx
	pop bp
	ret 2
endp displayPlayerDMG
proc displayEnemyDMG
	DMG2 equ [bp+4]
	push bp
	mov bp,sp
	push dx
	push ax
	push bx
	mov ah, 09h
	mov bl, 04h
	mov bh, 0
	mov cx, 26
	int 10h
	mov ah, 09h
	mov dx, offset enemyDmgMSG
	int 21h
	mov bx, DMG2
	mov dl, [byte ptr bx]
	add dl, '0'
	mov ah, 02h
	int 21h
	mov ah, 09h
	mov dx, offset DmgMSG
	int 21h
	pop bx
	pop ax
	pop dx
	pop bp
	ret 2
endp displayEnemyDMG
proc OpenFile
	; Open file
	mov ah, 3Dh
	xor al, al
	mov dx, offset filename
	int 21h
	jc openerror
	mov [filehandle], ax
	ret
openerror:
	mov dx, offset ErrorMsg
	mov ah, 9h
	int 21h
	ret
endp OpenFile
proc ReadHeader
	; Read BMP file header, 54 bytes
	mov ah,3fh
	mov bx, [filehandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	ret
endp ReadHeader
proc ReadPalette
	; Read BMP file color palette, 256 colors * 4 bytes (400h)
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	ret
endp ReadPalette
proc CopyPal
	; Copy the colors palette to the video memory
	; The number of the first color should be sent to port 3C8h
	; The palette is sent to port 3C9h
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0
	; Copy starting color to port 3C8h
	out dx,al
	; Copy palette itself to port 3C9h
	inc dx
PalLoop:
	; Note: Colors in a BMP file are saved as BGR values rather than RGB.
	mov al,[si+2] ; Get red value.
	shr al,2 ; Max. is 255, but video palette maximal
	; value is 63. Therefore dividing by 4.
	out dx,al ; Send it.
	mov al,[si+1] ; Get green value.
	shr al,2
	out dx,al ; Send it.
	mov al,[si] ; Get blue value.
	shr al,2
	out dx,al ; Send it.
	add si,4 ; Point to next color.
	; (There is a null chr. after every color.)
	loop PalLoop
	ret
endp CopyPal
proc CopyBitmap
	; BMP graphics are saved upside-down.
	; Read the graphic line by line (200 lines in VGA format),
	; displaying the lines from bottom to top.
	mov ax, 0A000h
	mov es, ax
	mov cx,200
PrintBMPLoop:
	push cx
	; di = cx*320, point to the correct screen line
	mov di,cx
	shl cx,6
	shl di,8
	add di,cx
	; Read one line
	mov ah,3fh
	mov cx,320
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,320
	mov si,offset ScrLine
	rep movsb ; Copy line to the screen
	;rep movsb is same as the following code:
	;mov es:di, ds:si
	;inc si
	;inc di
	;dec cx
	pop cx
	loop PrintBMPLoop
	ret
endp CopyBitmap
start:
	mov ax, @data
	mov ds, ax
	; Graphic mode
	mov ax, 13h
	int 10h
	; Process BMP file
	call OpenFile
	call ReadHeader
	call ReadPalette
	call CopyPal
	call CopyBitmap
	; Wait for key press
	mov ah,1
	int 21h
	; Back to text mode
	mov ah, 0
	mov al, 2
	int 10h
	call menu
exit:
	mov ax, 4c00h
	int 21h
END start