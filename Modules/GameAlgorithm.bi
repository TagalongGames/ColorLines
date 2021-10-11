#ifndef GAMEALGORITHM_BI
#define GAMEALGORITHM_BI

#include once "windows.bi"

' ��� ������ � ���������
Enum SquareLType
	' ��������� ������������ ������
	Blank = -2
	' ������������ ������, �����
	Wall = -1
	' ��������� ������
	Start = 0
End Enum

Type LeePathLength As Integer

/'
	�������� �������� �� ���������� ���� � ���������
	
	ptStart � ����� �����������.
	ptEnd � ����� ����������.
	StageHeight � ������ ��������� (���������� ������ �� ���������)
	StageWidth � ������ ��������� (���������� ������ �� �����������)
	Grid � ��������� �� ������ ����������� ������� ��������������� ���������
	IncludeDiagonalPath � ����, ������������ ��������� ������������ �����
	pPath � ��������� �� ������ (����������) ��������� ����
	������ pPath ������ ����� ����������� �����, ����� �������� ���� ���� (StageHeight * StageWidth)
	���� ������� ������� ���������� ����, ���� �� ����������
	
	���������� ����� ����, 0 ���� ���� �� ����������
	
	���������
	���������� � ��������� ���������� � ����
	���������� � ��������� �������� �������� �� ������. [y * StageWidth + x]
	�������� ���������� ��������������� ������� �����������
	��� ����� ��� ��������� ������ ������ ����� �������� SquareLType.Blank
	��� ������������ ������ (�����) ������ ����� �������� SquareLType.Wall
	��������� ������ ������ ���� �������� SquareLType.Start
	���������� �������, ��� �������� ����� ��������� Greed � �������� ������ �������
	����� �������� (���������� ���������� ����� ������������� ���������)
	
'/

Declare Function GetLeePath( _
	ByVal ptStart As POINT, _
	ByVal ptEnd As POINT, _
	ByVal StageWidth As Integer, _
	ByVal StageHeight As Integer, _
	ByVal Grid As Integer Ptr, _
	ByVal IncludeDiagonalPath As Boolean, _
	ByVal pPath As POINT Ptr _
)As LeePathLength

#endif
