IDEAl
MODEL small
STACK 100h
DATASEG
			;stats;
	enemyCurrentHealth db 1
	playerCurrentHealth db 5
	playerPokemonLevel db 1
	enemyPokemonLevel db 1
	PlayerMaxHealth db 5
	enemyMaxHealth db 5
	enemyPokemonID db 1
	coins db 25
	healthPotions db 3
			;end stats;
	filename db 'test.bmp',0
	filehandle dw ?
	Header db 54 dup (0)
	Palette db 256*4 dup (0)
	ScrLine db 320 dup (0)
			;OUTPUT;
	earnCoinMSG db 'Coins earned: $'
	coinMSG db 'Your coins: $'
	pokemonHealMSG db 'Your pokemon is fully healed.$'
	insufficentCoinsMSG db 'Not enough coins, earn more coins in combat to proceed.$'
	potionAmountMSG db 'Your potions: $'
	pokestationMSG1 db 'Welcome to the Pokestation!$'
	pokestationHealMSG1 db 'Heal your pokemon - $'
	pokestationHealMSG2 db '5 Coins$'
	pokestationBuyMSG1 db 'Buy a health potion for your pokemon - $'
	pokestationBuyMSG2 db '3 Coins$'
	ErrorMsg db 'Error', 13, 10,'$'
	combatMsg db 'Combat has begun$'
	menuMsg1 db 'Welcome to Pokemon Black & White$'
	walkMSG db 'Walk$'
	pokestationMSG db 'Pokestation$'
	exitMSG db 'Exit$'
	menuMsg2 db 'Use ^ arrow key to navigate up, use v arrow key to navigate down$'
	menuMsg3 db 'Press any key to continue...$'
	attackMSG db '   Attack$'
	shockMSG db '   Thunder Shock$'
	healMSG db '   Heal$'
	runMSG db '   Run$'
	linefeed db 13, 10, "$"
	noPotionsLeftMSG db 'You have no potions left! buy more at the pokestation$'
	playerPokemonName db 'Pikachu$'
	pokemonNameMessage db 'Your Pokemon: $'
	playerHealthMessage db 'Pokemon health: $'
	potionsLeftMSG db 'Amount of potions left: $'
	playerEXPMessage db 'Pokemon experience is: $'
	playerLevelMessage db 'Pokemon level is: $'
	pokemonInjuredMessage db 'Your pokemon is injured and cannot fight, heal him at the pokestation.$'
	enemyPokemonName db 'AAAAAAAA$'
	enemyPokemonName1 db 'Rattata$'
	enemyPokemonName2 db 'Magikarp$'
	enemyPokemonName3 db 'Zubat$'
	enemyPokemonName4 db 'Caterpie$'
	enemyPokemonNameMsg db 'Enemy Pokemon Name: $'
	enemyPokemonLvlMsg db 'Enemy Pokemon Level: $'
	enemyPokemonHealthMsg db 'Enemy Pokemon health: $'
	playerDmgMSG db 'You inflicted: $'
	enemyDmgMSG db 'The enemy inflicted: $'
	DmgMSG db ' DMG$'
	playerWinMSG db 'Enemy pokemon has fainted!$'
	enemyWinMSG db 'PLayer pokemon has fainted!$'
	afterShockMSG db 'Enemy pokemon is paralyzed! strike with all haste!$'
	shockLimitMSG db 'You can only shock your enemy once.$'
	playerHealMSG db 'You healed for: $'
	EarnEXPMSG db 'You earned: $'
	levelUpMSG db 'You leveled up!$'
	EXPMSG db ' EXP$'
	HPMSG db ' HP$'
	spaces db '						  $'
	spaces02 db '						    $'
	lines db '--------------------------------$'
	lines02 db '|-------------------------------$'
	runFailMSG db 'You stumbled over a rock and broke your nose, ouch!$'
	runSuccessMSG db 'You were able to run away from the duel!$'
			;end OUTPUT;
	isShocked db 0
	shockLimit db 1
	didPlayerLevelUp db 0
	playerPokemonDamage db 1
	playerEXP db 0
	playerMaxEXP db 10
	levelHealthMultiplier equ 5
	levelEXPMultiplier equ 2
	enemyPokemonDamage db 1
	remainder db 0
	turn db 0
CODESEG
;this prodedure generates a random number and saves it in a chosen dedicated space in the stack
;input: anything to dedicate a place for the number in the stack
;output: random number in dedicated place in the stack
proc randomGenerate
;push something to dedicate place for the random number in the stack and then call the procedure, pop to get the random number
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	mov ah, 02Ch ;puts in dl 1/100 seconds
	int 21h
	xor ax, ax
	mov al, dl
	mov dl, 10
	div dl ;ah holds the remainder, our random number.
	xor dx, dx
	mov dl, ah
	mov [bp+4], dx
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret
endp randomGenerate
;this procedure is the main procedure of the game, it manages the game and it includes most of the combat system, like turns, most of the functions like shock, run, leveling up and such. 
;input: coin amount, potion amount, player's maximum health, the amount of times the player can shock, player's maximum experience, player's current experience, turn(0 or 1), player's current health, enemy's current health
;output: earned exp, earned coins, earned levels.
proc combat
	enemyHealth equ [bp+4]
	playerHealth equ [bp+6]
	turn01 equ [bp+8]
	currentEXP equ [bp+10]
	maxEXP equ [bp+12]
	_shockLimit equ [bp+14]
	_playerMaxHealth equ [bp+16]
	_healthPotions1 equ [bp+18]
	_coins2 equ [bp+20]
	push bp
	mov bp, sp
	push dx
	push ax
	push bx
	push cx
	push si
	push di
	push offset shockLimit
	push offset enemyPokemonID
	push offset turn
	push offset playerMaxHealth
	push offset playerCurrentHealth
	push offset enemyCurrentHealth
	push offset enemyMaxHealth
	push offset enemyPokemonLevel
	push offset playerPokemonLevel
	call generateStats
jumpToTurn:
	mov bx, turn01
	cmp [byte ptr bx], 0
	je playerTurn
	jne enemyTurn
playerTurn:
	call resetScreen
	mov ah, 09
	mov dx, offset menuMsg2
	int 21h
	mov dx, offset linefeed
	int 21h
	mov bl, 0Eh
	mov bh, 0
	mov cx, 9
	int 10h
	mov dx, offset attackMSG
	int 21h
	mov dx, offset linefeed
	int 21h
	mov bx, _shockLimit
	cmp [byte ptr bx], 1
	je blue
grey:
	mov bl, 08h
	mov bh, 0
	mov cx, 16
	int 10h
	jmp displayMSG
blue:
	mov bl, 01h
	mov bh, 0
	mov cx, 16
	int 10h
displayMSG:
	mov dx, offset shockMSG
	int 21h
	mov dx, offset linefeed
	int 21h
	mov bl, 02h
	mov bh, 0
	mov cx, 7
	int 10h
	mov dx, offset healMSG
	int 21h
	mov dx, offset linefeed
	int 21h
	mov bl, 0Bh
	mov bh, 0
	mov cx, 6
	int 10h
	mov dx, offset runMSG
	int 21h
	call displayStats
	; new line
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	mov si, 1
	jmp pointAttack
retry:
	mov ah, 00h
	int 16h
	cmp ah, 050h
	je arrowDown
	cmp ah, 048h
	je arrowUp
	cmp ah, 01Ch
	je isEnter
	jne retry
arrowDown:
	cmp si, 4
	je reset
	inc si
	jmp checkPlace
arrowUp:
	cmp si, 1
	je reset2
	dec si
	jmp checkPlace
isEnter:
	cmp si, 1
	je attack1
	cmp si, 2
	je shock1
	cmp si, 3
	je heal1
	cmp si, 4
	je run
reset:
	mov si, 1
	jmp checkPlace
reset2:
	mov si, 4
	jmp checkPlace
checkPlace:
	cmp si, 1
	je pointAttack
	cmp si, 2
	je pointShock
	cmp si, 3
	je pointHeal
	cmp si, 4
	je pointRun
pointAttack:
	xor bx, bx
	mov ah, 02
	mov dl, 00
	mov dh, 02
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	mov dl, 00
	mov dh, 03
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	mov dl, 00
	mov dh, 04
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	mov dl, 00
	mov dh, 01
	int 10h
	mov dl, '-'
	int 21h
	mov dl, '-'
	int 21h
	mov dl, '>'
	int 21h
	mov dl, 0
	mov dh, 05
	int 10h
	jmp retry
pointShock:
	mov ah, 02
	mov dl, 00
	mov dh, 01
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	mov dl, 00
	mov dh, 03
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	mov dl, 00
	mov dh, 04
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	xor bx, bx
	mov dl, 00
	mov dh, 02
	int 10h
	mov dl, '-'
	int 21h
	mov dl, '-'
	int 21h
	mov dl, '>'
	int 21h
	mov dl, 0
	mov dh, 05
	int 10h
	jmp retry
pointHeal:
	mov ah, 02
	mov dl, 00
	mov dh, 01
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	mov dl, 00
	mov dh, 02
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	mov dl, 00
	mov dh, 04
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	xor bx, bx
	mov dl, 00
	mov dh, 03
	int 10h
	mov dl, '-'
	int 21h
	mov dl, '-'
	int 21h
	mov dl, '>'
	int 21h
	mov dl, 0
	mov dh, 05
	int 10h
	jmp retry
pointRun:
	mov ah, 02
	mov dl, 00
	mov dh, 01
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	mov dl, 00
	mov dh, 02
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	mov dl, 00
	mov dh, 03
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	xor bx, bx
	mov dl, 00
	mov dh, 04
	int 10h
	mov dl, '-'
	int 21h
	mov dl, '-'
	int 21h
	mov dl, '>'
	int 21h
	mov dl, 0
	mov dh, 05
	int 10h
	jmp retry
shock1:
	call resetScreen
	call displayStats
	mov ah, 09h
	mov bx, _shockLimit
	cmp [byte ptr bx], 0
	jne continue
noShocksLeft:
	mov dx, offset shockLimitMSG
	int 21h
	mov ah, 07
	int 21h
	jmp playerTurn
continue:
	mov [byte ptr bx], 0
	mov bl, 01h
	mov bh, 0
	mov cx, 50
	int 10h
	mov ah, 09
	mov dx, offset afterShockMSG
	int 21h
	mov dx, offset linefeed
	int 21h
	mov dx, offset menuMsg3
	int 21h
	mov [isShocked], 1
	mov ah, 07
	int 21h
	jmp playerTurn
run:
	push ax
	call randomGenerate
	pop ax
	cmp ax, 6
	jb fail
success:
	call resetScreen
	call displayStats
	mov ah, 09
	mov dx, offset runSuccessMSG
	int 21h
	mov dx, offset linefeed
	int 21h
	mov dx, offset menuMsg3
	int 21h
	mov ah, 07
	int 21h
	jmp finish2
fail:
	call resetScreen
	call displayStats
	mov ah, 09
	mov dx, offset runFailMSG
	int 21h
	mov dx, offset linefeed
	int 21h
	mov dx, offset menuMsg3
	int 21h
	mov ah, 07
	int 21h
	mov bx, turn01
	xor [byte ptr bx], 1
	jmp enemyTurn
heal1:
	mov bx, _healthPotions1
	cmp [byte ptr bx], 0
	jne continue2
noPotionsLeft:
	call resetScreen
	call displayStats
	mov ah, 09
	mov dx, offset noPotionsLeftMSG
	int 21h
	mov dx, offset linefeed
	int 21h
	mov dx, offset menuMsg3
	int 21h
	mov ah, 07
	int 21h
	jmp playerTurn
continue2:
	push ax
	call randomGenerate
	pop si
	push si
	push offset playerMaxHealth
	push offset playerCurrentHealth
	call heal
	sub [byte ptr bx], 1
	jmp afterHeal
attack1:
	push ax
	call randomGenerate ;random number is in the stack segment
	pop si
	push si
	push offset enemyCurrentHealth
	call attack
	call resetScreen
	call displayStats
	xor bx, bx
	mov dl, 0
	mov dh, 0
	mov ah, 02h
	int 10h
	mov ah, 09h
	mov bl, 0Eh
	mov bh, 0
	mov cx, 20
	int 10h
	mov dx, offset playerDmgMSG
	int 21h
	mov dx, si
	add dl, '0'
	mov ah, 02h
	int 21h
	mov ah, 09h
	mov dx, offset DmgMSG
	int 21h
	jmp after
afterHeal:
	call resetScreen
	call displayStats
	xor bx, bx
	mov ah, 02h
	mov dl, 0
	mov dh, 0
	int 10h
;displays player's heal points;
	mov ah, 09h
	mov bl, 02h
	mov bh, 0
	mov cx, 20
	int 10h
	mov dx, offset playerHealMSG
	int 21h
	mov ah, 02h
	mov dx, si
	add dl, '0'
	int 21h
	mov ah, 09h
	mov dx, offset HPMSG
	int 21h
;displays player's heal points;
after:
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	mov dx, offset menuMsg3
	int 21h
	mov ah, 07h
	int 21h
	jmp check
enemyTurn:
	push ax
	call randomGenerate
	pop si
	push si
	push offset playerCurrentHealth
	call attack
	call resetScreen
	call displayStats
	xor bx, bx
	mov dl, 0
	mov dh, 0
	mov ah, 02h
	int 10h
;displays enemy's damage;
	mov ah, 09h
	mov bl, 04h
	mov bh, 0
	mov cx, 26
	int 10h
	
	mov ah, 09h
	mov dx, offset enemyDmgMSG
	int 21h
	mov dx, si
	add dl, '0'
	mov ah, 02h
	int 21h
	mov ah, 09h
	mov dx, offset DmgMSG
	int 21h
;displays enemy's damage;
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	mov ah, 09
	mov dx, offset menuMsg3
	int 21h
	mov ah, 07h
	int 21h
check:
	cmp [isShocked], 1
	je skipSwitchTurns
	mov bx, turn01
	xor [byte ptr bx], 1
skipSwitchTurns:
	mov [isShocked], 0
	mov bx, enemyHealth
	cmp [byte ptr bx], 0
	jg checkPlayerHealth
	je playerWon
	jmp finish2
checkPlayerHealth:
	mov bx, playerHealth
	cmp [byte ptr bx], 0
	jg jumpToTurn
	je enemyWon
playerWon:
;exp;
	push ax
	call randomGenerate
	pop si
	mov ax, si
	mov bx, currentEXP
	add [byte ptr bx], al
	mov bx, currentEXP
	mov al, [byte ptr bx]
	mov bx, maxEXP
	cmp al, [byte ptr bx]
	jae levelUp
	jmp noLevelUp 
levelUp:
	sub al, [byte ptr bx]
	mov [remainder], al
	inc [playerPokemonLevel]
	mov al, [byte ptr bx]
	mov bl, levelEXPMultiplier
	mul bl
	mov bx, maxEXP
	mov [byte ptr bx], al
	mov bx, currentEXP
	mov [byte ptr bx], 0
	mov al, [remainder]
	add [byte ptr bx], al
	mov bx, _playerMaxHealth
	mov al, [byte ptr bx]
	mov bx, playerHealth
	mov [byte ptr bx], al
	shl [byte ptr bx], 1
	xor [didPlayerLevelUp], 1
noLevelUp:
;exp
	xor ax, ax
	call resetScreen
	call displayStats
	mov ah, 02h
	mov dl, 0
	mov dh, 0
	int 10h
	mov ah, 09h
	mov bl, 0Ah
	mov bh, 0
	mov cx, 26
	int 10h
	mov dx, offset playerWinMSG
	int 21h
	mov dx, offset linefeed
	int 21h
	mov bl, 0Eh
	mov bh, 0
	mov cx, 18
	int 10h
	mov dx, offset EarnEXPMSG
	int 21h
	xor ax, ax
	mov ax, si
	mov dl, 10
	div dl
	mov dl, al
	add dl, '0' 
	mov ah, 02h
	int 21h
	xor ax, ax
	mov ax, si
	mov dl, 10
	div dl
	mov dl, ah
	add dl, '0'
	mov ah, 02h
	int 21h
	mov ah, 09
	mov dx, offset EXPMSG
	int 21h
	mov dx, offset linefeed
	int 21h
	mov dx, offset menuMsg3
	int 21h
	mov ah, 07
	int 21h
	call resetScreen
	call displayStats
	mov ah, 09
	mov bl, 0Eh
	mov bh, 0
	mov cx, 16
	int 10h
	mov dx, offset earnCoinMSG 
	int 21h
	push ax
	call randomGenerate
	pop ax
	mov si, ax
	mov dl, 10
	div dl
	mov dl, al
	add dl, '0' 
	mov ah, 02h
	int 21h
	xor ax, ax
	mov ax, si
	mov dl, 10
	div dl
	mov dl, ah
	add dl, '0'
	mov ah, 02h
	int 21h
	mov ax, si
	mov bx, _coins2
	add [byte ptr bx], al
	cmp [didPlayerLevelUp], 1
	je newLevel
	jmp noNewLevel
newLevel:
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	mov ah, 09h
	mov bl, 0Eh
	mov bh, 0
	mov cx, 15
	int 10h
	mov dx, offset levelUpMSG
	int 21h
	xor [didPlayerLevelUp], 1
noNewLevel:
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	mov dx, offset menuMsg3
	int 21h
	mov ah, 07h
	int 21h
	jmp finish2
enemyWon:
	call resetScreen
	call displayStats
	mov ah, 09
	mov dl, 0
	mov dh, 0
	mov ah, 02h
	int 10h
	mov ah, 09h
	mov bl, 04h
	mov bh, 0
	mov cx, 27
	int 10h
	mov dx, offset enemyWinMSG
	int 21h
	mov dx, offset linefeed
	int 21h
	mov dx, offset menuMsg3
	int 21h
	mov ah, 07h
	int 21h
	jmp finish2
finish2:
	pop di
	pop si
	pop cx
	pop bx
	pop ax
	pop dx
	pop bp
	ret 16
endp combat
;this procedure allows the user to buy health potions and heal their pokemon
;input: potions, coins, player's max health, player's current health
;output: updated potions, updated coins, updated health
proc pokestation
	push bp
	mov bp, sp
	push ax
	push bx
	push dx
	push cx
	push si
	_playerHealth2 equ [bp+4]
	_playerMaxHealth2 equ [bp+6]
	_coins equ [bp+8]
	_healthPotions equ [bp+10]
beginning2:
	call resetScreen
	mov ah, 02h
	mov dl, 26
	mov dh, 01
	int 10h
	mov ah, 09h
	mov dx, offset pokestationMSG1
	int 21h
	mov dx, offset linefeed
	int 21h
	mov ah, 02h
	mov dl, 29
	mov dh, 03
	int 10h
	mov ah, 09
	mov dx, offset pokestationHealMSG1
	int 21h
	mov bl, 0Eh
	mov bh, 0
	mov cx, 7
	int 10h
	mov dx, offset pokestationHealMSG2
	int 21h
	mov dx, offset linefeed
	int 21h
	mov ah, 02h
	mov dl, 29
	mov dh, 05
	int 10h
	mov ah, 09
	mov dx, offset pokestationBuyMSG1
	int 21h
	mov bl, 0Eh
	mov bh, 0
	mov cx, 7
	int 10h
	mov dx, offset pokestationBuyMSG2
	int 21h
	mov dx, offset linefeed
	int 21h
	mov ah, 02h
	mov dl, 29
	mov dh, 07
	int 10h
	mov ah, 09
	mov dx, offset exitMSG
	int 21h
	mov dx, offset linefeed
	int 21h
	mov ah, 02h
	mov dl, 28
	mov dh, 09
	int 10h
	mov ah, 09
	mov bl, 0Eh
	mov bh, 0
	mov cx, 14
	int 10h
	mov ah, 09
	mov dx, offset coinMSG
	int 21h
	mov bx, _coins
	xor ax, ax
	mov al, [byte ptr bx]
	mov dl, 10
	div dl
	mov dl, al
	add dl, '0' 
	mov ah, 02h
	int 21h
	xor ax, ax
	mov al, [byte ptr bx]
	mov dl, 10
	div dl
	mov dl, ah
	add dl, '0'
	mov ah, 02h
	int 21h
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	mov ah, 02h
	mov dl, 28
	mov dh, 10
	int 10h
	mov ah, 09
	mov bl, 02h
	mov bh, 0
	mov cx, 16
	int 10h
	mov ah, 09
	mov dx, offset potionAmountMSG
	int 21h
	mov bx, _healthPotions
	xor ax, ax
	mov al, [byte ptr bx]
	mov dl, 10
	div dl
	mov dl, al
	add dl, '0' 
	mov ah, 02h
	int 21h
	xor ax, ax
	mov al, [byte ptr bx]
	mov dl, 10
	div dl
	mov dl, ah
	add dl, '0'
	mov ah, 02h
	int 21h
	mov si, 1
	jmp pointHealPokemon
retry2:
	mov ah, 00h
	int 16h
	cmp ah, 050h
	je arrowDown3
	cmp ah, 048h
	je arrowup3
	cmp ah, 01Ch
	je isEnter3
	jne retry2
	jmp pointWalk
isEnter3:
	cmp si, 1
	je checkHealPokemon
	cmp si, 2
	je checkBuyPotions
	cmp si, 3
	je exit2
pointHealPokemon:
	;reset arrows
	mov ah, 02
	mov dl, 25
	mov dh, 05
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	mov ah, 02
	mov dl, 25
	mov dh, 07
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	;
	mov dl, 25
	mov dh, 03
	int 10h
	mov dl, '-'
	int 21h
	int 21h
	mov dl, '>'
	int 21h
	mov dl, 56
	mov dh, 03
	int 10h
	jmp retry2
pointBuy:
	;reset arrows
	mov ah, 02
	mov dl, 25
	mov dh, 03
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	mov ah, 02
	mov dl, 25
	mov dh, 07
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	;
	mov dl, 25
	mov dh, 05
	int 10h
	mov dl, '-'
	int 21h
	int 21h
	mov dl, '>'
	int 21h
	mov dl, 75
	mov dh, 05
	int 10h
	jmp retry2
pointExit2:
	;reset arrows
	mov ah, 02
	mov dl, 25
	mov dh, 03
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	mov ah, 02
	mov dl, 25
	mov dh, 05
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	;
	mov dl, 25
	mov dh, 07
	int 10h
	mov dl, '-'
	int 21h
	int 21h
	mov dl, '>'
	int 21h
	mov dl, 33
	mov dh, 07
	int 10h
	jmp retry2
arrowDown3:
	cmp si, 3
	je reset5
	inc si
	jmp checkPlace3
arrowUp3:
	cmp si, 1
	je reset6
	dec si
	jmp checkPlace3
reset5:
	mov si, 1
	jmp checkPlace3
reset6:
	mov si, 3
	jmp checkPlace3
checkPlace3:
	cmp si, 1
	je pointHealPokemon
	cmp si, 2
	je pointBuy
	cmp si, 3
	je pointExit2
checkHealPokemon:
	mov bx, _coins
	cmp [byte ptr bx], 5
	jae healPokemon
	call resetScreen
	mov ah, 09
	mov dx, offset insufficentCoinsMSG
	int 21h
	mov dx, offset linefeed
	int 21h
	mov dx, offset menuMsg3
	int 21h
	mov ah, 07
	int 21h
	jmp beginning2
healPokemon:
	sub [byte ptr bx], 5
	xor ax, ax
	mov bx, _playerMaxHealth2
	mov al, [byte ptr bx]
	mov bx, _playerHealth2
	mov [byte ptr bx], al
	call resetScreen
	mov ah, 09
	mov bl, 02h
	mov bh, 0
	mov cx, 29
	int 10h
	mov dx, offset pokemonHealMSG
	int 21h
	mov dx, offset linefeed
	int 21h
	mov dx, offset menuMsg3
	int 21h
	mov ah, 07
	int 21h
	jmp beginning2
checkBuyPotions:
	mov bx, _coins
	cmp [byte ptr bx], 3
	jae buyPotions
	call resetScreen
	mov ah, 09
	mov dx, offset insufficentCoinsMSG
	int 21h
	mov dx, offset linefeed
	int 21h
	mov dx, offset menuMsg3
	int 21h
	mov ah, 07
	int 21h
	jmp beginning2
buyPotions:
	sub [byte ptr bx], 3
	mov bx, _healthPotions
	inc [byte ptr bx]
	jmp beginning2
exit2:
	pop si
	pop cx
	pop dx
	pop bx
	pop ax
	pop bp
	ret 8
endp pokestation
;this procedure receives health and a random number and decreases the health with the random number
;input: randomNumber, health
;output: updated health
proc attack
	randomNumberVar equ [bp+6]
	health equ [bp+4]
	push bp
	mov bp, sp
	push ax
	push bx
	mov ax, randomNumberVar
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
	ret 4
endp attack
;this procedure receives health, maximum health and a random number and increases the health with the random number, and makes sure the health doesn't surpass the maximum health.
;input: randomNumber, maximum health, health
;output: updated health
proc heal
	randomNumberVar equ [bp+8]
	maxHealth equ [bp+6]
	health equ [bp+4]
	push bp
	mov bp, sp
	push bx
	push ax
	mov ax, randomNumberVar
	mov bx, health
	add [byte ptr bx], al
	mov bx, maxHealth
	mov al, [byte ptr bx]
	mov bx, health
	cmp [byte ptr bx], al
	jae healToMax
	jmp finish3
healToMax:
	mov [byte ptr bx], al
finish3:
	pop ax
	pop bx
	pop bp
	ret 6
endp heal
;this procedure allows the user to navigate between the different procedures, it is a main menu. also, if the player wants to enter combat, but he does not have sufficent health, it will not permit him to enter combat.
;input: player's current health
;output: none
proc menu
	push bp
	mov bp, sp
	push dx
	push ax
	push bx
	push si
	_playerHealth equ [bp+4]
beginning:
	call resetScreen
	mov ah, 02h
	mov dl, 21
	mov dh, 01
	int 10h
	mov ah, 09h
	mov dx, offset menuMsg1
	int 21h
	mov ah, 02h
	mov dl, 35
	mov dh, 03
	int 10h
	mov ah, 09
	mov dx, offset walkMSG
	int 21h
	mov ah, 02h
	mov dl, 35
	mov dh, 05
	int 10h
	mov ah, 09
	mov dx, offset pokestationMSG
	int 21h
	mov ah, 02h
	mov dl, 35
	mov dh, 07
	int 10h
	mov ah, 09
	mov dx, offset exitMSG
	int 21h
	; new line
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	mov si, 1
	jmp pointWalk
retry1:
	mov ah, 00h
	int 16h
	cmp ah, 050h
	je arrowDown2
	cmp ah, 048h
	je arrowup2
	cmp ah, 01Ch
	je isEnter2
	cmp al, 's'
	jne retry1
	jmp pointWalk
isEnter2:
	cmp si, 1
	je walk1
	cmp si, 2
	je pokestationLaunch
	cmp si, 3
	je exit
pointWalk:
	;reset arrows
	mov ah, 02
	mov dl, 31
	mov dh, 05
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	mov ah, 02
	mov dl, 31
	mov dh, 07
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	;
	mov dl, 31
	mov dh, 03
	int 10h
	mov dl, '-'
	int 21h
	int 21h
	mov dl, '>'
	int 21h
	mov dl, 39
	mov dh, 03
	int 10h
	jmp retry1
pointPokestation:
	;reset arrows
	mov ah, 02
	mov dl, 31
	mov dh, 03
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	mov ah, 02
	mov dl, 31
	mov dh, 07
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	;
	mov dl, 31
	mov dh, 05
	int 10h
	mov dl, '-'
	int 21h
	int 21h
	mov dl, '>'
	int 21h
	mov dl, 46
	mov dh, 05
	int 10h
	jmp retry1
pointExit:
	;reset arrows
	mov ah, 02
	mov dl, 31
	mov dh, 03
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	mov ah, 02
	mov dl, 31
	mov dh, 05
	int 10h
	mov dl, 20h
	int 21h
	int 21h
	int 21h
	;
	mov dl, 31
	mov dh, 07
	int 10h
	mov dl, '-'
	int 21h
	int 21h
	mov dl, '>'
	int 21h
	mov dl, 39
	mov dh, 07
	int 10h
	jmp retry1
arrowDown2:
	cmp si, 3
	je reset3
	inc si
	jmp checkPlace2
arrowUp2:
	cmp si, 1
	je reset4
	dec si
	jmp checkPlace2
reset3:
	mov si, 1
	jmp checkPlace2
reset4:
	mov si, 3
	jmp checkPlace2
checkPlace2:
	cmp si, 1
	je pointWalk
	cmp si, 2
	je pointPokestation
	cmp si, 3
	je pointExit
pokestationLaunch:
	push offset healthPotions
	push offset coins
	push offset playerMaxHealth
	push offset playerCurrentHealth
	call pokestation
	jmp beginning
walk1:
	mov bx, _playerHealth
	cmp [byte ptr bx], 0
	jne sufficentHealth
notEnoughHealth:
	call resetScreen
	mov ah, 09
	mov dx, offset pokemonInjuredMessage
	int 21h
	mov dx, offset linefeed
	int 21h
	mov dx, offset menuMsg3
	int 21h
	mov ah, 07
	int 21h
	jmp beginning
sufficentHealth:
	push offset coins
	push offset healthPotions
	push offset playerMaxHealth
	push offset shockLimit
	push offset playerMaxEXP
	push offset playerEXP
	push offset turn
	push offset playerCurrentHealth
	push offset enemyCurrentHealth
	call combat
	jmp beginning
	pop si
	pop bx
	pop ax
	pop dx
	pop bp
	ret 2
endp menu
;this procedure displays the player's stats and the enemy's stats.
;input: none
;output: battle UI
proc displayStats
	push dx
	push ax
	push cx
	push bx
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	xor bx, bx
	mov dl, 48
	mov dh, 4
	mov ah, 02h
	int 10h
	mov bl, 0Ch
	mov bh, 0
	mov cx, 32
	int 10h
	mov dx, offset lines02
	int 21h
	mov dl, 48
	mov dh, 5
	mov ah, 02h
	int 10h
	mov bl, 0Ch
	mov bh, 0
	mov cx, 1
	int 10h
	mov ah, 02
	mov dx, '|'
	int 21h
	mov dx, 20h
	int 21h
	mov ah, 09
	mov dx, offset enemyPokemonNameMsg
	mov ah, 09h
	int 21h
	cmp [enemyPokemonID], 1
	je displayRatatta
	cmp [enemyPokemonID], 2
	je displayMagikarp
	cmp [enemyPokemonID], 3
	je displayZubat
	cmp [enemyPokemonID], 4
	je displayRaticate
displayRatatta:
	mov dx, offset enemyPokemonName1
	int 21h
	jmp finish5
displayMagikarp:
	mov dx, offset enemyPokemonName2
	int 21h
	jmp finish5
displayZubat:
	mov dx, offset enemyPokemonName3
	int 21h
	jmp finish5
displayRaticate:
	mov dx, offset enemyPokemonName4
	int 21h
	jmp finish5
finish5:
	mov ah, 09
	mov dl, 48
	mov dh, 6
	mov ah, 02h
	int 10h
	mov bl, 0Ch
	mov bh, 0
	mov cx, 1
	int 10h
	mov ah, 02
	mov dx, '|'
	int 21h
	mov dx, 20h
	int 21h
	mov ah, 09
	mov dx, offset enemyPokemonLvlMsg
	mov ah, 9h
	int 21h
	xor ax, ax
	mov al, [enemyPokemonLevel]
	mov dl, 10
	div dl
	cmp al, 0
	je skip1
	mov dl, al
	add dl, '0' 
	mov ah, 02h
	int 21h
skip1:
	xor ax, ax
	mov al, [enemyPokemonLevel]
	mov dl, 10
	div dl
	cmp al, 0
	mov dl, ah
	add dl, '0'
	mov ah, 02h
	int 21h
	; new line
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	mov dl, 48
	mov dh, 7
	mov ah, 02h
	int 10h
	mov bl, 0Ch
	mov bh, 0
	mov cx, 1
	int 10h
	mov ah, 02
	mov dx, '|'
	int 21h
	mov dx, 20h
	int 21h
	mov ah, 09
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
	mov ah, 09h
	mov ah, 09
	mov dl, 48
	mov dh, 8
	mov ah, 02h
	int 10h
	mov ah, 09h
	mov bl, 0Ch
	mov bh, 0
	mov cx, 32
	int 10h
	mov dx, offset lines02
	int 21h
	xor bx, bx
	mov dl, 0
	mov dh, 17
	mov ah, 02h
	int 10h
	mov ah, 09h
	mov bl, 09h
	mov bh, 0
	mov cx, 31
	int 10h
	mov dx, offset lines
	int 21h
	mov dx, offset linefeed
	int 21h
	mov ah, 02
	mov dl, 20h
	int 21h
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
	mov ah, 02
	mov dl, 20h
	int 21h
	mov ah, 09
	mov dx, offset playerLevelMessage
	mov ah, 9h
	int 21h
	xor ax, ax
	mov al, [playerPokemonLevel]
	mov dl, 10
	div dl
	cmp al, 0
	je skip2
	mov dl, al
	add dl, '0' 
	mov ah, 02h
	int 21h
skip2:
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
	mov ah, 02
	mov dl, 20h
	int 21h
	mov ah, 09
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
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	mov ah, 02
	mov dl, 20h
	int 21h
	mov ah, 09
	mov dx, offset potionsLeftMSG
	int 21h
	xor ax, ax
	mov al, [healthPotions]
	mov dl, 10
	div dl
	cmp al, 0
	je skip5
	mov dl, al
	add dl, '0' 
	mov ah, 02h
	int 21h
skip5:
	xor ax, ax
	mov al, [healthPotions]
	mov dl, 10
	div dl
	mov dl, ah
	add dl, '0'
	mov ah, 02h
	int 21h
	mov ah, 09
	mov dx, offset linefeed
	int 21h
	mov ah, 02
	mov dl, 20h
	int 21h
	mov ah, 09
	mov dx, offset playerEXPMessage
	mov ah, 9h
	int 21h
	xor ax, ax
	mov al, [playerEXP]
	mov dl, 100
	div dl
	cmp al, 0
	je skip3
	mov dl, al
	add dl, '0' 
	mov ah, 02h
	int 21h
skip3:
	xor ax, ax
	mov al, [playerEXP]
	mov dl, 10
	div dl
	mov dl, al
	xor ax, ax
	mov al, dl
	mov dl, 10
	div dl
	mov dl, ah
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
	mov dl, 100
	div dl
	cmp al, 0
	je skip4
	mov dl, al
	add dl, '0' 
	mov ah, 02h
	int 21h
skip4:
	xor ax, ax
	mov al, [playerMaxEXP]
	mov dl, 10
	div dl
	mov dl, al
	xor ax, ax
	mov al, dl
	mov dl, 10
	div dl
	mov dl, ah
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
	mov ah, 09h
	mov dx, offset linefeed
	int 21h
	mov bl, 09h
	mov bh, 0
	mov cx, 31
	int 10h
	mov dx, offset lines
	int 21h
	xor bx, bx
	mov dl, 31
	mov dh, 23
	mov ah, 02h
	int 10h
	mov bl, 09h
	mov bh, 0
	mov cx, 1
	int 10h
	mov ah, 02h
	mov dl, '|'
	int 21h
	mov ah, 02h
	mov dl, 31
	mov dh, 22
	int 10h
	mov ah, 09h
	mov bl, 09h
	mov bh, 0
	mov cx, 1
	int 10h
	mov ah, 02h
	mov dl, '|'
	int 21h
	mov ah, 09
	mov dl, 31
	mov dh, 21
	mov ah, 02h
	int 10h
	mov bl, 09h
	mov bh, 0
	mov cx, 1
	mov al, '|'
	int 10h
	mov dl, 31
	mov dh, 20
	mov ah, 02h
	int 10h
	mov bl, 09h
	mov bh, 0
	mov cx, 1
	mov al, '|'
	int 10h
	mov ah, 02h
	mov dl, 31
	mov dh, 19
	int 10h
	mov ah,9
	mov bl, 09h
	mov bh, 0
	mov cx, 1
	mov al, '|'
	int 10h
	mov dl, 31
	mov dh, 18
	mov ah, 02h
	int 10h
	mov bl, 09h
	mov bh, 0
	mov cx, 1
	mov al, '|'
	int 10h
	mov dl, 31
	mov dh, 17
	mov ah, 02h
	int 10h
	mov bl, 09h
	mov bh, 0
	mov cx, 1
	mov al, '|'
	int 10h
	mov ah, 02h
	mov dl, 00
	mov dh, 00
	int 10h
	pop bx
	pop cx
	pop ax
	pop dx
	ret
endp displayStats
;this procedure resets the screen
;input: none
;output: cleared screen
proc resetScreen
	push ax
	mov ax, 3
	int 10h
	pop ax
	ret
endp resetScreen
;this procedure generates the enemy and player's stats at the start of every game.
;input: shock usage limit, pokemon id, turn, player's maximum health, player's current health, enemy's current health, enemy's maximum health, enemy's level, player's level
;output: stats
proc generateStats
	pokemonLevel equ [bp+4]
	enemyLevel equ [bp+6]
	maxEnemyHealth equ [bp+8]
	enemyCurrHealth equ [bp+10]
	playerCurrHealth equ [bp+12]
	maxPlayerHealth equ [bp+14]
	turn02 equ [bp+16]
	pokemonID equ [bp+18]
	_shockLimit2 equ [bp+20] 
	;
	push bp
	mov bp, sp
	push ax
	push bx
	;generate enemy pokemon ID
	mov bx, _shockLimit2
	mov [byte ptr bx], 1
	mov bx, pokemonID
tryAgain:
	push ax
	call randomGenerate
	pop ax
	cmp ax, 4
	ja tryAgain
	cmp ax, 0
	je tryAgain
	mov [byte ptr bx], al
	xor ax, ax
	mov bx, pokemonLevel
	mov al, [byte ptr bx]
	mov bx, enemyLevel
	mov [byte ptr bx], al
	mov ah, levelHealthMultiplier
	mul ah
	mov bx, maxEnemyHealth
	mov [byte ptr bx], al
	mov bx, enemyCurrHealth
	mov [byte ptr bx], al
	mov bx, maxPlayerHealth
	mov [byte ptr bx], al
	mov al, [byte ptr bx]
	mov bx, playerCurrHealth
	mov bx, turn02
	mov [byte ptr bx], 0
	pop bx
	pop ax
	pop bp
	ret 18
endp generateStats
;opens a file
;input none 
;output: file's handle
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
;reads header
;input: none 
;output: none
proc ReadHeader
	; Read BMP file header, 54 bytes
	mov ah,3fh
	mov bx, [filehandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	ret
endp ReadHeader
;reads pallette
;input: none 
;output: none 
proc ReadPalette
	; Read BMP file color palette, 256 colors * 4 bytes (400h)
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	ret
endp ReadPalette
;inverts BGR to RGB
;input none 
;output: inverted colors
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
;prints the picture from the .bmp file
;input: none 
;output: printed picture
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
	;push offset playerMaxEXP
	;push offset playerEXP
	;push offset turn
	;push offset playerCurrentHealth
	;push offset enemyCurrentHealth
	;call combat
	xor bx, bx
	push offset playerCurrentHealth
	call menu
exit:
	call resetScreen
	mov ax, 4c00h
	int 21h
END start