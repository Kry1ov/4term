.model      small
.stack      100h

.data
    startMessage      db "CONSOLE PARAMETERS: ", '$'
    iterationsMsg     db "ITERATIONS COUNT: ", '$'
    fileMsg           db "FILENAME: ", '$'
    applicationError  db "APPLICATION START ERROR!", '$'
    stringMsg         db "STRING NUMBER: ", '$'
    negativeExit      db "ENTER CORRECT NUMBER!", '$'
    allocatingError   db "ALLOCATING MEMORY ERROR!", '$'
    startupError      db "STARTUP ERROR!", '$'
    badFileMessage    db "CANNOT OPEN FILE", 0dh, 0ah, '$'
    badArguments      db "BAD ARGUMENTS ERROR!", 0dh, 0ah, '$'
    fileError         db "ERROR OPENING FILE!", '$'
    badFileName       db "BAD FILE NAME!", '$'

    partSize          equ 256
    wasPreviousLetter dw 0
    realPartSize      dw 256
    descriptor        dw 0
    pointerPosition   dd 0
    path              db 256 dup('$')
    tempVariable      dw 0
    isEndl            db 0
    spacePos          dw 0
    base              dw 10
    iterations        dw 0
    stringNumber      dw 0
    parsingStep       dw 1
    endl              db 13, 10, '$'
    endlCounter       dw 0
    
    tempString        db 256 dup('$')
    fileName          db 256 dup(0)
    dtaBuffer         db 128 dup(0)
    applicationName   db 256 dup(0)
    part              db partSize dup('$')
    
    ;������ ����� ���������� ��� epb (��������� � ��������� ���������)
    EPB         dw 0                     ;������� ���������
                dw offset commandline, 0  ;����� ��������� ������
                dw 005Ch, 0, 006Ch, 0    ;����� FCB ���������      
    commandline db 125                   ;����� ���
                db " /?"
    commandtext db 122 dup (?)

    dsize=$-startMessage          ;������ �������� ������ 
.code

;����� ���������� �������
printString proc  
    push    bp
    mov     bp, sp   
    pusha                                                     
    mov     dx, [ss:bp+4+0] ;��������� � �������� ����� ��� �������� ������� ���������    
    mov     ax, 0900h   ;��� ������ ������������
    int     21h 
    mov     dx, offset endl  ;�������� �� ����� ������
    mov     ax, 0900h
    int     21h  
    popa
    pop     bp      
    ret 
endp

;output string
puts proc
    mov     ah, 9
    int     21h
    ret
endp

;�������� �� ������������ ����� �����
badFileNameCall proc
    lea     dx, badFileName
    call    puts
    call    exit
endp

exit proc
    mov     ax, 4c00h
    int     21h
endp

;�������� �� ���� � �������� [1..255]
badRange:
    lea     dx, negativeExit  ;����� ������
    call    puts
    call    exit
ret

;������ � �����
toInteger proc
    pusha        
    xor     di, di
    lea     di, path ;������ ��� ��������
    xor     bx, bx     
    xor     ax, ax   
    xor     cx, cx
    xor     dx, dx
    mov     bx, spacePos  ;������ ������� �������
    
    skipSpacesInteger:
        cmp     [di + bx], byte ptr ' ' ;���������� ������
        jne     unskippingInteger
        inc     bx
        jmp     skipSpacesInteger
    
    unskippingInteger:
        cmp     [di + bx], byte ptr '-' ;����� ������,���� ������������� �����
        jne     atoiLoop
        jmp     atoiError

    atoiLoop: 
    ;�������        
        cmp     [di + bx], byte ptr '0'     ;���� ��� < 0
        jb      atoiError  
        cmp     [di + bx], byte ptr '9'   ;���� ��� > 9
        ja      atoiError                     
        mul     base            ;mul 10
        mov     dl, [di + bx] 
        jo      atoiError 
        sub     ax, '0'   ;�������� 30h,����� �������� �����
        jo      atoiError  ;��������� ������������
        add     ax, dx    ;��������� � ������ ������
        inc     bx 
        cmp     [di + bx], byte ptr ' '  ;���� �� ����� - �����������
        jne     atoiLoop  
        jmp     atoiEnd 
    
    atoiError:
        jmp     badRange

    atoiEnd: 
        mov     tempVariable, ax  ;������ ���������� �����
        mov     spacePos, bx    ;� ������� ������� �������
        inc     parsingStep         ;����������� ���-�� �������� ��������
        cmp     tempVariable, 255    ;��������� ���� ����� �� ������ ����������
        jg      badRange
        cmp     tempVariable, 0
        je      badRange
        popa
        ret
endp

;����� � ������
toString proc
    pusha
    xor     di, di
    lea     di, tempString
    mov     ax, tempVariable
    xor     bx, bx
    mov     bx, di
    xor     cx, cx
    mov     cx, 256
    setZeroString: ;�������� ������
        mov     [di], byte ptr '$'
        loop    setZeroString
        lea     di, tempString
    itoaLoop:
        xor     dx, dx
        div     base  
        add     dl, '0' ;+30h ��� ��������� ������ �� �����
        mov     [di], dl
        inc     di                   
        cmp     ax, 0    ;�������� �� �����
        ja      itoaLoop            ;����������
        dec     di
        xor     si, si
        mov     si, bx 
        popa
        ret
endp

;������ ������� ���������
applicationStartError:
    lea     dx, applicationError
    call    puts
    call    exit
ret

;��������� ������
;allocateMemory proc
   ; push    ax
;    push    bx 
;    mov     bx, ((csize/16)+1)+256/16+((dsize/16)+1)+256/16 ;psp stack data segment stack segment
;    mov     ah, 4Ah   ;4Ah ��������� ������ ����� ������
;    int     21h 
;    jc      allocateMemoryError
;    jmp     allocateMemoryEnd  
;mov sp,csize + 100h+200h
;mov ah,4ah
;stack_shift = csize + 100h + 200h
;mov bx,stack_shift shr 4 + 1
;int 21h
;
;mov ax,cs
;mov word ptr EPB+4,ax
;mov word ptr EPB+8,ax
;mov word ptr EPB+0Ch,ax  
;
;    allocateMemoryError:  ;������ ��� ���������
;        lea     dx, allocatingError
;        call    puts
;        call    exit    
;    allocateMemoryEnd:
;        pop     bx
;        pop     ax
;        ret
;endp
;
;���������� ��������
getIterations proc
    pusha
    xor     ax, ax
    call    toInteger   ;�������� ���� ��������� �����
    mov     ax, tempVariable
    mov     iterations, ax    ;� ������ ��� ��� ���������� ��������
    popa
    ret
endp

;��������� � ��������� ����������
loadAndRun proc
    mov     ax, 4B00h      ;4Bh ��������� � ��������� ���������
    lea     dx, applicationName  ;����� � ������ ������ ���������
    lea     bx, EPB  ;����� ����� epb  
    int     21h
    jb      applicationStartError    ;�������� ������ �������
    ret
endp

;������ ������ �����
fileErrorCall:
    lea     dx, fileError
    call    puts
    call    exit
ret

;��������� ����� �����
getFilename proc
    pusha
    lea     di, path ; ������ � ������� 
    xor     bx, bx     
    xor     ax, ax   
    mov     bx, spacePos
    skipSpacesString:
        cmp     [di + bx], byte ptr ' ' ;���������� ������� � �����
        jne     unskippingString
        inc     bx
        jmp     skipSpacesString
    unskippingString:
        lea si, fileName ;������ � ������ �����
    copyFilename:
        xor     ax, ax
        mov     al, [di + bx] 
        mov     [si], al   ;����������� ������������ ��� ����� �� path � fileName
        inc     bx
        inc     si
        cmp     [di + bx], byte ptr '$'
        jne     copyFilename
        mov     spacePos, bx
        popa
        ret
endp

;��������� ������ ������
getStringNumber proc
    pusha
    xor     ax, ax
    call    toInteger
    mov     ax, tempVariable ;��� ����� �������� ����� == ������ ������
    mov     stringNumber, ax ;����� ������
    popa
    ret
endp

;��������� ����� ������������ ����� (������ �� �����)
getApplicationName proc
    pusha
    xor     ax, ax
    mov     dx, offset fileName    ;��� ����� ��� ������
    mov     ah, 3Dh        ;������� ���� 3Dh
    mov     al, 00h         ;��� ������
    int     21h
    mov     descriptor, ax
    mov     bx, ax
    jnc     readFilePart  ;CF = 0 - ��� ������ ��� ��������
    jmp     fileErrorCall;   ����� ������� ������
    readFilePart:    
        mov     ah, 42h     ;��������� ������\������ �����
        mov     cx, word ptr [offset pointerPosition]  ;  ������� ���� ��������
        mov     dx, word ptr [offset pointerPosition + 2] ; ������� ���� ��������  (����������� �� ������ �����)
        mov     al, 0     ;������ �����
        mov     bx, descriptor   ;������������� �����
        int     21h
        mov     cx, partSize ;����� ���� ��� ����������
        lea     dx, part   ;����� ������ ��� ������ ������
        mov     ah, 3Fh     ;������ ����� � ������������
        mov     bx, descriptor
        int     21h
        mov     realPartSize, ax ;�������� ����� �������� ���� 
        call    searchApplicationName
        call    memset
        cmp     realPartSize, partSize
        jb      closeFile
        mov     bx, stringNumber 
        cmp     endlCounter, bx
        je      closeFile  ;��������� ����
        ;���� ��� - ���� ������
        mov     cx, word ptr [offset pointerPosition]
        mov     dx, word ptr [offset pointerPosition + 2]
        add     dx, ax
        adc     cx, 0
        mov     word ptr [offset pointerPosition], cx
        mov     word ptr [offset pointerPosition + 2], dx
        jmp     readFilePart
    closeFile:
    exitFromFile:
        mov     ah, 3Eh        ;������� ����
        mov     bx, descriptor
        int     21h
        popa
        ret
endp

;������ ����� � ����� (������ �� ������)
searchApplicationName proc
    pusha
    xor     si, si
    partParsing:
        call    checkEndl  ;�������� �� ����
        mov     ax, stringNumber ;����� ����� ������
        cmp     endlCounter, ax ;���� ������ ������
        je      parseApplicationName   ;������������ ��� ���������
        cmp     isEndl, 0
        je      increment
        inc     endlCounter
        jmp     partParsingCycle
        increment:
            inc     si
        partParsingCycle:
            mov     isEndl, 0
            cmp     si, realPartSize
            jb      partParsing        ;if lower
            popa
            ret
    parseApplicationName:
        cmp     isEndl, 1
        jne     parseStart   
        call    badFileNameCall
        parseStart:
            lea     di, applicationName ;�������� ��� �����
            copyApplicationName: ;�������� ���� � ��  
            ;� ���������� ���������� � ����� ���� ���
                xor     ax, ax
                mov     al, [part + si]
                mov     [di], al
                inc     si
                inc     di   
                ;�������� �� ����� ������
                cmp     [part + si], 0dh
                je      exitFromParsing
                cmp     [part + si], 0ah
                je      exitFromParsing
                cmp     si, realPartSize
                je      exitFromParsing
                jmp     copyApplicationName    
    exitFromParsing:
        popa
        ret
endp

;�������� �� ����� ������
checkEndl proc
    mov     al, [part + si]
    xor     ah,ah
    cmp     al, 0dh
    je      checkNextSymbol
    cmp     al, 0ah
    jne     exitFromEndlCheck
    inc     si
    call    setIsEndl ;���� ����� ������ - ������������� ���� ����� ������
    exitFromEndlCheck:
    ret
endp

;�������� ����� �������
checkNextSymbol:
    call    setIsEndl
    mov     bl, [part + si + 1]
    xor     bh,bh
    cmp     bl, 0ah  ;���� newline - ���������
    jne     exitFromCheck
    inc     si
    exitFromCheck:
        inc     si
ret

;���� ����� ������
setIsEndl proc
    mov     isEndl, 1
    ret
endp

;memset
memset proc
    pusha
    xor     si, si
    lea     si, part
    mov     cx, partSize
    setEndCycle:    ;"���������"
        mov     byte ptr [si], '$'
        inc     si
        loop    setEndCycle
        popa
        ret
endp

;������������ ��������� ������
badArgumentsCall:
    lea     dx, badArguments  ;����� ������
    call    puts
    call    exit
ret

;start
start:
   ; call    allocateMemory    ;�������� ������
    mov     ax, @data        
    mov     ds, ax
    mov     bl, es:[80h]     ;������ ���
    add     bx, 80h             
    mov     si, 82h           ;��������� ��������� ������
    mov     di, offset path   ;�������� �������� ������
    cmp     si, bx
    ja      badArgumentsCall 
    getPath:
        mov     al, es:[si]
        mov     [di], al
        cmp     BYTE PTR es:[si], byte ptr ' ' ;�������� �� ������ ������ � ������
        jne     getNextCharacter  ;�������� ����� ���� ������
        cmp     wasPreviousLetter, 0
        je      skipCurrentSymbol   ;����� ����
        mov     wasPreviousLetter, 0
        cmp     parsingStep, 1
        jne     stepTwo
        call    getIterations ;������� ��� ��������� ���������
        jmp     skipCurrentSymbol
        stepTwo:
            call    getStringNumber   ;�������� ����� ������
            jmp     skipCurrentSymbol   ;��������� � �����
        stepThree:
            call    getFilename   ;�������� ��� �����
            jmp     main
        getNextCharacter:
            mov     wasPreviousLetter, 1
        skipCurrentSymbol:
            inc     di
            inc     si
            cmp     si, bx
            jg      stepThree    ;���� ������
    jbe getPath      ;���� ������ ��� �����
    
    main:
        lea     dx, startMessage ;����� ���������
        call    puts
        lea     ax, path  ;������ �����
        push    ax
        call    printString  
        pop     ax
        dec     stringNumber
        call    getApplicationName ;�������� ��� ���������
        xor cx, cx
        mov cx, iterations ;������� = ���������� �������� �����
        startApps:        
        ;����������� ��� ������ ����� ����� ��������� � �����
            mov sp,csize + 100h+200h ;����������� ����� �� 200h ����� ����� �����
            mov ah,4ah    ;��������� ������ �� ��������
            stack_shift = csize + 100h + 200h
            mov bx,stack_shift shr 4 + 1  ;������ � ���������� + 1
            int 21h        ;�������� ������ ���������� ����� ������
            ;���������� ����� epb
            mov ax,cs
            mov word ptr EPB+4,ax  ;������� ��������� ������
            mov word ptr EPB+8,ax   ;������� �������  fcb
            mov word ptr EPB+0Ch,ax ;������� ������� fcb
            call    loadAndRun  ;��������� � ������� ������
            loop    startApps
            call exit
endp

csize = $ - start  ;������ �������� ����

end start      



