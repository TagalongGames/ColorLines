#include once "GameModel.bi"
#include once "crt.bi"

Enum StageKeys
	Tab
	ShiftTab
	KeyReturn
	Left
	Up
	Right
	Down
	Escape
End Enum

Type _GameModel
	Events As StageEvents
	Context As Any Ptr
	SelectedCellX As Integer
	SelectedCellY As Integer
	SelectedBallX As Integer
	SelectedBallY As Integer
	PressedCellX As Integer
	PressedCellY As Integer
End Type

Function RowSequenceLength( _
		ByVal pStage As Stage Ptr, _
		ByVal X As Integer, _
		ByVal Y As Integer, _
		ByVal BallColor As BallColors _
	)As Integer
	
	If X > 8 Then
		Return 0
	End If
	
	If pStage->Lines(Y, X).Ball.Visible = False Then
		Return 0
	End If
	
	If pStage->Lines(Y, X).Ball.Color <> BallColor Then
		Return 0
	End If
	
	Return 1 + RowSequenceLength(pStage, X + 1, Y, BallColor)
	
End Function

Function ColSequenceLength( _
		ByVal pStage As Stage Ptr, _
		ByVal X As Integer, _
		ByVal Y As Integer, _
		ByVal BallColor As BallColors _
	)As Integer
	
	If Y > 8 Then
		Return 0
	End If
	
	If pStage->Lines(Y, X).Ball.Visible = False Then
		Return 0
	End If
	
	If pStage->Lines(Y, X).Ball.Color <> BallColor Then
		Return 0
	End If
	
	Return 1 + ColSequenceLength(pStage, X, Y + 1, BallColor)
	
End Function

Function ForwardDiagonalSequenceLength( _
		ByVal pStage As Stage Ptr, _
		ByVal X As Integer, _
		ByVal Y As Integer, _
		ByVal BallColor As BallColors _
	)As Integer
	
	If Y > 8 Then
		Return 0
	End If
	
	If X > 8 Then
		Return 0
	End If
	
	If pStage->Lines(Y, X).Ball.Visible = False Then
		Return 0
	End If
	
	If pStage->Lines(Y, X).Ball.Color <> BallColor Then
		Return 0
	End If
	
	Return 1 + ForwardDiagonalSequenceLength(pStage, X + 1, Y + 1, BallColor)
	
End Function

Function BackwardDiagonalSequenceLength( _
		ByVal pStage As Stage Ptr, _
		ByVal X As Integer, _
		ByVal Y As Integer, _
		ByVal BallColor As BallColors _
	)As Integer
	
	If Y > 8 Then
		Return 0
	End If
	
	If X < 0 Then
		Return 0
	End If
	
	If pStage->Lines(Y, X).Ball.Visible = False Then
		Return 0
	End If
	
	If pStage->Lines(Y, X).Ball.Color <> BallColor Then
		Return 0
	End If
	
	Return 1 + BackwardDiagonalSequenceLength(pStage, X - 1, Y + 1, BallColor)
	
End Function

Function RemoveLines( _
		ByVal pModel As GameModel Ptr, _
		ByVal pStage As Stage Ptr _
	)As Boolean
	
	' Cписок удаляемых ячеек
	Dim RemovedCells(0 To 9 * 9 - 1) As POINT = Any
	Dim RemovedCellsCount As Integer = 0
	
	' Строки
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			Dim Length As Integer = RowSequenceLength(pStage, i, j, pStage->Lines(j, i).Ball.Color)
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
			Dim Length As Integer = ColSequenceLength(pStage, i, j, pStage->Lines(j, i).Ball.Color)
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
			Dim Length As Integer = ForwardDiagonalSequenceLength(pStage, i, j, pStage->Lines(j, i).Ball.Color)
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
		Dim i As Integer = 0
		Dim j As Integer = t
		Do While (i <= 8) OrElse (j <= 8)
			Dim Length As Integer = ForwardDiagonalSequenceLength(pStage, i, j, pStage->Lines(j, i).Ball.Color)
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
			Dim Length As Integer = BackwardDiagonalSequenceLength(pStage, i, j, pStage->Lines(j, i).Ball.Color)
			If Length >= 5 Then
				For k As Integer = 0 To Length - 1
					RemovedCells(RemovedCellsCount).x = i + k
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
			Dim Length As Integer = BackwardDiagonalSequenceLength(pStage, i, j, pStage->Lines(j, i).Ball.Color)
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
		pStage->Lines(RemovedCells(i).y, RemovedCells(i).x).Ball.Visible = False
	Next
	
	pModel->Events.OnLinesChanged( _
		pModel->Context, _
		@RemovedCells(0), _
		RemovedCellsCount _
	)
	
	Return True
	
End Function

Sub GenerateTablo( _
		ByVal pModel As GameModel Ptr, _
		ByVal pStage As Stage Ptr _
	)
	
	For i As Integer = 0 To 2
		Dim RandomColor As BallColors = GetRandomBallColor()
		pStage->Tablo(i).Ball.Color = RandomColor
	Next
	
	pModel->Events.OnTabloChanged( _
		pModel->Context _
	)
	
End Sub

Function ExtractBalls( _
		ByVal pModel As GameModel Ptr, _
		ByVal pStage As Stage Ptr _
	)As Boolean
	
	Dim ExtractCount As Integer = 0
	
	For i As Integer = 0 To 2
		' Выбрать случайную свободную ячейку
		' Если пустых нет, то вернуть ошибку
		Dim pt As POINT = Any
		Dim NotEmpty As Boolean = StageGetRandomEmptyCellCoord(pStage, @pt)
		
		If NotEmpty Then
			
			Dim RandomColor As BallColors = pStage->Tablo(i).Ball.Color
			
			/'
			Dim buffer As WString * (255 + 1) = Any
			Const ffFormat = WStr("{%d, %d}, %d")
			swprintf(@buffer, @ffFormat, x, y, RandomColor)
			buffer[255] = 0
			MessageBoxW(NULL, @buffer, NULL, MB_OK)
			'/
			
			' Поместить на игровое поле
			pStage->Lines(pt.y, pt.x).Ball.Color = RandomColor
			pStage->Lines(pt.y, pt.x).Ball.Frame = AnimationFrames.Birth0
			pStage->Lines(pt.y, pt.x).Ball.Visible = True
			
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
		ByVal pStage As Stage Ptr, _
		ByVal OldCoord As POINT Ptr, _
		ByVal NewCoord As POINT Ptr _
	)As Boolean
	
	' Проверить наличие пути
	
	' Переместить шар
	pStage->Lines(OldCoord->y, OldCoord->x).Ball.Visible = False
	pStage->Lines(NewCoord->y, NewCoord->x).Ball.Color = pStage->Lines(OldCoord->y, OldCoord->x).Ball.Color
	pStage->Lines(NewCoord->y, NewCoord->x).Ball.Visible = True
	
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
		ByVal pEvents As StageEvents Ptr, _
		ByVal Context As Any Ptr _
	)As GameModel Ptr
	
	Dim pModel As GameModel Ptr = Allocate(SizeOf(GameModel))
	If pModel = NULL Then
		Return NULL
	End If
	
	pModel->Events = *pEvents
	pModel->Context = Context
	pModel->SelectedCellX = 0
	pModel->SelectedCellY = 0
	pModel->SelectedBallX = 0
	pModel->SelectedBallY = 0
	pModel->PressedCellX = 0
	pModel->PressedCellY = 0
	
	Return pModel
	
End Function

Sub DestroyGameModel( _
		ByVal pModel As GameModel Ptr _
	)
	
	Deallocate(pModel)
	
End Sub

Sub GameModelNewGame( _
		ByVal pModel As GameModel Ptr, _
		ByVal pStage As Stage Ptr _
	)
	
	' Обнуление
	
	pStage->Score = 0
	pModel->Events.OnScoreChanged( _
		pModel->Context _
	)
	
	Dim pts(9 * 9 - 1) As POINT = Any
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			pStage->Lines(j, i).Ball.Frame = AnimationFrames.Stopped
			pStage->Lines(j, i).Ball.Visible = False
			pStage->Lines(j, i).Ball.Selected = False
			
			pts(j * 9 + i).x = i
			pts(j * 9 + i).y = j
		Next
	Next
	
	pModel->Events.OnLinesChanged( _
		pModel->Context, _
		@pts(0), _
		9 * 9 _
	)
	
	pStage->MovedBall.Frame = AnimationFrames.Stopped
	pStage->MovedBall.Visible = False
	
	pModel->Events.OnMovedBallChanged( _
		pModel->Context _
	)
	
	ExtractBalls(pModel, pStage)
	
	GenerateTablo(pModel, pStage)
	
End Sub

Function GetCellFromPoint( _
		ByVal pStage As Stage Ptr, _
		ByVal pScene As Scene Ptr, _
		ByVal pp As POINT Ptr, _
		ByVal ppCell As POINT Ptr _
	)As Boolean
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			Dim ScreenRectangle As RECT = Any
			SceneTranslateBounds( _
				pScene, _
				@pStage->Lines(j, i).Bounds, _
				@pStage->Lines(j, i).Position, _
				@ScreenRectangle _
			)
			If PtInRect(@ScreenRectangle, *pp) Then
				ppCell->x = i
				ppCell->y = j
				Return True
			End If
		Next
	Next
	
	Return False
	
End Function

Sub GameModelLMouseDown( _
		ByVal pModel As GameModel Ptr, _
		ByVal pStage As Stage Ptr, _
		ByVal pScene As Scene Ptr, _
		ByVal pp As POINT Ptr _
	)
	
	Dim CellCoord As Point = Any
	If GetCellFromPoint(pStage, pScene, pp, @CellCoord) Then
		' Хорошо
		' Dim buffer As WString * (512 + 1) = Any
		' Const ffFormat = WStr("{%d, %d}")
		' swprintf(@buffer, @ffFormat, CellCoord.x, CellCoord.y)
		' buffer[255] = 0
		' MessageBoxW(NULL, @buffer, NULL, MB_OK)
	End If
	
End Sub

Sub GameModelKeyDown( _
		ByVal pModel As GameModel Ptr, _
		ByVal pStage As Stage Ptr, _
		ByVal Key As Integer _
	)
	
	Select Case Key
		
		Case VK_TAB
			' Прыжок на следующий шар
			
		Case StageKeys.ShiftTab
			' Если Shift+TAB то на предыдущий шар
			
		Case VK_SPACE, VK_RETURN
			pModel->PressedCellX = pModel->SelectedCellX
			pModel->PressedCellY = pModel->SelectedCellY
			pStage->Lines(pModel->PressedCellY, pModel->PressedCellX).Pressed = True
			
			Dim pts As POINT = Any
			pts.x = pModel->PressedCellX
			pts.y = pModel->PressedCellY
			pModel->Events.OnLinesChanged( _
				pModel->Context, _
				@pts, _
				1 _
			)
			
		Case VK_LEFT
			Dim pts(1) As POINT = Any
			pts(0).x = pModel->SelectedCellX
			pts(0).y = pModel->SelectedCellY
			
			pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Selected = False
			
			pModel->SelectedCellX -= 1
			If pModel->SelectedCellX < 0 Then
				pModel->SelectedCellX = 8
			End If
			pts(1).x = pModel->SelectedCellX
			pts(1).y = pModel->SelectedCellY
			
			pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Selected = True
			
			pModel->Events.OnLinesChanged( _
				pModel->Context, _
				@pts(0), _
				2 _
			)
			
		Case VK_UP
			Dim pts(1) As POINT = Any
			pts(0).x = pModel->SelectedCellX
			pts(0).y = pModel->SelectedCellY
			
			pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Selected = False
			
			pModel->SelectedCellY -= 1
			If pModel->SelectedCellY < 0 Then
				pModel->SelectedCellY = 8
			End If
			pts(1).x = pModel->SelectedCellX
			pts(1).y = pModel->SelectedCellY
			
			pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Selected = True
			
			pModel->Events.OnLinesChanged( _
				pModel->Context, _
				@pts(0), _
				2 _
			)
			
		Case VK_RIGHT
			Dim pts(1) As POINT = Any
			pts(0).x = pModel->SelectedCellX
			pts(0).y = pModel->SelectedCellY
			
			pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Selected = False
			
			pModel->SelectedCellX += 1
			If pModel->SelectedCellX > 8 Then
				pModel->SelectedCellX = 0
			End If
			pts(1).x = pModel->SelectedCellX
			pts(1).y = pModel->SelectedCellY
			
			pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Selected = True
			
			pModel->Events.OnLinesChanged( _
				pModel->Context, _
				@pts(0), _
				2 _
			)
			
		Case VK_DOWN
			Dim pts(1) As POINT = Any
			pts(0).x = pModel->SelectedCellX
			pts(0).y = pModel->SelectedCellY
			
			pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Selected = False
			
			pModel->SelectedCellY += 1
			If pModel->SelectedCellY > 8 Then
				pModel->SelectedCellY = 0
			End If
			pts(1).x = pModel->SelectedCellX
			pts(1).y = pModel->SelectedCellY
			
			pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Selected = True
			
			pModel->Events.OnLinesChanged( _
				pModel->Context, _
				@pts(0), _
				2 _
			)
			
		Case VK_ESCAPE
			' Снять выбор шара
			If pStage->Lines(pModel->SelectedBallY, pModel->SelectedBallX).Ball.Selected Then
				pStage->Lines(pModel->SelectedBallY, pModel->SelectedBallX).Ball.Selected = False
				
				Dim pts As POINT = Any
				pts.x = pModel->SelectedBallX
				pts.y = pModel->SelectedBallY
				pModel->Events.OnLinesChanged( _
					pModel->Context, _
					@pts, _
					1 _
				)
			End If
			
	End Select
	
End Sub

Sub GameModelKeyUp( _
		ByVal pModel As GameModel Ptr, _
		ByVal pStage As Stage Ptr, _
		ByVal Key As Integer _
	)
	
	Select Case Key
		
		Case VK_SPACE, VK_RETURN
			' Отпустить кнопку
			pStage->Lines(pModel->PressedCellY, pModel->PressedCellX).Pressed = False
			
			' Если шар виден, то выбрать его
			If pStage->Lines(pModel->PressedCellY, pModel->PressedCellX).Ball.Visible Then
				
				' Выбрать или снять выбор шара
				pStage->Lines(pModel->PressedCellY, pModel->PressedCellX).Ball.Selected = Not pStage->Lines(pModel->PressedCellY, pModel->PressedCellX).Ball.Selected
				
				pModel->SelectedBallX = pModel->PressedCellX
				pModel->SelectedBallY = pModel->PressedCellY
				
			Else
				' Если есть выделенный шар
				' то переместить его на новое место
				If pStage->Lines(pModel->SelectedBallY, pModel->SelectedBallX).Ball.Selected AndAlso pStage->Lines(pModel->SelectedBallY, pModel->SelectedBallX).Ball.Visible Then
					
					' Переместить шар
					Dim OldCoord As POINT = Any
					OldCoord.x = pModel->SelectedBallX
					OldCoord.y = pModel->SelectedBallY
					Dim NewCoord As POINT = Any
					NewCoord.x = pModel->PressedCellX
					NewCoord.y = pModel->PressedCellY
					
					If MoveBall(pModel, pStage, @OldCoord, @NewCoord) Then
						If RemoveLines(pModel, pStage) = False Then
							If ExtractBalls(pModel, pStage) Then
								GenerateTablo(pModel, pStage)
								RemoveLines(pModel, pStage)
							End If
						End If
						
						pStage->Lines(pModel->SelectedBallY, pModel->SelectedBallX).Ball.Selected = False
					End If
				End If
			End If
			
			Dim pts As POINT = Any
			pts.x = pModel->PressedCellX
			pts.y = pModel->PressedCellY
			pModel->Events.OnLinesChanged( _
				pModel->Context, _
				@pts, _
				1 _
			)
			
	End Select
	
End Sub

Function GameModelUpdate( _
		ByVal pModel As GameModel Ptr, _
		ByVal pStage As Stage Ptr _
	)As Boolean
	
	Return False
	
End Function

Function GameModelCommand( _
		ByVal pModel As GameModel Ptr, _
		ByVal pStage As Stage Ptr, _
		ByVal cmd As StageCommands _
	)As Boolean
	
	Return False
	
End Function
