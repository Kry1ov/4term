.model small
.stack 100h

.186
.data
str1 db "Enter in the COM1:",0Dh,0Ah,'$'
COM1 equ 03F8h
str2 db "Break detected.",0Dh,0Ah,'$'

.code
jmp start

start:
mov ax,@data
mov ds,ax
mov ah,9
mov dx,offset str1;����� ������ str1 
int 21h
mov dx,0 ;��������� ������� �����
mov ah,3
int 14h
test ah,10000b ;�������� ���������� ������� ����
jz ok
mov dx,offset str2 ;����� ������ str2
mov ah,9
int 21h
jmp end


ok:       ;������ �������
mov ah,1
int 21h
mov dx,0 ;��������� ������� �����
mov ah,1 ;������ ������� � ���������������� ����
int 14h

end: ;���������� ������
mov ax,4C00h
int 21h

end start