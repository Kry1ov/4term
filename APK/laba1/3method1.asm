.model small
.stack 100h

.186
.data
str1 db "Enter in COM1:",0Dh,0Ah,'$'
COM1 equ 03F8h
str2 db "Line break detected.",0Dh,0Ah,'$'


.code
jmp start



start:
mov ax,@data
mov ds,ax 
;��������� COM1
mov dx,03FDh
in al,dx; ���������� ���� �� �����
test al,10000b
jz ok ;���� �������,�� ��������� � ���������
;����� ������� ��������� �� ������
mov dx,offset str2 ;����� ������ str2
mov ah,9
int 21h
jmp end 
    
    
ok:
mov dx,03FBh;��� ������ � ������
xor ax,ax;������� �������
mov ax,080h
out dx,al ;����� ������ �� �������� � ����
mov dx,03F8h ;���� ������� ��� - 0
;�� �������� ������
mov ax,000Ch ;������������� ������� �����
out dx,al
mov dx,03FBh
xor ax,ax
mov ax,0011b ;��������� ������ 8N1
out dx,al
    ;��������� COM2
mov dx,02FBh;������ � ������
xor ax,ax
mov ax,080h
out dx,al
mov dx,02F8h
mov ax,000Ch;��������� ������� ����� 9600
out dx,al
mov dx,02FBh;������ � ������
xor ax,ax
mov ax,0011b;��������� ������ 8N1
out dx,al
mov ah,9
mov dx,offset str1
int 21h 

input:
        
mov ah,1 ;������ ������� � ����
int 21h
mov dx,COM1
out dx,al ;����� �� �������� � ����
        
end:   ;���������� ������ ��������� 
mov ax,4C00h
int 21h
end start