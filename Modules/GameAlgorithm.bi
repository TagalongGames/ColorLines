#ifndef GAMEALGORITHM_BI
#define GAMEALGORITHM_BI

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

#ifndef _SQUARECOORD_DEFINED_
#define _SQUARECOORD_DEFINED_

Type SquareCoord
	X As Integer
	Y As Integer
End Type

#endif

Declare Function GetLeePath( _
	ByVal ptStart As SquareCoord Ptr, _
	ByVal ptEnd As SquareCoord Ptr , _
	ByVal StageWidth As Integer, _
	ByVal StageHeight As Integer, _
	ByVal Grid As Integer Ptr, _
	ByVal IncludeDiagonalPath As Boolean, _
	ByVal pPath As SquareCoord Ptr _
)As LeePathLength

#endif
