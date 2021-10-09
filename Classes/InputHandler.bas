#include once "InputHandler.bi"

Type _InputHandler
	pStage As Stage Ptr
	pScene As Scene Ptr
	SelectedCellX As Integer
	SelectedCellY As Integer
	SelectedBallX As Integer
	SelectedBallY As Integer
	PressedCellX As Integer
	PressedCellY As Integer
End Type

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
				@pStage->Lines(j, i).PositionMatrix, _
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

Function CreateInputHandler( _
		ByVal pStage As Stage Ptr, _
		ByVal pScene As Scene Ptr _
	)As InputHandler Ptr
	
	Dim pHandler As InputHandler Ptr = Allocate(SizeOf(InputHandler))
	If pHandler = NULL Then
		Return NULL
	End If
	
	pHandler->pStage = pStage
	pHandler->pScene = pScene
	pHandler->SelectedCellX = 0
	pHandler->SelectedCellY = 0
	pHandler->SelectedBallX = 0
	pHandler->SelectedBallY = 0
	pHandler->PressedCellX = 0
	pHandler->PressedCellY = 0
	
	Return pHandler
	
End Function

Sub DestroyInputHandler( _
		ByVal pHandler As InputHandler Ptr _
	)
	
	Deallocate(pHandler)
	
End Sub

Sub InputHandlerLMouseDown( _
		ByVal pHandler As InputHandler Ptr, _
		ByVal pp As POINT Ptr _
	)
	
	Dim CellCoord As Point = Any
	If GetCellFromPoint(pHandler->pStage, pHandler->pScene, pp, @CellCoord) Then
		' Развыбрать старую ячейку
		Dim pts(1) As POINT = Any
		pts(0).x = pHandler->SelectedCellX
		pts(0).y = pHandler->SelectedCellY
		pHandler->pStage->Lines(pHandler->SelectedCellY, pHandler->SelectedCellX).Selected = False
		
		' Выбрать новую ячейку
		pHandler->SelectedCellX = CellCoord.x
		pHandler->SelectedCellY = CellCoord.y
		pHandler->pStage->Lines(pHandler->SelectedCellY, pHandler->SelectedCellX).Selected = True
		
		' Нажать кнопку
		pHandler->PressedCellX = CellCoord.x
		pHandler->PressedCellY = CellCoord.y
		pHandler->pStage->Lines(pHandler->PressedCellY, pHandler->PressedCellX).Pressed = True
		
		pts(1).x = CellCoord.x
		pts(1).y = CellCoord.y
		
		' pModel->Events.OnLinesChanged( _
			' pModel->Context, _
			' @pts(0), _
			' 2 _
		' )
		
	End If
	
End Sub

Sub InputHandlerLMouseUp( _
		ByVal pHandler As InputHandler Ptr, _
		ByVal pp As POINT Ptr _
	)
	
	Dim CellCoord As Point = Any
	If GetCellFromPoint(pHandler->pStage, pHandler->pScene, pp, @CellCoord) Then
		InputHandlerKeyUp( _
			pHandler, _
			VK_SPACE _
		)
	End If
	
End Sub

Sub InputHandlerKeyDown( _
		ByVal pHandler As InputHandler Ptr, _
		ByVal Key As Integer _
	)
	
	Select Case Key
		
		Case VK_TAB
			' Прыжок на следующий шар
			' Если Shift+TAB то на предыдущий шар
			' Ctrl+Стрелка переход к следующему шару
			' Home, End, Ctrl+Home, Ctrl+End, PageUp, PageDown
			
		Case VK_SPACE, VK_RETURN
			pHandler->PressedCellX = pHandler->SelectedCellX
			pHandler->PressedCellY = pHandler->SelectedCellY
			pHandler->pStage->Lines(pHandler->PressedCellY, pHandler->PressedCellX).Pressed = True
			
			Dim pts As POINT = Any
			pts.x = pHandler->PressedCellX
			pts.y = pHandler->PressedCellY
			' pModel->Events.OnLinesChanged( _
				' pModel->Context, _
				' @pts, _
				' 1 _
			' )
			
		Case VK_LEFT
			Dim pts(1) As POINT = Any
			pts(0).x = pHandler->SelectedCellX
			pts(0).y = pHandler->SelectedCellY
			
			pHandler->pStage->Lines(pHandler->SelectedCellY, pHandler->SelectedCellX).Selected = False
			
			pHandler->SelectedCellX -= 1
			If pHandler->SelectedCellX < 0 Then
				pHandler->SelectedCellX = 8
			End If
			pts(1).x = pHandler->SelectedCellX
			pts(1).y = pHandler->SelectedCellY
			
			pHandler->pStage->Lines(pHandler->SelectedCellY, pHandler->SelectedCellX).Selected = True
			
			' pModel->Events.OnLinesChanged( _
				' pModel->Context, _
				' @pts(0), _
				' 2 _
			' )
			
		Case VK_UP
			Dim pts(1) As POINT = Any
			pts(0).x = pHandler->SelectedCellX
			pts(0).y = pHandler->SelectedCellY
			
			pHandler->pStage->Lines(pHandler->SelectedCellY, pHandler->SelectedCellX).Selected = False
			
			pHandler->SelectedCellY -= 1
			If pHandler->SelectedCellY < 0 Then
				pHandler->SelectedCellY = 8
			End If
			pts(1).x = pHandler->SelectedCellX
			pts(1).y = pHandler->SelectedCellY
			
			pHandler->pStage->Lines(pHandler->SelectedCellY, pHandler->SelectedCellX).Selected = True
			
			' pModel->Events.OnLinesChanged( _
				' pModel->Context, _
				' @pts(0), _
				' 2 _
			' )
			
		Case VK_RIGHT
			Dim pts(1) As POINT = Any
			pts(0).x = pHandler->SelectedCellX
			pts(0).y = pHandler->SelectedCellY
			
			pHandler->pStage->Lines(pHandler->SelectedCellY, pHandler->SelectedCellX).Selected = False
			
			pHandler->SelectedCellX += 1
			If pHandler->SelectedCellX > 8 Then
				pHandler->SelectedCellX = 0
			End If
			pts(1).x = pHandler->SelectedCellX
			pts(1).y = pHandler->SelectedCellY
			
			pHandler->pStage->Lines(pHandler->SelectedCellY, pHandler->SelectedCellX).Selected = True
			
			' pModel->Events.OnLinesChanged( _
				' pModel->Context, _
				' @pts(0), _
				' 2 _
			' )
			
		Case VK_DOWN
			Dim pts(1) As POINT = Any
			pts(0).x = pHandler->SelectedCellX
			pts(0).y = pHandler->SelectedCellY
			
			pHandler->pStage->Lines(pHandler->SelectedCellY, pHandler->SelectedCellX).Selected = False
			
			pHandler->SelectedCellY += 1
			If pHandler->SelectedCellY > 8 Then
				pHandler->SelectedCellY = 0
			End If
			pts(1).x = pHandler->SelectedCellX
			pts(1).y = pHandler->SelectedCellY
			
			pHandler->pStage->Lines(pHandler->SelectedCellY, pHandler->SelectedCellX).Selected = True
			
			' pModel->Events.OnLinesChanged( _
				' pModel->Context, _
				' @pts(0), _
				' 2 _
			' )
			
		Case VK_ESCAPE
			' Снять выбор шара
			pHandler->pStage->Lines(pHandler->SelectedBallY, pHandler->SelectedBallX).Ball.Selected = False
			
			Dim pts As POINT = Any
			pts.x = pHandler->SelectedBallX
			pts.y = pHandler->SelectedBallY
			' pModel->Events.OnLinesChanged( _
				' pModel->Context, _
				' @pts, _
				' 1 _
			' )
			
	End Select
	
End Sub

Sub InputHandlerKeyUp( _
		ByVal pHandler As InputHandler Ptr, _
		ByVal Key As Integer _
	)
	
	Select Case Key
		
		Case VK_SPACE, VK_RETURN
			' Отпустить кнопку
			pHandler->pStage->Lines(pHandler->PressedCellY, pHandler->PressedCellX).Pressed = False
			
			' Если шар виден, то выбрать его
			If pHandler->pStage->Lines(pHandler->PressedCellY, pHandler->PressedCellX).Ball.Visible Then
				
				' Развыбрать старый шар
				pHandler->pStage->Lines(pHandler->SelectedBallY, pHandler->SelectedBallX).Ball.Selected = False
				
				Dim pts As POINT = Any
				pts.x = pHandler->SelectedBallX
				pts.y = pHandler->SelectedBallY
				' pModel->Events.OnLinesChanged( _
					' pModel->Context, _
					' @pts, _
					' 1 _
				' )
				
				' Выбрать новый шар
				pHandler->SelectedBallX = pHandler->PressedCellX
				pHandler->SelectedBallY = pHandler->PressedCellY
				pHandler->pStage->Lines(pHandler->SelectedBallY, pHandler->SelectedBallX).Ball.Selected = Not pHandler->pStage->Lines(pHandler->SelectedBallY, pHandler->SelectedBallX).Ball.Selected
				
			Else
				' Если есть выделенный шар
				' то переместить его на новое место
				Dim BallSelected As Boolean = pHandler->pStage->Lines(pHandler->SelectedBallY, pHandler->SelectedBallX).Ball.Selected
				Dim BallVisible As Boolean = pHandler->pStage->Lines(pHandler->SelectedBallY, pHandler->SelectedBallX).Ball.Visible
				If BallSelected AndAlso BallVisible Then
					
					Dim OldBallCoord As POINT = Any
					OldBallCoord.x = pHandler->SelectedBallX
					OldBallCoord.y = pHandler->SelectedBallY
					Dim NewBallCoord As POINT = Any
					NewBallCoord.x = pHandler->PressedCellX
					NewBallCoord.y = pHandler->PressedCellY
					
					' Dim Executed As Boolean = MoveBallCommandExecute( _
						' @pModel->Commands(pModel->CommandsIndex), _
						' pModel, _
						' @OldBallCoord, _
						' @NewBallCoord _
					' )
					
					' If Executed Then
						' pModel->CommandsIndex += 1
						' If pModel->CommandsIndex > COMMANDS_CAPACITY Then
							' Передвинуть
						' End If
					' Else
						' pModel->Events.OnPathNotExist( _
							' pModel->Context _
						' )
					' End If
				End If
			End If
			
			Dim pts As POINT = Any
			pts.x = pHandler->PressedCellX
			pts.y = pHandler->PressedCellY
			' pModel->Events.OnLinesChanged( _
				' pModel->Context, _
				' @pts, _
				' 1 _
			' )
			
	End Select
	
End Sub
