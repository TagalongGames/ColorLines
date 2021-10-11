#include once "GameAlgorithm.bi"

Function GetLeePath( _
		ByVal ptStart As POINT, _
		ByVal ptEnd As POINT, _
		ByVal StageWidth As Integer, _
		ByVal StageHeight As Integer, _
		ByVal Grid As Integer Ptr, _
		ByVal IncludeDiagonalPath As Boolean, _
		ByVal pPath As POINT Ptr _
	)As LeePathLength
	
	' ��������, ��������������� ������� ������
	' ������, �����, �����, ������ � ������������
	Dim dx(7) As Integer = {1, 0, -1, 0, 1, -1, -1, 1}
	Dim dy(7) As Integer = {0, 1, 0, -1, 1, 1, -1, -1}
	
	Dim MaxK As Integer = Any
	If IncludeDiagonalPath Then
		MaxK = 7
	Else
		MaxK = 3
	End If
	
	Dim d As Integer, x As Integer, y As Integer, stopp As Integer
	
	' ��������������� �����
	
	Do
		' ������������, ��� ��� ��������� ������ ��� ��������
		stopp = 1
		
		For y = 0 To StageHeight - 1
			For x = 0 To StageWidth - 1
				
				' ������ (x, y) �������� ������ d
				If Grid[y * StageWidth + x] = d Then
					' �������� �� ���� ������������ �������
					For k As Integer = 0 To MaxK
						' ����� �� ������� �� ������� �������
						If y + dy(k) >= 0 AndAlso y + dy(k) < StageHeight AndAlso x + dx(k) >= 0 AndAlso x + dx(k) < StageWidth Then
							'y * StageWidth + x
							If Grid[(y + dy(k)) * StageWidth + x + dx(k)] = SquareLType.Blank Then
								' ������� ������������ ������
								stopp = 0
								' �������������� �����
								Grid[(y + dy(k)) * StageWidth + x + dx(k)] = d + 1
							End If
						End If
					Next
				End If
				
			Next
		Next
		
		d += 1
		
	Loop While stopp = 0 AndAlso Grid[ptEnd.y * StageWidth + ptEnd.x] = SquareLType.Blank
	
	If Grid[ptEnd.y * StageWidth + ptEnd.x] = SquareLType.Blank Then
		' ���� �� ������
		Return 0
	End If
	
	' �������������� ����
	
	' ����� ����������� ���� �� (StartX, StartY) � (EndX, EndY)
	Dim PathLen As Integer = Grid[ptEnd.y * StageWidth + ptEnd.x]
	x = ptEnd.x
	y = ptEnd.y
	d = PathLen
	
	Do While d > 0
		' ���������� ������ (x, y) � ����
		pPath[d].x = x
		pPath[d].y = y
		d -= 1
		
		For k As Integer = 0 To MaxK
			If y + dy(k) >= 0 AndAlso y + dy(k) < StageWidth AndAlso x + dx(k) >= 0 AndAlso x + dx(k) < StageWidth Then
				If Grid[(y + dy(k)) * StageWidth + x + dx(k)] = d Then
					x += dx(k)
					' ��������� � ������, ������� �� 1 ����� � ������
					y += dy(k)
					Exit For
				End If
			End If
			
		Next
	Loop
	
	' ������ ���� ����� � ������ � �� �����
	pPath[d].x = ptStart.x
	pPath[d].y = ptStart.y
	
	Return PathLen
	
End Function

