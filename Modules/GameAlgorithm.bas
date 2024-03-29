#include once "GameAlgorithm.bi"

' ��������, ��������������� ������� ������
' ������, �����, �����, ������ � ������������
Dim Shared m_dx(7) As Integer = {1, 0, -1, 0, 1, -1, -1, 1}
Dim Shared m_dy(7) As Integer = {0, 1, 0, -1, 1, 1, -1, -1}

Function GetLeePath( _
		ByVal ptStart As SquareCoord Ptr, _
		ByVal ptEnd As SquareCoord Ptr , _
		ByVal StageWidth As Integer, _
		ByVal StageHeight As Integer, _
		ByVal Grid As Integer Ptr, _
		ByVal IncludeDiagonalPath As Boolean, _
		ByVal pPath As SquareCoord Ptr _
	)As LeePathLength
	
	Dim MaxK As Integer = Any
	If IncludeDiagonalPath Then
		MaxK = 7
	Else
		MaxK = 3
	End If
	
	Dim d As Integer, x As Integer, y As Integer, StopFlag As Boolean
	
	' ��������������� �����
	
	Do
		' ������������, ��� ��� ��������� ������ ��� ��������
		StopFlag = True
		
		For y = 0 To StageHeight - 1
			For x = 0 To StageWidth - 1
				
				' ������ (x, y) �������� ������ d
				If Grid[y * StageWidth + x] = d Then
					' �������� �� ���� ������������ �������
					For k As Integer = 0 To MaxK
						' ����� �� ������� �� ������� �������
						If y + m_dy(k) >= 0 AndAlso y + m_dy(k) < StageHeight AndAlso x + m_dx(k) >= 0 AndAlso x + m_dx(k) < StageWidth Then
							'y * StageWidth + x
							If Grid[(y + m_dy(k)) * StageWidth + x + m_dx(k)] = SquareLType.Blank Then
								' ������� ������������ ������
								StopFlag = False
								' �������������� �����
								Grid[(y + m_dy(k)) * StageWidth + x + m_dx(k)] = d + 1
							End If
						End If
					Next
				End If
				
			Next
		Next
		
		d += 1
		
	Loop While StopFlag = False AndAlso Grid[ptEnd->Y * StageWidth + ptEnd->X] = SquareLType.Blank
	
	If Grid[ptEnd->Y * StageWidth + ptEnd->X] = SquareLType.Blank Then
		' ���� �� ������
		Return 0
	End If
	
	' �������������� ����
	
	' ����� ����������� ���� �� (StartX, StartY) � (EndX, EndY)
	Dim PathLen As Integer = Grid[ptEnd->Y * StageWidth + ptEnd->X]
	x = ptEnd->X
	y = ptEnd->Y
	d = PathLen
	
	Do While d > 0
		' ���������� ������ (x, y) � ����
		pPath[d].x = x
		pPath[d].y = y
		d -= 1
		
		For k As Integer = 0 To MaxK
			If y + m_dy(k) >= 0 AndAlso y + m_dy(k) < StageWidth AndAlso x + m_dx(k) >= 0 AndAlso x + m_dx(k) < StageWidth Then
				If Grid[(y + m_dy(k)) * StageWidth + x + m_dx(k)] = d Then
					x += m_dx(k)
					' ��������� � ������, ������� �� 1 ����� � ������
					y += m_dy(k)
					Exit For
				End If
			End If
			
		Next
	Loop
	
	' ������ ���� ����� � ������ � �� �����
	pPath[d].x = ptStart->X
	pPath[d].y = ptStart->Y
	
	Return PathLen
	
End Function
