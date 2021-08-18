.model small 
.stack 100h
.data
    numberTen             dw  000Ah 
    sizeOfNumber          equ 2
    maxMassiveLength      equ 08h ;8
    numberStringLength    equ 20 
    
    i                     dw ? ;��� ������� �� �������
    j                     dw ? 
    rows                  dw ?
    cols                  dw ?
    total                 dw ? 
    one                   dw 1
    mulArray              dw maxMassiveLength dup ('$') 
    resultArray           dw maxMassiveLength dup ('$')   ;�������� ���������� ���������
    array                 dw maxMassiveLength*maxMassiveLength dup('$') ;�������                                     
    numberString          db numberStringLength dup('$')
    inputLimitsString     db "minimal value = -32768, maximal = 32767$" 
    invalidLengthString   db "input error. 1 <= length <= 8$"
    inputRowsString       db "enter the rows size $"
    inputColsString       db "enter the columns size $" 
    inputArrayString      db "fill in the matrix $" 
    invalidInputString    db "input error $" 
    tryAgainString        db "try again: $" 
    inputInviteString     db "enter the number: $"
    newLine               db 13, 10,'$'
    space                 db " $"
    overflow              db "Overflow $"
.code 
 
;���� �����  
inputNumbers proc
    call printNewLine    ;��������� �� ����� ������
    lea dx, inputInviteString  ;������� ����������� �� ����
    call outputString  
    
repeatElementInput:
    lea dx, numberString  ;�������� ����� � ������
    call inputString          
    lea si, numberString[2]
    call parseString     ;��������� ������ � �����
    jc invalidInput
    call loadNumber      ;��������� ��������� ����� � ���������� ����
    loop inputNumbers
ret

invalidInput:           ;��������� �� ������ ��� ������ �����
    call printNewLine
    lea dx, invalidInputString
    call outputString
    jno tryAgainOutput  ;��������� ���� ��� ������
tryAgainOutput:
    lea dx, tryAgainString  ;����������� �� ��������� ����
    call outputString
    jmp repeatElementInput  ;��������� ����
    
loadNumber:
    mov [di], ax        ;���������  �������
    add di, sizeOfNumber    ;� ��������� ������
ret 
inputNumbers endp

;������� ������ � �����
;dx,bx,ax ������� � �������� ��������, si - ����� ������
;��������� ������������ � ax,
parseString proc
    xor dx,dx
    xor bx,bx
    xor ax,ax  
    xor ch,ch
    jmp inHaveSign    ;�������� �� ������� �����
parseStringLoop:
    mov bl, [si]  ;���������� �����(1 ����� = 1 �����) 
    jmp isNumber   ;�������� �� �����
validString:
    sub bl, '0'  ;�������� 30h, ������� �����
    imul numberTen ;ax * 10
    jo invalidString           ;����� ������ 16 ���
    js invalidString           ;����� ������ 15 ���
    cmp ch, 1                  ;���� ����� � �������
    je negativeAdd
    add ax, bx
    js invalidString           ;�������� �������������� ����� �� ��������� ����� 
checkInvalid:
    inc si
    jmp parseStringLoop
             
negativeAdd:
    sub ax, bx   ;
    jmp checkInvalid             
             
isNumber:
    cmp bl, 0Dh          ;����� ������(����� enter)
    je endParsing        ;���� ����� �� ����� ������ - ���������� ������� ������
    cmp bl, '0'                               
    jl invalidString     ;���� ASCII < '0'
    cmp bl, '9'
    jg invalidString     ;���� ASCII > '9'      
    jmp validString      ;�����
  
inHaveSign:
    cmp [si], '-'   ;�������� �� �����
    je negative
    cmp [si], '+'   ;�������� �� ����
    jne isNullString
    inc si     
    jmp isNullString
    
negative: 
    mov ch, 1  ;���� ����� � ������� ������������� ch = 1
    inc si      ;� ���������� �� ���� �����
    jmp isNullString

isNullString:
    cmp [si], 0Dh  ;���� ����� ������ - ������(���������� �����)
    je invalidString
    jmp parseStringLoop
        
invalidString:
    ;pop bx   ;1 ��� -1
    xor ch, ch         
    stc   ;CF = 1
ret

endParsing:
    clc  ;CF = 0
    xor ch, ch
ret
parseString endp

;����� �����
;ax - ���� �����, di - ����� ���������� 
;����� �������������� di ��������� ����� ������� '$'
numberToString proc
    push 0          
    push 0024h  ;$
    add ax, 0000h      
    js numberIsNegative ;���� ���� ���� (����� < 0)  
numberToStringConvertingLoop:    
    xor dx,dx
    div numberTen ;��������� ����� � ������
    add dx, '0' ;��������� ���� ��� ����,����� �������� ������ �� �����
    push dx
    cmp ax, 0h
    jne numberToStringConvertingLoop   
moveNumberToBuffer:
    pop ax
    cmp al, '$'    ;���������� � �������� ����� ������
    je endConverting  ;���� ����� - ����������� �������
    mov [di], al    ;��������� ����� ��������
    inc di        ;� ��������� �� �����
    jmp moveNumberToBuffer
endConverting:
    pop ax
    mov [di], '$'
ret

numberIsNegative:
    mov [di], '-'
    inc di
    not ax  ;�������� ����� � ��
            ;��������� ������� ��� ��� ����        
    inc ax ;��� ����������� �������������� �� �������������� � �������������
    jmp NumberToStringConvertingLoop 
numberToString endp    

;���� ���-�� �����
rowInput proc 
    call printNewLine    
    lea dx, inputRowsString
    call outputString         
    lea di, rows  
    mov cx, 0001h ;���� ������ �����
    call inputNumbers
    cmp ax, maxMassiveLength   ;������ ������� ������
    jg invalidRowsInput
    cmp ax, 0001h       ;�� ���� �����
    jl invalidRowsInput     
    call printNewLine
ret

invalidRowsInput:     ;������ �����
    call printNewLine
    lea dx, invalidLengthString
    call outputString        ;����� ��������� �� ������
    call printNewLine
    jmp rowInput      ;��������� ����
rowInput endp
   
;���� ����� �����   
colInput proc 
    call printNewLine    
    lea dx, inputColsString
    call outputString         
    lea di, cols  
    mov cx, 0001h  ;���� ������ �����
    call inputNumbers
    cmp ax, maxMassiveLength  ;���������� � ���������� ������� ������
    jg invalidColsInput
    cmp ax, 0001h        ;�������� ���� �����
    jl invalidColsInput     
    call printNewLine
ret    
    
invalidColsInput:   ;������ �����
    call printNewLine
    lea dx, invalidLengthString
    call outputString  ;������� ��������� �� ������
    call printNewLine
    jmp colInput      ;��������� ����
colInput endp 

getTotal proc       ;��������� ��������� ������� �������
    mov ax, rows      ;�������� rows � ��
    mov bx, cols      ;�������� cols � ��
    mul bx            ;�������� �� �� ��
    mov total, ax     ;���������� ��������� 
ret
getTotal endp

;���� �������
msInput proc
    call printNewLine ;����� ������
    lea dx, inputArrayString   ;����������� �� ����
    call outputString             
    xor cx, cx
    mov cx, total     ;���������� ������ �������
    lea di, array      ;�������� ������
    call inputNumbers
    call printNewLine 
ret
msInput endp 
  
;����� ������
msOutput proc
    mov i, 0000h    ;������ �� ������ �������
    mov j, 0000h
    lea si, array ;�������� ����� �������
    jmp loop2  
loop1:      
    lea dx, newLine
    call outputString
    mov j, 0000h
    inc i 
    mov cx, i
    cmp cx, cols
    je loop2return
loop2: 
    mov ax, [si]      ;������� �� ������ ��
    add si, sizeOfNumber             ;�����
    
    lea di, numberString[2]
    call numberToString         ;��������� ����� � ������ ��� ������
    lea dx, numberString[2]
    call outputString   ;������� ����� � ����� ���� ������
    lea dx, space
    call outputString
    inc j          ;������� �������� ������� � ������ 
    mov cx, j
    cmp cx , rows   ;���� ����� ������� �� ��������
    jne loop2 
    jmp loop1   ;������� �� ����� ������ �������
loop2return:    
ret
msOutput endp 

findMul proc         ;��������� ���������
    lea di, mulArray
    lea si, array 
    ;lea bx, resultArray
    mov i, 0000h
    mov j, 0000h 
    xor bp,bp
    xor ax, ax    ;������ ���������
    inc ax
    jmp mulLoop2  
mulLoop1:    
    mov [di], ax     ;����� ����������
    add di, sizeOfNumber   ;������� �� ��������� �������
    add bx, sizeOfNumber  
    add bp, sizeOfNumber
    lea si,array       ;����� �������
    add si,bp      ;������ �� �������(������� �� ����� �������)
    xor ax, ax
    inc ax 
    mov i, 0000h   ;����������� �������, ������� i
    inc j 
    mov cx, j      ;���������� �� ��������� �������
    cmp cx, rows
    je mulLoop2return
mulLoop2: 
    imul one, [si]    ;�������� ������������
    jo overflowMul    ;�������� �� ������������
     
mulLoop2next: 
    add si, rows      ;������� �� ����� ������
    add si, rows 
    inc i
    mov cx, i
    cmp cx , cols     ;�������� �� ���� ������
    jne mulLoop2 
    jmp mulLoop1
mulLoop2return:    
ret
findMul endp
 

printMul proc     ;����� ����������
    lea si, mulArray
    lea bx, resultArray
    mov i, 0000h
    
startPrintMul:   
    cmp [bx], 0       ;� �������� ���������� ������ �������
    je printOverflow
    mov ax, [si]     
    
    lea di, numberString[2]
    call numberToString

    lea dx, numberString[2]
    call outputString   
    call printNewLine

nextPrint:    
    inc i                  ;��������� �� ��������� �������
    add si, sizeOfNumber  ;�������� �� ������ ������ ��������
    add bx, sizeOfNumber
    mov cx, i
    cmp cx, rows          ;���� �� ����� �� ������ - ���������� ��������
    jne startPrintMul 
ret
printMul endp

printOverflow:   ;������������ 
    lea dx, overflow
    call outputString
    call printNewLine
    jmp nextPrint
    
overflowMul: 
    mov word ptr [bx], 0
    jmp mulLoop2next
               
;��������� ����� � ������ 
printNewLine proc   ;������� �� ����� ������
    lea dx, newLine
    call outputString
ret
printNewLine endp

outputString proc ;����� ������
    mov ah, 09h
    int 21h    
ret
outputString endp

inputString proc  ;���� ������
    mov ah, 0Ah
    int 21h
ret
inputString endp

start:
    mov ax, data
    mov ds, ax
    mov es, ax
    xor ax, ax 
    
    mov [numberString], numberStringLength  ;������ ���� ����� ������
    lea dx, inputLimitsString
    call outputString       ;������� ��������� ������
    call printNewLine

    call rowInput           ;���� ���-�� ����� 
    call colInput           ;���� ���-�� ����� 
    call getTotal           ;������ �������
    call msInput            ;���� �������
    call msOutput           ;����� �������
    call findMul            ;������� ������������ ��������
    call printNewLine       ;������� �� ����� ������
    call printMul           ;������� ������������
    
exit:                       ;����� 
    mov ax, 4c00h
    int 21h    
ends

end start    
