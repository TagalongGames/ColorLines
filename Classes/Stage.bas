#include once "Stage.bi"

Function GetRandomBoolean()As Boolean
	
	Dim RndValue As Long = rand()
	
	If RndValue > RAND_MAX \ 2 Then
		Return True
	End If
	
	Return False
	
End Function

Function GetRandomBallColor()As BallColors
	
	Const SevenPart As Long = RAND_MAX \ 7
	Dim RndValue As Long = rand()
	
	Return Cast(BallColors, RndValue Mod 7)
	
End Function

Sub Visualisation( _
		ByVal pStage As Stage Ptr _
	)
	' ��������� ������������� ��� ������� ��������� �������
	' Dim OldRect As RECT
	
	' ����������� ������
	' object.Move
	
	' ��������� ������������� ��� ������ ��������� �������
	' Dim NewRect As RECT
	
	' ���������� ��� ��������������
	' Dim UnionRect As RECT
	
	' ����������� ����� � �����
	' Render(hDC)
	
	' ������� � ���� ������������ �������������
	' InvalidateRect(hWin, @UnionRect, FALSE)
End Sub

Function CreateStage( _
		ByVal HiScore As Integer, _
		ByVal UpdateFunction As StageUpdateFunction, _
		ByVal Context As Any Ptr _
	)As Stage Ptr
	
	Dim pStage As Stage Ptr = Allocate(SizeOf(Stage))
	If pStage = NULL Then
		Return NULL
	End If
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			' Dim RndExists As Boolean = GetRandomBoolean()
			pStage->Lines(j, i).Ball.Exist = True 'RndExists
			
			Dim RndColor As BallColors = GetRandomBallColor()
			pStage->Lines(j, i).Ball.Color = RndColor
		Next
	Next
	
	For i As Integer = 0 To 2
		pStage->Tablo(i).Ball.Exist = False
	Next
	
	pStage->MovedBall.Exist = False
	pStage->lpfnUpdateFunction = UpdateFunction
	pStage->Context = Context
	pStage->Score = 0
	pStage->HiScore = HiScore
	
	Return pStage
	
End Function

Sub DestroyStage( _
		ByVal pStage As Stage Ptr _
	)
	
	Deallocate(pStage)
	
End Sub

Sub StageRecalculateSizes( _
		ByVal pStage As Stage Ptr, _
		ByVal SceneWidth As UINT, _
		ByVal SceneHeight As UINT _
	)
	
	Const DefaultCellWidth As UINT = 40
	Const DefaultCellHeight As UINT = 40
	
	Const DefaultBallWidth As UINT = 36
	Const DefaultBallHeight As UINT = 36
	
	Const SquareMargin As UINT = 100
	
	Dim SquareLength As UINT = min(SceneWidth, SceneHeight)
	
	Dim CellWidth As UINT = max(DefaultCellWidth, (SquareLength - SquareMargin) \ 9)
	Dim CellHeight As UINT = max(DefaultCellHeight, (SquareLength - SquareMargin) \ 9)
	
	Dim BallWidth As UINT = (CellWidth \ 10) * 9
	Dim BallHeight As UINT = (CellHeight \ 10) * 9
	
	Dim BallMarginWidth As UINT = (CellWidth - BallWidth) \ 2
	Dim BallMarginHeight As UINT = (CellHeight - BallHeight) \ 2
	
	' ������
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			SetRect(@pStage->Lines(j, i).CellRectangle, _
				i * CellWidth, _
				j * CellHeight, _
				i * CellWidth + CellWidth, _
				j * CellHeight + CellHeight _
			)
		Next
	Next
	
	' ���
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			SetRect(@pStage->Lines(j, i).Ball.BallRectangle, _
				i * CellWidth + BallMarginWidth, _
				j * CellHeight + BallMarginHeight, _
				i * CellWidth + BallWidth, _
				j * CellHeight + BallHeight _
			)
		Next
	Next
	
End Sub

Function StageGetCellFromPoint( _
		ByVal pStage As Stage Ptr, _
		ByVal pp As POINT Ptr, _
		ByVal pCell As POINT Ptr _
	)As Boolean
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			If PtInRect(@pStage->Lines(j, i).CellRectangle, *pp) Then
				pCell->x = i
				pCell->y = j
				Return True
			End If
		Next
	Next
	
	pCell->x = 0
	pCell->y = 0
	
	Return False
	
End Function

Sub StageClick( _
		ByVal pStage As Stage Ptr, _
		ByVal pp As POINT Ptr _
	)
	
	' ���� �� ����� ������ � �� �������� ���������� ������
	Dim CellCoord As POINT = Any
	Dim b As Boolean = StageGetCellFromPoint( _
		pStage, _
		pp, _
		@CellCoord _
	)
	If b Then
		' �������� ������
		' ���� ��� ����������, �� ���� ��� ��� ������ � ���������� � ������� ����� ���
		' ���� �� ���������� � ��� ������ � ����� ���� ��� ����������� � �����������
	End If
	
End Sub
