#include once "Stage.bi"

Const DefaultCellWidth As UINT = 40
Const DefaultCellHeight As UINT = 40

Const DefaultBallWidth As UINT = 36
Const DefaultBallHeight As UINT = 36

Const SquareMargin As UINT = 0

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
	' Вычислить прямоугольник для старого положения объекта
	' Dim OldRect As RECT
	
	' Переместить объект
	' object.Move
	
	' Вычислить прямоугольник для нового положения объекта
	' Dim NewRect As RECT
	
	' Объединить оба прямоугольника
	' Dim UnionRect As RECT
	
	' Отрендерить сцену в буфер
	' Render(hDC)
	
	' Вывести в окно объединённый прямоугольник
	' InvalidateRect(hWin, @UnionRect, FALSE)
End Sub

Function CreateStage( _
		ByVal HiScore As Integer, _
		ByVal CallBacks As StageCallBacks Ptr, _
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
	pStage->CallBacks = *CallBacks
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

Sub StageNewGame( _
		ByVal pStage As Stage Ptr _
	)
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			pStage->Lines(j, i).Ball.State = BallStates.Stopped
			pStage->Lines(j, i).Ball.Exist = False
		Next
	Next
	
	For i As Integer = 0 To 2
		pStage->Tablo(i).Ball.State = BallStates.Stopped
		pStage->Tablo(i).Ball.Exist = False
	Next
	
	pStage->MovedBall.State = BallStates.Stopped
	pStage->MovedBall.Exist = False
	
	pStage->Score = 0
	
	pStage->CallBacks.Render( _
		pStage->Context, _
		NULL _
	)
	
End Sub

Sub StageRecalculateSizes( _
		ByVal pStage As Stage Ptr, _
		ByVal SceneWidth As UINT, _
		ByVal SceneHeight As UINT _
	)
	
	Dim SquareLength As UINT = 40 ' min(SceneWidth, SceneHeight)
	
	Dim CellWidth As UINT = max(DefaultCellWidth, (SquareLength - SquareMargin) \ 9)
	Dim CellHeight As UINT = max(DefaultCellHeight, (SquareLength - SquareMargin) \ 9)
	
	Dim BallWidth As UINT = (CellWidth \ 10) * 9
	Dim BallHeight As UINT = (CellHeight \ 10) * 9
	
	Dim BallMarginWidth As UINT = (CellWidth - BallWidth) \ 2
	Dim BallMarginHeight As UINT = (CellHeight - BallHeight) \ 2
	
	' Ячейка
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			SetRect(@pStage->Lines(j, i).Rectangle, _
				i * CellWidth, _
				j * CellHeight, _
				i * CellWidth + CellWidth, _
				j * CellHeight + CellHeight _
			)
		Next
	Next
	
	' Шар
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			SetRect(@pStage->Lines(j, i).Ball.Rectangle, _
				i * CellWidth + BallMarginWidth, _
				j * CellHeight + BallMarginHeight, _
				i * CellWidth + CellWidth - BallMarginWidth, _
				j * CellHeight + CellHeight - BallMarginHeight _
			)
		Next
	Next
	
	' Табло
	For i As Integer = 0 To 2
		SetRect(@pStage->Tablo(i).Rectangle, _
			i * CellWidth, _
			0 * CellHeight, _
			i * CellWidth + CellWidth, _
			0 * CellHeight + CellHeight _
		)
		SetRect(@pStage->Tablo(i).Ball.Rectangle, _
			i * CellWidth + BallMarginWidth, _
			0 * CellHeight + BallMarginHeight, _
			i * CellWidth + CellWidth - BallMarginWidth, _
			0 * CellHeight + CellHeight - BallMarginHeight _
		)
	Next
	
End Sub

Function StageGetCellFromPoint( _
		ByVal pStage As Stage Ptr, _
		ByVal pp As POINT Ptr, _
		ByVal pCell As POINT Ptr _
	)As Boolean
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			If PtInRect(@pStage->Lines(j, i).Rectangle, *pp) Then
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
	
	' Если мы можем тыкать — то получить координаты ячейки
	Dim CellCoord As POINT = Any
	Dim b As Boolean = StageGetCellFromPoint( _
		pStage, _
		pp, _
		@CellCoord _
	)
	If b Then
		' Получить ячейку
		' Если она существует, то если шар был выбран — развыбрать и выбрать новый шар
		' Если не существует и шар выбран — найти путь для перемещения и переместить
	End If
	
End Sub

Sub StageKeyPress( _
		ByVal pStage As Stage Ptr, _
		ByVal Key As StageKeys _
	)
	
End Sub

Function StageTick( _
		ByVal pStage As Stage Ptr _
	)As Boolean
	
	Return False
	
End Function

Function StageCommand( _
		ByVal pStage As Stage Ptr, _
		ByVal cmd As StageCommands _
	)As Boolean
	
	Return False
	
End Function

Function StageGetWidth( _
		ByVal pStage As Stage Ptr _
	)As UINT
	
	Return DefaultCellWidth * 9
	
End Function

Function StageGetHeight( _
		ByVal pStage As Stage Ptr _
	)As UINT
	
	Return DefaultCellHeight * 9
	
End Function
