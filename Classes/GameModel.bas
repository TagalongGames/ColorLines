#include once "GameModel.bi"
#include once "GameAlgorithm.bi"
#include once "crt.bi"

/'
Type _MoveBallCommand
	' Шар
	BallCoord As SquareCoord
	' Новые координаты шара
	NewBallCoord As SquareCoord
	' Путь шара
	PathLength As Integer
	BallPath(9 * 9 - 1) As SquareCoord
	
	' Удалённые шары
	RemovedBallsCount As Integer
	RemovedBallsCoord(9 * 9 - 1) As SquareCoord
	RemovedBallsColor(9 * 9 - 1) As ColorBallKind
	
	' Шары, извлечённые из табла
	ExtractedBalls(2) As ColorBall
	
	' Удалённые шары после извлечения из табла
	RemovedBalls2Count As Integer
	RemovedBalls2Coord(9 * 9 - 1) As SquareCoord
	RemovedBalls2Color(9 * 9 - 1) As ColorBallKind
	
	' Старый счёт
	Score As Integer
	HiScore As Integer
	
End Type
'/

Type _GameModel
	pStage As Stage Ptr
	Events As StageEvents
	Context As Any Ptr
	Grid(9 * 9 - 1) As Integer
	SelectedCellX As Integer
	SelectedCellY As Integer
	SelectedBallX As Integer
	SelectedBallY As Integer
	PressedCellX As Integer
	PressedCellY As Integer
	Busy As Boolean
End Type

Function RemoveLines( _
		ByVal pModel As GameModel Ptr _
	)As Boolean
	
	Dim RemovedBalls(0 To 9 * 9 - 1) As SquareCoord = Any
	Dim RemovedBallsCount As Integer = 0
	
	' Строки
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			Dim Length As Integer = RowSequenceLength(pModel->pStage, i, j, pModel->pStage->Balls(j, i).Kind)
			If Length >= 5 Then
				For k As Integer = i To Length + i - 1
					RemovedBalls(RemovedBallsCount).x = k
					RemovedBalls(RemovedBallsCount).y = j
					RemovedBallsCount += 1
				Next
				i += Length
			End If
		Next
	Next
	' Столбцы
	For i As Integer = 0 To 8
		For j As Integer = 0 To 8
			Dim Length As Integer = ColSequenceLength(pModel->pStage, i, j, pModel->pStage->Balls(j, i).Kind)
			If Length >= 5 Then
				For k As Integer = j To Length + j - 1
					RemovedBalls(RemovedBallsCount).x = i
					RemovedBalls(RemovedBallsCount).y = k
					RemovedBallsCount += 1
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
			Dim Length As Integer = ForwardDiagonalSequenceLength(pModel->pStage, i, j, pModel->pStage->Balls(j, i).Kind)
			If Length >= 5 Then
				For k As Integer = 0 To Length - 1
					RemovedBalls(RemovedBallsCount).x = i + k
					RemovedBalls(RemovedBallsCount).y = j + k
					RemovedBallsCount += 1
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
			Dim Length As Integer = ForwardDiagonalSequenceLength(pModel->pStage, i, j, pModel->pStage->Balls(j, i).Kind)
			If Length >= 5 Then
				For k As Integer = 0 To Length - 1
					RemovedBalls(RemovedBallsCount).x = i + k
					RemovedBalls(RemovedBallsCount).y = j + k
					RemovedBallsCount += 1
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
			Dim Length As Integer = BackwardDiagonalSequenceLength(pModel->pStage, i, j, pModel->pStage->Balls(j, i).Kind)
			If Length >= 5 Then
				For k As Integer = 0 To Length - 1
					RemovedBalls(RemovedBallsCount).x = i - k
					RemovedBalls(RemovedBallsCount).y = j + k
					RemovedBallsCount += 1
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
			Dim Length As Integer = BackwardDiagonalSequenceLength(pModel->pStage, i, j, pModel->pStage->Balls(j, i).Kind)
			If Length >= 5 Then
				For k As Integer = 0 To Length - 1
					RemovedBalls(RemovedBallsCount).x = i - k
					RemovedBalls(RemovedBallsCount).y = j + k
					RemovedBallsCount += 1
				Next
				i -= Length
				j += Length
			Else
				i -= 1
				j += 1
			End If
		Loop
	Next
	
	If RemovedBallsCount = 0 Then
		Return False
	End If
	
	For i As Integer = 0 To RemovedBallsCount - 1
		pModel->pStage->Balls(RemovedBalls(i).y, RemovedBalls(i).x).Visible = False
	Next
	
	pModel->Events.OnLinesChanged( _
		pModel->Context, _
		@RemovedBalls(0), _
		RemovedBallsCount _
	)
	
	pModel->pStage->Score += RemovedBallsCount
	pModel->Events.OnScoreChanged( _
		pModel->Context, _
		RemovedBallsCount _
	)
	
	If pModel->pStage->Score > pModel->pStage->HiScore Then
		pModel->pStage->HiScore = pModel->pStage->Score
		pModel->Events.OnHiScoreChanged( _
			pModel->Context, _
			RemovedBallsCount _
		)
	End If
	
	Return True
	
End Function

Sub GenerateTablo( _
		ByVal pModel As GameModel Ptr _
	)
	
	For i As Integer = 0 To 2
		Dim RandomColor As ColorBallKind = GenerateRandomColorBallKind()
		pModel->pStage->TabloBalls(i).Kind = RandomColor
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
		Dim pt As SquareCoord = Any
		Dim NotEmpty As Boolean = StageGetRandomEmptyCellCoord( _
			pModel->pStage, _
			@pt _
		)
		If NotEmpty Then
			
			Dim RandomColor As ColorBallKind = pModel->pStage->TabloBalls(i).Kind
			
			/'
			Dim buffer As WString * (255 + 1) = Any
			Const ffFormat = WStr("{%d, %d}, %d")
			swprintf(@buffer, @ffFormat, x, y, RandomColor)
			buffer[255] = 0
			MessageBoxW(NULL, @buffer, NULL, MB_OK)
			'/
			
			' Поместить на игровое поле
			pModel->pStage->Balls(pt.y, pt.x).Kind = RandomColor
			pModel->pStage->Balls(pt.y, pt.x).Frame = AnimationFrames.Birth0
			pModel->pStage->Balls(pt.y, pt.x).Visible = True
			
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
		ByVal pOldCoord As SquareCoord Ptr, _
		ByVal pNewCoord As SquareCoord Ptr, _
		ByVal pPath As SquareCoord Ptr, _
		ByVal pPathLength As Integer Ptr _
	)As Boolean
	
	Scope
		For j As Integer = 0 To 8
			For i As Integer = 0 To 8
				If pModel->pStage->Balls(j, i).Visible Then
					pModel->Grid(j * 9 + i) = SquareLType.Wall
				Else
					pModel->Grid(j * 9 + i) = SquareLType.Blank
				End If
			Next
		Next
		pModel->Grid(pOldCoord->y * 9 + pOldCoord->x) = SquareLType.Start
	End Scope
	
	' Получить путь
	Dim PathLength As Integer = GetLeePath( _
		pOldCoord, _
		pNewCoord, _
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
	pModel->pStage->Balls(pOldCoord->y, pOldCoord->x).Visible = False
	pModel->pStage->Balls(pNewCoord->y, pNewCoord->x).Kind = pModel->pStage->Balls(pOldCoord->y, pOldCoord->x).Kind
	pModel->pStage->Balls(pNewCoord->y, pNewCoord->x).Visible = True
	
	Dim pts As SquareCoord = Any
	pts.x = pOldCoord->x
	pts.y = pOldCoord->y
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
	pModel->SelectedBallX = 0
	pModel->SelectedBallY = 0
	pModel->PressedCellX = 0
	pModel->PressedCellY = 0
	pModel->Busy = False
	
	pStage->Cells(pModel->SelectedCellY, pModel->SelectedCellX).Selected = True
	
	Return pModel
	
End Function

Sub DestroyGameModel( _
		ByVal pModel As GameModel Ptr _
	)
	
	Deallocate(pModel)
	
End Sub

Function GameModelIsBusy( _
		ByVal pModel As GameModel Ptr _
	)As Boolean
	
	Return pModel->Busy
	
End Function

Sub GameModelNewGame( _
		ByVal pModel As GameModel Ptr _
	)
	
	pModel->Busy = True
	
	pModel->pStage->Score = 0
	pModel->Events.OnScoreChanged( _
		pModel->Context, _
		0 _
	)
	
	Dim pts(9 * 9 - 1) As SquareCoord = Any
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			pModel->pStage->Balls(j, i).Frame = AnimationFrames.Stopped
			pModel->pStage->Balls(j, i).Visible = False
			pModel->pStage->Balls(j, i).Selected = False
			
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
	
	pModel->Busy = False
	
End Sub

Function GameModelUpdate( _
		ByVal pModel As GameModel Ptr _
	)As Boolean
	
	pModel->Busy = True
	
	pModel->Busy = False
	
	Return False
	
End Function

Sub GameModelGetSelectedCell( _
		ByVal pModel As GameModel Ptr, _
		ByVal pCellCoord As SquareCoord Ptr _
	)
	
	pCellCoord->x = pModel->SelectedCellX
	pCellCoord->y = pModel->SelectedCellY
	
End Sub

Sub GameModelGetSelectedBall( _
		ByVal pModel As GameModel Ptr, _
		ByVal pBallCoord As SquareCoord Ptr _
	)
	
	pBallCoord->x = pModel->SelectedBallX
	pBallCoord->y = pModel->SelectedBallY
	
End Sub

Sub GameModelGetPressedCell( _
		ByVal pModel As GameModel Ptr, _
		ByVal pPressedCellCoord As SquareCoord Ptr _
	)
	
	pPressedCellCoord->x = pModel->PressedCellX
	pPressedCellCoord->y = pModel->PressedCellY
	
End Sub

Sub GameModelMoveSelectionRectangle( _
		ByVal pModel As GameModel Ptr, _
		ByVal Direction As MoveSelectionRectangleDirection _
	)
	
	pModel->Busy = True
	
	Dim pts(2) As SquareCoord = Any
	
	pts(0).x = pModel->PressedCellX
	pts(0).y = pModel->PressedCellY
	pModel->pStage->Cells(pModel->PressedCellY, pModel->PressedCellX).Pressed = False
	
	pts(1).x = pModel->SelectedCellX
	pts(1).y = pModel->SelectedCellY
	pModel->pStage->Cells(pModel->SelectedCellY, pModel->SelectedCellX).Selected = False
	
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
			pModel->SelectedCellX = 8
			
		Case MoveSelectionRectangleDirection.JumpEndDown
			pModel->SelectedCellY = 8
			
		Case MoveSelectionRectangleDirection.JumpBeginStage
			pModel->SelectedCellX = 0
			pModel->SelectedCellY = 0
			
		Case MoveSelectionRectangleDirection.JumpEndStage
			pModel->SelectedCellX = 8
			pModel->SelectedCellY = 8
			
	End Select
	
	pts(2).x = pModel->SelectedCellX
	pts(2).y = pModel->SelectedCellY
	pModel->pStage->Cells(pModel->SelectedCellY, pModel->SelectedCellX).Selected = True
	
	pModel->Events.OnLinesChanged( _
		pModel->Context, _
		@pts(0), _
		3 _
	)
	
	pModel->Busy = False
	
End Sub

Sub GameModelMoveSelectionRectangleTo( _
		ByVal pModel As GameModel Ptr, _
		ByVal pCellCoord As SquareCoord Ptr _
	)
	
	pModel->Busy = True
	
	Dim pts(2) As SquareCoord = Any
	
	pts(0).x = pModel->PressedCellX
	pts(0).y = pModel->PressedCellY
	pModel->pStage->Cells(pModel->PressedCellY, pModel->PressedCellX).Pressed = False
	
	pts(1).x = pModel->SelectedCellX
	pts(1).y = pModel->SelectedCellY
	pModel->pStage->Cells(pModel->SelectedCellY, pModel->SelectedCellX).Selected = False
	
	pModel->SelectedCellX = pCellCoord->x
	pModel->SelectedCellY = pCellCoord->y
	
	pts(2).x = pModel->SelectedCellX
	pts(2).y = pModel->SelectedCellY
	pModel->pStage->Cells(pModel->SelectedCellY, pModel->SelectedCellX).Selected = True
	
	pModel->Events.OnLinesChanged( _
		pModel->Context, _
		@pts(0), _
		3 _
	)
	
	pModel->Busy = False
	
End Sub

Sub GameModelSelectBall( _
		ByVal pModel As GameModel Ptr, _
		ByVal pBallCoord As SquareCoord Ptr _
	)
	pModel->SelectedBallY = pBallCoord->X
	pModel->SelectedBallX = pBallCoord->Y
	
	Dim Selected As Boolean = pModel->pStage->Cells(pModel->SelectedBallY, pModel->SelectedBallX).Selected
	If Selected = False Then
		pModel->Busy = True
		
		pModel->pStage->Balls(pModel->SelectedBallY, pModel->SelectedBallX).Selected = True
		
		Dim pts As SquareCoord = Any
		pts.x = pModel->SelectedBallX
		pts.y = pModel->SelectedBallY
		
		pModel->Events.OnLinesChanged( _
			pModel->Context, _
			@pts, _
			1 _
		)
		
		pModel->Busy = False
		
	End If
	
End Sub

Sub GameModelDeselectBall( _
		ByVal pModel As GameModel Ptr _
	)
	
	Dim Selected As Boolean = pModel->pStage->Balls(pModel->SelectedBallY, pModel->SelectedBallX).Selected
	
	If Selected Then
		
		pModel->Busy = True
		
		Dim pts As SquareCoord = Any
		pts.x = pModel->SelectedBallX
		pts.y = pModel->SelectedBallY
		pModel->pStage->Balls(pModel->SelectedBallY, pModel->SelectedBallX).Selected = False
		
		pModel->Events.OnLinesChanged( _
			pModel->Context, _
			@pts, _
			1 _
		)
		
		pModel->Busy = False
		
	End If
	
End Sub

Sub GameModelPushCell( _
		ByVal pModel As GameModel Ptr, _
		ByVal pPushCellCoord As SquareCoord Ptr _
	)
	
	pModel->Busy = True
	
	Dim pts(2) As SquareCoord = Any
	
	pts(0).x = pModel->PressedCellX
	pts(0).y = pModel->PressedCellY
	pModel->pStage->Cells(pModel->PressedCellY, pModel->PressedCellX).Pressed = False
	
	pModel->PressedCellX = pPushCellCoord->x
	pModel->PressedCellY = pPushCellCoord->y
	
	pts(1).x = pModel->PressedCellX
	pts(1).y = pModel->PressedCellY
	pModel->pStage->Cells(pModel->PressedCellY, pModel->PressedCellX).Pressed = True
	
	pts(2).x = pModel->SelectedCellX
	pts(2).y = pModel->SelectedCellY
	pModel->pStage->Cells(pModel->SelectedCellY, pModel->SelectedCellX).Selected = False
	
	pModel->SelectedCellX = pPushCellCoord->x
	pModel->SelectedCellY = pPushCellCoord->y
	pModel->pStage->Cells(pModel->SelectedCellY, pModel->SelectedCellX).Selected = True
	
	pModel->Events.OnLinesChanged( _
		pModel->Context, _
		@pts(0), _
		3 _
	)
	
	pModel->Busy = False
	
End Sub

Sub GameModelUnPushCell( _
		ByVal pModel As GameModel Ptr _
	)
	
	pModel->Busy = True
	
	Dim pts As SquareCoord = Any
	pts.x = pModel->PressedCellX
	pts.y = pModel->PressedCellY
	pModel->pStage->Cells(pModel->PressedCellY, pModel->PressedCellX).Pressed = False
	
	pModel->Events.OnLinesChanged( _
		pModel->Context, _
		@pts, _
		1 _
	)
	
	pModel->Busy = False
	
End Sub

Sub GameModelPullCell( _
		ByVal pModel As GameModel Ptr _
	)
	
	pModel->Busy = True
	
	Dim pts(2) As SquareCoord = Any
	pts(0).x = pModel->PressedCellX
	pts(0).y = pModel->PressedCellY
	pModel->pStage->Cells(pModel->PressedCellY, pModel->PressedCellX).Pressed = False
	
	pts(1).x = pModel->SelectedCellX
	pts(1).y = pModel->SelectedCellY
	pModel->pStage->Cells(pModel->SelectedCellY, pModel->SelectedCellX).Selected = False
	
	pModel->SelectedCellX = pModel->PressedCellX
	pModel->SelectedCellY = pModel->PressedCellY
	pts(2).x = pModel->SelectedCellX
	pts(2).y = pModel->SelectedCellY
	pModel->pStage->Cells(pModel->SelectedCellY, pModel->SelectedCellX).Selected = True
	
	pModel->Events.OnLinesChanged( _
		pModel->Context, _
		@pts(0), _
		3 _
	)
	
	Dim BallVisible As Boolean = pModel->pStage->Balls(pModel->PressedCellY, pModel->PressedCellX).Visible
	
	If BallVisible Then
		
		Dim pts2(1) As SquareCoord = Any
		
		pts2(0).x = pModel->SelectedBallX
		pts2(0).y = pModel->SelectedBallY
		pModel->pStage->Balls(pModel->SelectedBallY, pModel->SelectedBallX).Selected = False
		
		pModel->SelectedBallX = pModel->PressedCellX
		pModel->SelectedBallY = pModel->PressedCellY
		
		pts2(1).x = pModel->SelectedBallX
		pts2(1).y = pModel->SelectedBallY
		pModel->pStage->Balls(pModel->SelectedBallY, pModel->SelectedBallX).Selected = True
		
		pModel->Events.OnLinesChanged( _
			pModel->Context, _
			@pts2(0), _
			2 _
		)
		
	Else
		' Если есть выделенный шар
		' то переместить его на новое место
		Dim OldBallSelected As Boolean = pModel->pStage->Balls(pModel->SelectedBallY, pModel->SelectedBallX).Selected
		Dim OldBallVisible As Boolean = pModel->pStage->Balls(pModel->SelectedBallY, pModel->SelectedBallX).Visible
		
		If OldBallSelected AndAlso OldBallVisible Then
			
			Dim OldBallCoord As SquareCoord = Any
			OldBallCoord.x = pModel->SelectedBallX
			OldBallCoord.y = pModel->SelectedBallY
			
			Dim NewBallCoord As SquareCoord = Any
			NewBallCoord.x = pModel->PressedCellX
			NewBallCoord.y = pModel->PressedCellY
			
			' Dim IsBallMoved As Boolean = MoveBall( _
				' pModel, _
				' @OldBallCoord, _
				' @NewBallCoord, _
				' @pMoveCommand->BallPath(0), _
				' @pMoveCommand->PathLength _
			' )
			
			' If IsBallMoved Then
				' If RemoveLines(pModel, pStage) = False Then
					' If ExtractBalls(pModel, pStage) Then
						' GenerateTablo(pModel, pStage)
						' RemoveLines(pModel, pStage)
					' End If
				' End If
				
				' pModel->pStage->Balls(pModel->SelectedBallY, pModel->SelectedBallX).Selected = False
				
			' End If
			
		End If
		
	End If
	
	pModel->Busy = False
	
End Sub

Sub GameModelUnPullCell( _
		ByVal pModel As GameModel Ptr _
	)
	
	pModel->Busy = True
	
	pModel->Busy = False
	
End Sub
