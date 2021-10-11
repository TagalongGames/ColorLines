#include once "GameModel.bi"
#include once "GameAlgorithm.bi"
#include once "crt.bi"

Type _GameModel
	pStage As Stage Ptr
	Events As StageEvents
	Context As Any Ptr
	Grid(9 * 9 - 1) As Integer
	SelectedCellX As Integer
	SelectedCellY As Integer
End Type

Declare Function MoveBall( _
	ByVal pModel As GameModel Ptr, _
	ByVal OldCoord As POINT Ptr, _
	ByVal NewCoord As POINT Ptr, _
	ByVal pPath As POINT Ptr, _
	ByVal pPathLength As Integer Ptr _
)As Boolean

Function RemoveLines( _
		ByVal pModel As GameModel Ptr _
	)As Boolean
	
	' Cписок удаляемых ячеек
	Dim RemovedCells(0 To 9 * 9 - 1) As POINT = Any
	Dim RemovedCellsCount As Integer = 0
	
	' Строки
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			Dim Length As Integer = RowSequenceLength(pModel->pStage, i, j, pModel->pStage->Lines(j, i).Ball.Color)
			If Length >= 5 Then
				For k As Integer = i To Length + i - 1
					RemovedCells(RemovedCellsCount).x = k
					RemovedCells(RemovedCellsCount).y = j
					RemovedCellsCount += 1
				Next
				i += Length
			End If
		Next
	Next
	' Столбцы
	For i As Integer = 0 To 8
		For j As Integer = 0 To 8
			Dim Length As Integer = ColSequenceLength(pModel->pStage, i, j, pModel->pStage->Lines(j, i).Ball.Color)
			If Length >= 5 Then
				For k As Integer = j To Length + j - 1
					RemovedCells(RemovedCellsCount).x = i
					RemovedCells(RemovedCellsCount).y = k
					RemovedCellsCount += 1
				Next
				j += Length
			End If
		Next
	Next
	' Главные диагонали
	For t As Integer = 4 To 0 Step -1
		Dim i As Integer = 0
		Dim j As Integer = t
		Do While (i <= 8) OrElse (j <= 8)
			Dim Length As Integer = ForwardDiagonalSequenceLength(pModel->pStage, i, j, pModel->pStage->Lines(j, i).Ball.Color)
			If Length >= 5 Then
				For k As Integer = 0 To Length - 1
					RemovedCells(RemovedCellsCount).x = i + k
					RemovedCells(RemovedCellsCount).y = j + k
					RemovedCellsCount += 1
				Next
				i += Length
				j += Length
			Else
				i += 1
				j += 1
			End If
		Loop
	Next
	For t As Integer = 1 To 4
		Dim i As Integer = t
		Dim j As Integer = 0
		Do While (i <= 8) OrElse (j <= 8)
			Dim Length As Integer = ForwardDiagonalSequenceLength(pModel->pStage, i, j, pModel->pStage->Lines(j, i).Ball.Color)
			If Length >= 5 Then
				For k As Integer = 0 To Length - 1
					RemovedCells(RemovedCellsCount).x = i + k
					RemovedCells(RemovedCellsCount).y = j + k
					RemovedCellsCount += 1
				Next
				i += Length
				j += Length
			Else
				i += 1
				j += 1
			End If
		Loop
	Next
	' Побочные диагонали
	For t As Integer = 8 To 4 Step -1
		Dim i As Integer = t
		Dim j As Integer = 0
		Do While (i >= 0) OrElse (j <= 8)
			Dim Length As Integer = BackwardDiagonalSequenceLength(pModel->pStage, i, j, pModel->pStage->Lines(j, i).Ball.Color)
			If Length >= 5 Then
				For k As Integer = 0 To Length - 1
					RemovedCells(RemovedCellsCount).x = i - k
					RemovedCells(RemovedCellsCount).y = j + k
					RemovedCellsCount += 1
				Next
				i -= Length
				j += Length
			Else
				i -= 1
				j += 1
			End If
		Loop
	Next
	For t As Integer = 1 To 4
		Dim i As Integer = 8
		Dim j As Integer = t
		Do While (i >= 0) OrElse (j <= 8)
			Dim Length As Integer = BackwardDiagonalSequenceLength(pModel->pStage, i, j, pModel->pStage->Lines(j, i).Ball.Color)
			If Length >= 5 Then
				For k As Integer = 0 To Length - 1
					RemovedCells(RemovedCellsCount).x = i - k
					RemovedCells(RemovedCellsCount).y = j + k
					RemovedCellsCount += 1
				Next
				i -= Length
				j += Length
			Else
				i -= 1
				j += 1
			End If
		Loop
	Next
	
	If RemovedCellsCount = 0 Then
		Return False
	End If
	
	For i As Integer = 0 To RemovedCellsCount - 1
		pModel->pStage->Lines(RemovedCells(i).y, RemovedCells(i).x).Ball.Visible = False
	Next
	
	pModel->Events.OnLinesChanged( _
		pModel->Context, _
		@RemovedCells(0), _
		RemovedCellsCount _
	)
	
	pModel->pStage->Score += RemovedCellsCount
	pModel->Events.OnScoreChanged( _
		pModel->Context, _
		RemovedCellsCount _
	)
	
	If pModel->pStage->Score > pModel->pStage->HiScore Then
		pModel->pStage->HiScore = pModel->pStage->Score
		pModel->Events.OnHiScoreChanged( _
			pModel->Context, _
			RemovedCellsCount _
		)
	End If
	
	Return True
	
End Function

Sub GenerateTablo( _
		ByVal pModel As GameModel Ptr _
	)
	
	For i As Integer = 0 To 2
		Dim RandomColor As BallColors = GetRandomBallColor()
		pModel->pStage->Tablo(i).Ball.Color = RandomColor
	Next
	
	pModel->Events.OnTabloChanged( _
		pModel->Context _
	)
	
End Sub

Function ExtractBalls( _
		ByVal pModel As GameModel Ptr _
	)As Boolean
	
	Dim ExtractCount As Integer = 0
	
	For i As Integer = 0 To 2
		' Выбрать случайную свободную ячейку
		' Если пустых нет, то вернуть ошибку
		Dim pt As POINT = Any
		Dim NotEmpty As Boolean = StageGetRandomEmptyCellCoord(pModel->pStage, @pt)
		
		If NotEmpty Then
			
			Dim RandomColor As BallColors = pModel->pStage->Tablo(i).Ball.Color
			
			/'
			Dim buffer As WString * (255 + 1) = Any
			Const ffFormat = WStr("{%d, %d}, %d")
			swprintf(@buffer, @ffFormat, x, y, RandomColor)
			buffer[255] = 0
			MessageBoxW(NULL, @buffer, NULL, MB_OK)
			'/
			
			' Поместить на игровое поле
			pModel->pStage->Lines(pt.y, pt.x).Ball.Color = RandomColor
			pModel->pStage->Lines(pt.y, pt.x).Ball.Frame = AnimationFrames.Birth0
			pModel->pStage->Lines(pt.y, pt.x).Ball.Visible = True
			
			ExtractCount += 1
			
			pModel->Events.OnLinesChanged( _
				pModel->Context, _
				@pt, _
				1 _
			)
		End If
	Next
	
	If ExtractCount > 2 Then
		Return True
	End If
	
	Return False
	
End Function

Function MoveBall( _
		ByVal pModel As GameModel Ptr, _
		ByVal OldCoord As POINT Ptr, _
		ByVal NewCoord As POINT Ptr, _
		ByVal pPath As POINT Ptr, _
		ByVal pPathLength As Integer Ptr _
	)As Boolean
	
	Scope
		For j As Integer = 0 To 8
			For i As Integer = 0 To 8
				If pModel->pStage->Lines(j, i).Ball.Visible Then
					pModel->Grid(j * 9 + i) = SquareLType.Wall
				Else
					pModel->Grid(j * 9 + i) = SquareLType.Blank
				End If
			Next
		Next
		pModel->Grid(OldCoord->y * 9 + OldCoord->x) = SquareLType.Start
	End Scope
	
	' Получить путь
	Dim PathLength As Integer = GetLeePath( _
		*OldCoord, _
		*NewCoord, _
		9, _
		9, _
		@pModel->Grid(0), _
		False, _
		pPath _
	)
	If PathLength = 0 Then
		Return False
	End If
	
	' Переместить шар
	pModel->pStage->Lines(OldCoord->y, OldCoord->x).Ball.Visible = False
	pModel->pStage->Lines(NewCoord->y, NewCoord->x).Ball.Color = pModel->pStage->Lines(OldCoord->y, OldCoord->x).Ball.Color
	pModel->pStage->Lines(NewCoord->y, NewCoord->x).Ball.Visible = True
	
	Dim pts As POINT = Any
	pts.x = OldCoord->x
	pts.y = OldCoord->y
	pModel->Events.OnLinesChanged( _
		pModel->Context, _
		@pts, _
		1 _
	)
	
	Return True
	
End Function

Function CreateGameModel( _
		ByVal pStage As Stage Ptr, _
		ByVal pEvents As StageEvents Ptr, _
		ByVal Context As Any Ptr _
	)As GameModel Ptr
	
	Dim pModel As GameModel Ptr = Allocate(SizeOf(GameModel))
	If pModel = NULL Then
		Return NULL
	End If
	
	pModel->pStage = pStage
	
	pModel->Events = *pEvents
	pModel->Context = Context
	' pModel->Grid(9 * 9 - 1) = {0}
	pModel->SelectedCellX = 0
	pModel->SelectedCellY = 0
	pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Selected = True
	
	Return pModel
	
End Function

Sub DestroyGameModel( _
		ByVal pModel As GameModel Ptr _
	)
	
	Deallocate(pModel)
	
End Sub

Sub GameModelNewGame( _
		ByVal pModel As GameModel Ptr _
	)
	
	' Обнуление
	
	pModel->pStage->Score = 0
	pModel->Events.OnScoreChanged( _
		pModel->Context, _
		0 _
	)
	
	Dim pts(9 * 9 - 1) As POINT = Any
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			pModel->pStage->Lines(j, i).Ball.Frame = AnimationFrames.Stopped
			pModel->pStage->Lines(j, i).Ball.Visible = False
			pModel->pStage->Lines(j, i).Ball.Selected = False
			
			pts(j * 9 + i).x = i
			pts(j * 9 + i).y = j
		Next
	Next
	
	pModel->Events.OnLinesChanged( _
		pModel->Context, _
		@pts(0), _
		9 * 9 _
	)
	
	pModel->pStage->MovedBall.Frame = AnimationFrames.Stopped
	pModel->pStage->MovedBall.Visible = False
	
	pModel->Events.OnMovedBallChanged( _
		pModel->Context _
	)
	
	ExtractBalls(pModel)
	
	GenerateTablo(pModel)
	
End Sub

Function GameModelUpdate( _
		ByVal pModel As GameModel Ptr _
	)As Boolean
	
	Return False
	
End Function

Sub GameModelGetSelectedCell( _
		ByVal pModel As GameModel Ptr, _
		ByVal pCellCoord As POINT Ptr _
	)
	
	pCellCoord->x = pModel->SelectedCellX
	pCellCoord->y = pModel->SelectedCellY
	
End Sub

Sub GameModelMoveSelectionRectangle( _
		ByVal pModel As GameModel Ptr, _
		ByVal Direction As MoveSelectionRectangleDirection _
	)
	
	Dim pts(1) As POINT = Any
	pts(0).x = pModel->SelectedCellX
	pts(0).y = pModel->SelectedCellY
	
	pModel->pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Selected = False
	
	Select Case Direction
		
		Case MoveSelectionRectangleDirection.Left
			pModel->SelectedCellX -= 1
			If pModel->SelectedCellX < 0 Then
				pModel->SelectedCellX = 8
			End If
			
		Case MoveSelectionRectangleDirection.Up
			pModel->SelectedCellY -= 1
			If pModel->SelectedCellY < 0 Then
				pModel->SelectedCellY = 8
			End If
			
		Case MoveSelectionRectangleDirection.Right
			pModel->SelectedCellX += 1
			If pModel->SelectedCellX > 8 Then
				pModel->SelectedCellX = 0
			End If
			
		Case MoveSelectionRectangleDirection.Down
			pModel->SelectedCellY += 1
			If pModel->SelectedCellY > 8 Then
				pModel->SelectedCellY = 0
			End If
			
			' JumpNextLeft
			' JumpNextUp
			' JumpNextRight
			' JumpNextDown
			
		Case MoveSelectionRectangleDirection.JumpBeginLeft
			pModel->SelectedCellX = 0
			
		Case MoveSelectionRectangleDirection.JumpBeginUp
			pModel->SelectedCellY = 0
			
		Case MoveSelectionRectangleDirection.JumpEndRight
			pModel->SelectedCellY = 8
			
		Case MoveSelectionRectangleDirection.JumpEndDown
			pModel->SelectedCellX = 8
			
		Case MoveSelectionRectangleDirection.JumpBeginStage
			pModel->SelectedCellX = 0
			pModel->SelectedCellY = 0
			
		Case MoveSelectionRectangleDirection.JumpEndStage
			pModel->SelectedCellX = 8
			pModel->SelectedCellY = 8
			
	End Select
	
	pts(1).x = pModel->SelectedCellX
	pts(1).y = pModel->SelectedCellY
	
	pModel->pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Selected = True
	
	pModel->Events.OnLinesChanged( _
		pModel->Context, _
		@pts(0), _
		2 _
	)
	
End Sub
