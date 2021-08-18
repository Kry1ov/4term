#include <time.h>
#include <iostream>
using namespace std;

#define SIZE 4
#define COUNTER 1000000 //���������� ����������

void printArray(int array[SIZE][SIZE]); //����� �������

int main()
{
	srand(time(NULL));
	int array1[SIZE][SIZE], array2[SIZE][SIZE], array3[SIZE][SIZE];

	for (int i = 0; i < SIZE; i++) //���� �������
	{
		for (int j = 0; j < SIZE; j++)
		{
			//���������� ������ ���������� ����������
			array1[i][j] = rand() % 100; 
			array2[i][j] = rand() % 100;
		}
	}
	//����� �������� ������
	printf("Array 1:\n");
	printArray(array1);
	printf("Array 2:\n");
	printArray(array2);

	// ������� �� ����� ��
	clock_t begin_c = clock(); //�������� ������ �������
	for(int i=0;i<COUNTER;i++)
	{
		for (int i = 0; i < SIZE; i++)
		{
			for (int j = 0; j < SIZE; j++)
			{
				array3[i][j] = array1[i][j] | array2[i][j]; //��������� �������� ���������� ��� |
			}
		}
	}
	clock_t end_c = clock();

	//������� ���������
	printf("Result using C:\n");
	printArray(array3);
	printf("\n");

	// ������� �� ����������
	clock_t begin_asm = clock();
	for(int i=0;i<COUNTER;i++)
	{
		int cnt = 16;
		__asm
		{
			MOV ECX, cnt			   
			XOR ESI, ESI				   // ����� ������, ������ ���������
			START :
			MOV EAX, array1[ESI]	   // EAX = array1[ESI], �����������
			MOV EDX, array2[ESI]	   // EDX = array2[ESI], ������� ������
			OR EDX, EAX			   // �������� ����������� ���
			MOV array3[ESI], DX   // array3[ESI] = DX - ������ ���������� � 3 ������
			INC ESI             //��������� �������
			LOOP START
		}
	}
	clock_t end_asm = clock();
	//����� ����������
	printf("Result using ASM:\n");
	printArray(array3);
	printf("\n");

	// ������� � �������������� MMX
	clock_t begin_mmx = clock();
	for (int i=0;i<COUNTER;i++)
	{
		int cnt = 8;
		_asm
		{
			MOV ECX, cnt					// ���� - 8 ��������(�.�. � ������� 16 ��������� ��������
										// 4 ����� = 64, � MMX ��������� �� ���� ���������� ���������� 8 ����)
			XOR ESI, ESI					// ����� ������, ������ ���������
			STARTM :
			MOVQ MM0, array1[ESI]	    // ������ ������ � MMX ������� 
			MOVQ MM1, array2[ESI]		// ������ ������ � MMX ������� 
			POR MM0, MM1				// �������� ����������� ���
			MOVQ array3[ESI], MM0       //���������� ��������� � 3 ������
			INC ESI;                    // ����� �������
			LOOP STARTM
			EMMS							// ������� ��������
		}
	}
	clock_t end_mmx = clock();
	//����� ����������
	printf("Result using MMX:\n");
	printArray(array3);
	printf("\n");
	//����� ������������ �� ���������� �������
	printf("Computing using C\n");
	printf("time: %.6lf sec\n\n", (float)(end_c - begin_c) / CLOCKS_PER_SEC);

	printf("Computing using ASM\n");
	printf("time: %.6lf sec\n\n", (float)(end_asm - begin_asm) / CLOCKS_PER_SEC);

	printf("Computing using MMX\n");
	printf("time: %.6lf sec\n\n", (float)(end_mmx - begin_mmx) / CLOCKS_PER_SEC);

	system("pause");
	return 0;

}


void printArray(int array[SIZE][SIZE])
{
	for (int i = 0; i < SIZE; i++)
	{
		printf("\t");
		for (int j = 0; j < SIZE; j++)
		{
			printf("\t %d ", array[i][j]);
		}
		printf("\n");
	}
	printf("\n");
}



