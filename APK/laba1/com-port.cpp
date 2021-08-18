#include <windows.h>
#include <iostream>

using namespace std;
void ReadCOM();
//��������� ����������� ��m ������
HANDLE hserial;
HANDLE hserial1;

int main(int argc, char* argv[])
{
    //��������� ������ � ������� ������
    LPCTSTR sPortname = L"COM2";
    LPCTSTR sPortname1 = L"COM1";
    hserial = ::CreateFile(sPortname, GENERIC_READ | GENERIC_WRITE, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);//��������� ��� ������ � ������
    hserial1 = ::CreateFile(sPortname1, GENERIC_READ | GENERIC_WRITE, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    if (hserial == INVALID_HANDLE_VALUE)//��������� ����������������� com1
    {
        if (GetLastError() == ERROR_FILE_NOT_FOUND)
        {
            cout << "serial port doesnt existd.\n";
        }
        cout << "some other error occured.\n";
    }
    if (hserial1 == INVALID_HANDLE_VALUE)//��������� ����������������� com1
    {
        if (GetLastError() == ERROR_FILE_NOT_FOUND)
        {
            cout << "serial port doesnt existd.\n";
        }
        cout << "some other error occured.\n";
    }
    //����������� �������� ����������
    DCB dcbSerialParams = { 0 };
    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
    if (!GetCommState(hserial, &dcbSerialParams))
    {
        cout << "getting state error.\n";
    }
    dcbSerialParams.BaudRate = CBR_9600;//�������� ��������
    dcbSerialParams.ByteSize = 8;//����� ������������� �����
    dcbSerialParams.StopBits = ONESTOPBIT;//1 ���� ���
    dcbSerialParams.Parity = NOPARITY;//���������� ���� ��������
    if (!SetCommState(hserial, &dcbSerialParams))
    {
        cout << "error setting serial port state.\n";
    }


    //����������� ��������� 2 �����
    DCB dcbSerialParams1 = { 0 };
    dcbSerialParams1.DCBlength = sizeof(dcbSerialParams1);
    if (!GetCommState(hserial, &dcbSerialParams1))
    {
        cout << "getting state error.\n";
    }
    dcbSerialParams1.BaudRate = CBR_9600;//�������� ��������
    dcbSerialParams1.ByteSize = 8;//����� ������������� �����
    dcbSerialParams1.StopBits = ONESTOPBIT;//1 ���� ���
    dcbSerialParams1.Parity = NOPARITY;//���������� ���� ��������
    if (!SetCommState(hserial1, &dcbSerialParams1))
    {
        cout << "error setting serial port state.\n";
    }

    char data[] = "Hello";//������ ��� ��������
    DWORD dwSize = sizeof(data);//������ ������
    DWORD dwByteWritten;//���������� ���������� ����

    //�������� ������
    BOOL iRet = WriteFile(hserial, data, dwSize, &dwByteWritten, NULL);
    //����� ���-�� ���������� ����
    cout << dwSize << "Bytes in string." << dwByteWritten << "Bytes sended." << endl;


    //���� ������ ������
    while (true)
    {
        ReadCOM();
    }
    return 0;
}


void ReadCOM()//������� ������
{
    DWORD iSize;
    char sReceiveChar;
    while (true)
    {
        ReadFile(hserial, &sReceiveChar, 1, &iSize, 0);//�������� 1 ����
        if (iSize > 0)//���� ���-�� �������,�� �������
        {
            cout << sReceiveChar;
        }
    }
}