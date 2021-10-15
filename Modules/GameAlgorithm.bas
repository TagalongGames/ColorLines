#include once "GameAlgorithm.bi"

Function GetLeePath( _
		ByVal ptStart As SquareCoord Ptr, _
		ByVal ptEnd As SquareCoord Ptr , _
		ByVal StageWidth As Integer, _
		ByVal StageHeight As Integer, _
		ByVal Grid As Integer Ptr, _
		ByVal IncludeDiagonalPath As Boolean, _
		ByVal pPath As SquareCoord Ptr _
	)As LeePathLength
	
	' смещени€, соответствующие сосед€м €чейки
	' справа, снизу, слева, сверху и диагональные
	Dim dx(7) As Integer = {1, 0, -1, 0, 1, -1, -1, 1}
	Dim dy(7) As Integer = {0, 1, 0, -1, 1, 1, -1, -1}
	
	Dim MaxK As Integer = Any
	If IncludeDiagonalPath Then
		MaxK = 7
	Else
		MaxK = 3
	End If
	
	Dim d As Integer, x As Integer, y As Integer, StopFlag As Boolean
	
	' распространение волны
	
	Do
		' предполагаем, что все свободные клетки уже помечены
		StopFlag = True
		
		For y = 0 To StageHeight - 1
			For x = 0 To StageWidth - 1
				
				' €чейка (x, y) помечена числом d
				If Grid[y * StageWidth + x] = d Then
					' проходим по всем непомеченным сосед€м
					For k As Integer = 0 To MaxK
						' „тобы не вылезти за границы массива
						If y + dy(k) >= 0 AndAlso y + dy(k) < StageHeight AndAlso x + dx(k) >= 0 AndAlso x + dx(k) < StageWidth Then
							'y * StageWidth + x
							If Grid[(y + dy(k)) * StageWidth + x + dx(k)] = SquareLType.Blank Then
								' найдены непомеченные клетки
								StopFlag = False
								' распростран€ем волну
								Grid[(y + dy(k)) * StageWidth + x + dx(k)] = d + 1
							End If
						End If
					Next
				End If
				
			Next
		Next
		
		d += 1
		
	Loop While StopFlag = False AndAlso Grid[ptEnd->Y * StageWidth + ptEnd->X] = SquareLType.Blank
	
	If Grid[ptEnd->Y * StageWidth + ptEnd->X] = SquareLType.Blank Then
		' путь не найден
		Return 0
	End If
	
	' восстановление пути
	
	' длина кратчайшего пути из (StartX, StartY) в (EndX, EndY)
	Dim PathLen As Integer = Grid[ptEnd->Y * StageWidth + ptEnd->X]
	x = ptEnd->X
	y = ptEnd->Y
	d = PathLen
	
	Do While d > 0
		' записываем €чейку (x, y) в путь
		pPath[d].x = x
		pPath[d].y = y
		d -= 1
		
		For k As Integer = 0 To MaxK
			If y + dy(k) >= 0 AndAlso y + dy(k) < StageWidth AndAlso x + dx(k) >= 0 AndAlso x + dx(k) < StageWidth Then
				If Grid[(y + dy(k)) * StageWidth + x + dx(k)] = d Then
					x += dx(k)
					' переходим в €чейку, котора€ на 1 ближе к старту
					y += dy(k)
					Exit For
				End If
			End If
			
		Next
	Loop
	
	' “еперь путь будет с начала и до конца
	pPath[d].x = ptStart->X
	pPath[d].y = ptStart->Y
	
	Return PathLen
	
End Function
