TITLE Example of ASM                (asmExample.ASM)

; This program locates the cursor and displays the
; system time. It uses two Win32 API structures.
; Last update: 6/30/2005
main EQU start
INCLUDE Irvine32.inc
;chcp 437 
;D:\windbg\asmExample.exe
; Redefine external symbols for convenience
; Redifinition is necessary for using stdcall in .model directive 
; using "start" is because for linking to WinDbg.  added by Huang
 
main	EQU start@0
 
.data
consoleHandle    DWORD ?

;地板
Ground BYTE 80 dup('-')

;站著的人物
SHead    BYTE ' ',0DAh, 2 dup(0C4h), 0BFh,' '
SBody   BYTE ' ',0B3h,2 dup('.'), 0B3h,' '
SHand   BYTE '/',0B3h,'_','_', 0B3h,'\'
SBottom BYTE ' ',0C0h,2 dup(0C4h),0D9h,' '
SFoot   BYTE  2 dup(' '),2 dup(0B3h),2 dup(' ')

;趴著的人物
DSpace BYTE 6 dup(' ')
DTop	BYTE '_',0DAh,3 dup(0C4h),0BFh
DBottom   BYTE '_',0C0h,3 dup(0C4h),0D9h

;障礙物
boxTop    BYTE 0DAh, 0C4h, 0BFh,' ',' '
boxBody   BYTE 0B3h, ' ', 0B3h,' ',' '
boxBottom BYTE 0C0h, 0C4h,0D9h,' ',' '



msecond DWORD 1000
nowtime DWORD ?
pretime DWORD ?
count DWORD ?
cellsWritten DWORD ?
attributes0 WORD 7 DUP(0Ch)
attributesGround WORD 80 dup(0Ch)

;各基礎座標
ranX WORD ?
xyInit COORD <0,7> ; 起始座標
xyInit2 COORD <0,15>
xyBound COORD <80,25> ; 一個頁面最大的邊界
xyPos COORD  <0,0> ; 現在的游標位置
xyPos2 COORD  <0,0>
xyBoxInit COORD <80,7>
xyBoxInit2 COORD <100,15>
xyBoxPos COORD <0,0> ;障礙物起始座標
xyBoxPos2 COORD <0,0> 
GroundPos COORD <0,12>
GroundPos2 COORD <0,20>
Sizeofbox SMALL_RECT <0,0,80,25>
.code
main PROC

; Get the Console standard output handle:
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov consoleHandle,eax
;初始化障礙物的起始位置
	mov ax,70d
	call RandomRange
	add ax,50d
	mov xyBoxPos.x,ax        ;將座標x的起始位置放入變數中
	mov ax,xyBoxInit.y
	mov xyBoxPos.y,ax		   ;將座標y的起始位置放入變數中
;初始化第二個障礙物的起始位置
	mov ax,70
	call RandomRange
	add ax,50
	mov xyBoxPos2.x,ax       ;將座標x的起始位置放入變數中
	mov ax,xyBoxInit2.y
	mov xyBoxPos2.y,ax		   ;將座標y的起始位置放入變數中
;畫地板

	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				;output handle
      ADDR attributesGround, 			;write attribures
      80,							;number of cells
      GroundPos,						;first cell coordinates
      ADDR cellsWritten				;number of cells written
	  
	  INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			    ; console output handle
       ADDR Ground,  				; pointer to the top box line
       80,   					; size of box line
       GroundPos,   				; coordinates of first char
       ADDR count    				; output count
	
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				;output handle
      ADDR attributesGround, 			;write attribures
      80,							;number of cells
      GroundPos2,						;first cell coordinates
      ADDR cellsWritten				;number of cells written
	  
	  INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			    ; console output handle
       ADDR Ground,  				; pointer to the top box line
       80,   					; size of box line
       GroundPos2,   				; coordinates of first char
       ADDR count    				; output count
	   jmp Start
;畫地板

		
Start:
	.IF ax != 5000h  ;Down        ;如果ax值為下鍵
		jmp Stand
	.ENDIF
	.IF ax == 5000h  ;Down        ;如果ax值為下鍵
		jmp Down
	.ENDIF
	.IF ax == 011Bh ;ESC		;如果為esc鍵，則結束程式
		jmp END_FUNC
	.ENDIF
moving:
		
	mov ecx,1000010h
	L1:
		imul ebx
	Loop L1
	
	dec xyBoxPos.x
	dec xyBoxPos2.x
	.IF xyBoxPos.x==0
		mov ax,xyBoxInit.x
		mov xyBoxPos.x,ax
		;初始化障礙物的起始位置
		mov ax,70
		call RandomRange
		add ax,50
		mov ranX,ax
		mov xyBoxPos.x,ax        ;將座標x的起始位置放入變數中
		mov ax,xyBoxInit.y
		mov xyBoxPos.y,ax		   ;將座標y的起始位置放入變數中
		jmp Stand1
	.ENDIF
	.IF xyBoxPos2.x==0
		mov ax,xyBoxInit2.x
		mov xyBoxPos2.x,ax
		;初始化第二個障礙物的起始位置
		mov ax,70
		call RandomRange
		add ax,50
		mov xyBoxPos2.x,ax       ;將座標x的起始位置放入變數中
		mov ax,xyBoxInit2.y
		mov xyBoxPos2.y,ax		   ;將座標y的起始位置放入變數中
		jmp Stand2
	.ENDIF
	.IF xyBoxPos2.x==-1
		mov ax,xyBoxInit2.x
		mov xyBoxPos2.x,ax
		;初始化第二個障礙物的起始位置
		mov ax,70
		call RandomRange
		add ax,50
		mov xyBoxPos2.x,ax       ;將座標x的起始位置放入變數中
		mov ax,xyBoxInit2.y
		mov xyBoxPos2.y,ax		   ;將座標y的起始位置放入變數中
		jmp Stand2
	.ENDIF
	jmp DrawBox
	jmp Start


	
	
;站著的人物
Stand:
	mov ax,xyInit.x
	mov xyPos.x,ax         ;將座標x的起始位置放入變數中
	mov ax,xyInit.y
	mov xyPos.y,ax		   ;將座標y的起始位置放入變數中
	
	;畫頭
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				;output handle
      ADDR attributes0, 			;write attribures
      6,							;number of cells
      xyPos,						;first cell coordinates
      ADDR cellsWritten				;number of cells written
	  
	  INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			    ; console output handle
       ADDR SHead,  				; pointer to the top box line
       6,   					; size of box line
       xyPos,   				; coordinates of first char
       ADDR count    				; output count
	  
	  inc xyPos.y
	
	;畫身體+眼睛
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR SBody,  				
       6,   				
       xyPos,   			
       ADDR count
	
	inc xyPos.y
	
	;畫手
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR SHand,  				
       6,   				
       xyPos,   			
       ADDR count
	
	inc xyPos.y
	;畫下半身
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR SBottom,  				
       6,   				
       xyPos,   			
       ADDR count
	inc xyPos.y
	
	;畫腳
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR SFoot,  				
       6,   				
       xyPos,   			
       ADDR count
	;畫第二個人
	mov ax,xyInit2.x
	mov xyPos2.x,ax         ;將座標x的起始位置放入變數中
	mov ax,xyInit2.y
	mov xyPos2.y,ax		   ;將座標y的起始位置放入變數中
	
	;畫頭
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				;output handle
      ADDR attributes0, 			;write attribures
      6,							;number of cells
      xyPos2,						;first cell coordinates
      ADDR cellsWritten				;number of cells written
	  
	  INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			    ; console output handle
       ADDR SHead,  				; pointer to the top box line
       6,   					; size of box line
       xyPos2,   				; coordinates of first char
       ADDR count    				; output count
	  
	  inc xyPos2.y
	
	;畫身體+眼睛
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos2,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR SBody,  				
       6,   				
       xyPos2,   			
       ADDR count
	
	inc xyPos2.y
	
	;畫手
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos2,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR SHand,  				
       6,   				
       xyPos2,   			
       ADDR count
	
	inc xyPos2.y
	;畫下半身
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos2,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR SBottom,  				
       6,   				
       xyPos2,   			
       ADDR count
	inc xyPos2.y
	
	;畫腳
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos2,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR SFoot,  				
       6,   				
       xyPos2,   			
       ADDR count
	
	
	jmp moving
Stand1:
	mov ax,xyInit.x
	mov xyPos.x,ax         ;將座標x的起始位置放入變數中
	mov ax,xyInit.y
	mov xyPos.y,ax		   ;將座標y的起始位置放入變數中
	
	;畫頭
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				;output handle
      ADDR attributes0, 			;write attribures
      6,							;number of cells
      xyPos,						;first cell coordinates
      ADDR cellsWritten				;number of cells written
	  
	  INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			    ; console output handle
       ADDR SHead,  				; pointer to the top box line
       6,   					; size of box line
       xyPos,   				; coordinates of first char
       ADDR count    				; output count
	  
	  inc xyPos.y
	
	;畫身體+眼睛
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR SBody,  				
       6,   				
       xyPos,   			
       ADDR count
	
	inc xyPos.y
	
	;畫手
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR SHand,  				
       6,   				
       xyPos,   			
       ADDR count
	
	inc xyPos.y
	;畫下半身
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR SBottom,  				
       6,   				
       xyPos,   			
       ADDR count
	inc xyPos.y
	
	;畫腳
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR SFoot,  				
       6,   				
       xyPos,   			
       ADDR count
	jmp DrawBox
Stand2:
	mov ax,xyInit2.x
	mov xyPos2.x,ax         ;將座標x的起始位置放入變數中
	mov ax,xyInit2.y
	mov xyPos2.y,ax		   ;將座標y的起始位置放入變數中
	
	;畫頭
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				;output handle
      ADDR attributes0, 			;write attribures
      6,							;number of cells
      xyPos2,						;first cell coordinates
      ADDR cellsWritten				;number of cells written
	  
	  INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			    ; console output handle
       ADDR SHead,  				; pointer to the top box line
       6,   					; size of box line
       xyPos2,   				; coordinates of first char
       ADDR count    				; output count
	  
	  inc xyPos2.y
	
	;畫身體+眼睛
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos2,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR SBody,  				
       6,   				
       xyPos2,   			
       ADDR count
	
	inc xyPos2.y
	
	;畫手
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos2,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR SHand,  				
       6,   				
       xyPos2,   			
       ADDR count
	
	inc xyPos2.y
	;畫下半身
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos2,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR SBottom,  				
       6,   				
       xyPos2,   			
       ADDR count
	inc xyPos2.y
	
	;畫腳
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos2,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR SFoot,  				
       6,   				
       xyPos2,   			
       ADDR count
	jmp DrawBox
	   
;趴下的人物
Down:

	mov ax,xyInit.x
	mov xyPos.x,ax         ;將座標x的起始位置放入變數中
	mov ax,xyInit.y
	mov xyPos.y,ax		   ;將座標y的起始位置放入變數中
	
	;畫三行空白，覆蓋原本的圖案
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
      consoleHandle,  			
      ADDR DSpace,  				
      6,   				
      xyPos,   			
      ADDR count
	
	inc xyPos.y
	
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
      consoleHandle,  			
      ADDR DSpace,  				
      6,   				
      xyPos,   			
      ADDR count
	inc xyPos.y
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
      consoleHandle,  			
      ADDR DSpace,  				
      6,   				
      xyPos,   			
      ADDR count
	inc xyPos.y
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
      consoleHandle,  			
      ADDR DTop,  				
      6,   				
      xyPos,   			
      ADDR count
	inc xyPos.y  
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      6,						
      xyPos,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
      consoleHandle,  			
      ADDR DBottom,  				
      6,   				
      xyPos,   			
      ADDR count
	jmp moving
	
;障礙物
DrawBox:
	

	;障礙物上半部分
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      4,						
      xyBoxPos,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR boxTop,  				
       4,   				
       xyBoxPos,   			
       ADDR count
	
	inc xyBoxPos.y
	
	;障礙物中間
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      4,						
      xyBoxPos,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR boxBody,  				
       4,   				
       xyBoxPos,   			
       ADDR count
	   
	inc xyBoxPos.y
	;障礙物下面
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      4,						
      xyBoxPos,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR boxBottom,  				
       4,   				
       xyBoxPos,   			
       ADDR count
	
	sub xyBoxPos.y,2
;畫第二個障礙物
	;障礙物上半部分
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      4,						
      xyBoxPos2,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR boxTop,  				
       4,   				
       xyBoxPos2,   			
       ADDR count
	
	inc xyBoxPos2.y
	
	;障礙物中間
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      4,						
      xyBoxPos2,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR boxBody,  				
       4,   				
       xyBoxPos2,   			
       ADDR count
	   
	inc xyBoxPos2.y
	;障礙物下面
	INVOKE WriteConsoleOutputAttribute,
      consoleHandle,  				
      ADDR attributes0, 		
      4,						
      xyBoxPos2,						
      ADDR cellsWritten				

	INVOKE WriteConsoleOutputCharacter,
       consoleHandle,  			
       ADDR boxBottom,  				
       4,   				
       xyBoxPos2,   			
       ADDR count
	
	sub xyBoxPos2.y,2
	
	jmp moving
END_FUNC:
	exit
main ENDP

END main


