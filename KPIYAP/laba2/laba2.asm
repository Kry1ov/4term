;���������� ���� � ������ �� ��������


.model small
.stack 100h

.data
size equ 200
string db size, ?, size dup('$') 
enter db 0Dh,0Ah,'$' 
point dw 0      ;������������ ��� �������� ������� ����
counter dw 0   ;������� ����

flg dw 0

str1 db "Enter the string: $"
str2 db "Entered string:$"
str3 db "After sort:$"



.code  
 

input macro str    ; ���� ������
    lea dx,str
    mov str,size  
    mov ah,0Ah          
    int 21h
endm   

output macro str      ;����� ������
    lea dx,str
    mov ah,9
    int 21h 
endm   
        
space_skip macro i   ;���������� ������� 
    local c1  
    sub i,1
    c1: 
    inc i
    cmp string[2+i],' '  ;���������� ������ � ��������
    je c1
endm 

word_skip macro i        ;������� ����� 
    local f1,e1
    sub i,1
    f1: 
    inc i 
    cmp string[2+i],0Dh  ;���������� ������ � ������ ������
    je  e1
    
    cmp string[2+i],' '   
    jne f1  
    e1:
endm  

word_count macro   ;������� ���������� ����
    local a1
    mov si,-1 
    space_skip si
    a1:      
    word_skip si
    space_skip si
    inc counter  
    cmp string[2+si],0Dh
    jne a1
endm

capital_check macro i ;�������� �� ������� ����� �� ���� ����
    local j1
    cmp i, 61h
    jb j1    
    cmp i,7Ah 
    ja j1
    sub i,20h
    j1:
endm
          
reverse macro             ;������ �������� � ������ �� si �� di
    local r1,endrev
    sub si,1
    inc di
    r1:
    inc si
    sub di,1
    cmp si,di ;�������� �� ��,��� �� �� ����� �� ����� �������
    jae endrev
    mov dl,string[2+si]     ;���� ��������
    mov dh,string[2+di]
    mov string[2+si],dh                  
    mov string[2+di],dl 
    jmp r1
    endrev: 
endm       
    

flag:         ; ������������� ���� �� ������� ��� ���������� 
    mov flg,1
    jmp e3


compare proc    ;���������� ����� 
    mov flg,0 
    push si     ;si - ������� ������� �����
    push di     ;di - ������� ������� �����
    
    sub si,1
    sub di,1
    f3:
    inc si
    inc di
    mov ah, string[2+di]
    mov al, string[2+si] 
    capital_check ah
    capital_check al
    cmp al,ah
    je f3
    ja flag
    
    e3:             
    pop di
    pop si
    ret
endp 
           

main: 
    mov ax,@data
    mov ds,ax       
    
    output str1         
    output enter
    
    input string    
    output enter
                
    output str2
    output enter
                
    output string[2]
    output enter  
    word_count     ; ������� ���������� ���� 
    inc [counter] 
sort1: 
    sub [counter],1  
    cmp [counter],0  
    je end_sort 
    mov si,0                
    mov di,0  
    
    space_skip si           ;������� �������� � ������
    mov ah,string[2+si]     
    cmp ah,0Dh              ;�������� �� ����� ������
    je end_sort   
    mov point,si             ;� ������ ������� ������� �����
    
    sort2: 
    mov si,point             ;si �� ������� ������� �����
    word_skip si
    space_skip si            ;������ ����� �� �� �� ���� �����
    cmp string[si+2],0Dh
    je sort1        
    mov si,point
    mov di,si
    word_skip di             ;di �� ������ �����
    space_skip di 
    call compare      
    mov point,di             ;���������� ��� ���������
    cmp flg,0 
    je sort2     
    
    swap:    
        push si
        word_skip di ; ������������ �� ����� ������� �����
        sub di,1  
        reverse 
        pop si  
        push si
        mov di,si  
        word_skip di                       
        sub di,1
        reverse  
        pop si
        word_skip si
        space_skip si
        mov di,si  
        mov point,si
        word_skip di
        sub di,1
        reverse 
        jmp sort2
                                 
end_sort:   

    output str3
    output enter
                
    output string[2]
    output enter   
    
    mov ah,4CH
    int 21h
               
                           
                            
end main       



 
                     