.model small
.stack 100h

.186
.data
str2 db "Data from COM2:",0Dh,0Ah,'$'
COM2 equ 02F8h
str3 db "Line break detected",0Dh,0Ah,'$'

.code
jmp start

get_str  proc ;��������� ������
    mov dx,1
    mov ah,2   ;������ ������� �� ����������������� �����
    int 14h
    ret
get_str endp

start:
mov ax,@data
mov ds,ax
mov ah,9
mov dx,offset str2 ;����� ������ str2
int 21h
mov ah,3 ;��������� ������� �����
mov dx,1
int 14h
test ah,10000b 
jz output
mov dx,offset str3  ;����� ������ str3
mov ah,9
int 21h

output:
mov ax,0  ;������������� �����
call get_str ;����� ��������� ��������� ������
mov dl,al  ;
mov ah,2 ;������ ������� �� �����
int 21h
mov ax,4C00h
int 21h

end start