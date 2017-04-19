IDEAl
MODEL small
STACK 100h
DATASEG
	filename db 'test.bmp',0
	filehandle dw ?
	Header db 54 dup (0)
	Palette db 256*4 dup (0)
	ScrLine db 320 dup (0)
	ErrorMsg db 'Error', 13, 10,'$'
	combatMsg db 'Combat has begun$'
	menuMsg1 db 'Hello Player, press w to walk, and x to exit$'
	linefeed db 13, 10, "$"
	randomNumber db 0
	playerPokemonName db 'Pikachu$'
	playerPokemonLevel db 1
	playerCurrentHealth db 10
	PlayerMaxHealth db 10
	pokemonNameMessage db 'Your Pokemon: $'
	playerHealthMessage db 'Pokemon health: $'
	playerEXPMessage db 'Pokemon experience is: $'
	playerLevelMessage db 'Pokemon level is: $'
	playerEXP db 0
	playerMaxEXP db 10
CODESEG
proc randomGenerate
	push ax
	push cx
	push dx
	mov ah, 00h  ; interrupts to get system time        
	int 1Ah      ; CX:DX now hold number of clock ticks since midnight      
	mov  ax, dx
	xor  dx, dx
	mov  cx, 10    
	div  cx       ; now dx contains the remainder of the division - from 0 to 9
	mov [randomNumber], dl
	pop dx
	pop cx
	pop ax
	ret
	endp
proc walkMenu
	mov dx, offset menuMsg1
	mov ah, 9h
	int 21h
	; new line
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	mov ah, 07h
	int 21h
	cmp al, 'w'
	je walk1
	cmp al, 'x'
	je exit
	endp
walk1:
call walk
	proc OpenFile
		; Open file
		mov ah, 3Dh
		xor al, al
		mov dx, offset filename
		int 21h
		jc openerror
		mov [filehandle], ax
		ret
			proc walk
		call randomGenerate
	cmp [randomNumber], 4
	jb noCombat
	call combat
noCombat:
	endp walk
	jmp exit
	proc combat
	mov dx, offset combatMsg
	mov ah, 9h
	int 21h
	; new line
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	call playerPokemonStats
	endp combat
	jmp exit
proc playerPokemonStats
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
	ret
endp
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
	call walkMenu
exit:
	mov ax, 4c00h
	int 21h
END start