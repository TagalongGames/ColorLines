#include once "InputHandler.bi"
#include once "CreateInstance.bi"
#include once "DeselectBallCommand.bi"
#include once "EmptyCommand.bi"
#include once "MoveSelectionRectangleCommand.bi"
#include once "PullCellCommand.bi"
#include once "PushCellCommand.bi"
#include once "crt.bi"

Type _InputHandler
	pStage As Stage Ptr
	pScene As Scene Ptr
	pModel As GameModel Ptr
	pEmptyCommand As ICommand Ptr
End Type

Function GetDirection( _
		ByVal KeyCode As Integer _
	)As MoveSelectionRectangleDirection
	
	Select Case KeyCode
		
		Case VK_TAB
			Dim ShiftKeyState As Short = GetKeyState(VK_SHIFT)
			Dim ShiftKeyPressed As Boolean = HIBYTE(ShiftKeyState)
			If ShiftKeyPressed = 0 Then
				Return MoveSelectionRectangleDirection.JumpNextRight
			Else
				Return MoveSelectionRectangleDirection.JumpNextLeft
			End If
			
		Case VK_LEFT
			Dim ControlKeyState As Short = GetKeyState(VK_CONTROL)
			Dim ControlPressed As Boolean = HIBYTE(ControlKeyState)
			If ControlPressed = 0 Then
				Return MoveSelectionRectangleDirection.Left
			Else
				Return MoveSelectionRectangleDirection.JumpNextLeft
			End If
			
		Case VK_UP
			Dim ControlKeyState As Short = GetKeyState(VK_CONTROL)
			Dim ControlPressed As Boolean = HIBYTE(ControlKeyState)
			If ControlPressed = 0 Then
				Return MoveSelectionRectangleDirection.Up
			Else
				Return MoveSelectionRectangleDirection.JumpNextUp
			End If
			
		Case VK_RIGHT
			Dim ControlKeyState As Short = GetKeyState(VK_CONTROL)
			Dim ControlPressed As Boolean = HIBYTE(ControlKeyState)
			If ControlPressed = 0 Then
				Return MoveSelectionRectangleDirection.Right
			Else
				Return MoveSelectionRectangleDirection.JumpNextRight
			End If
			
		Case VK_DOWN
			Dim ControlKeyState As Short = GetKeyState(VK_CONTROL)
			Dim ControlPressed As Boolean = HIBYTE(ControlKeyState)
			If ControlPressed = 0 Then
				Return MoveSelectionRectangleDirection.Down
			Else
				Return MoveSelectionRectangleDirection.JumpNextDown
			End If
			
		Case VK_HOME
			Dim ControlKeyState As Short = GetKeyState(VK_CONTROL)
			Dim ControlPressed As Boolean = HIBYTE(ControlKeyState)
			If ControlPressed = 0 Then
				Return MoveSelectionRectangleDirection.JumpBeginLeft
			Else
				Return MoveSelectionRectangleDirection.JumpBeginStage
			End If
			
		Case VK_END
			Dim ControlKeyState As Short = GetKeyState(VK_CONTROL)
			Dim ControlPressed As Boolean = HIBYTE(ControlKeyState)
			If ControlPressed = 0 Then
				Return MoveSelectionRectangleDirection.JumpEndRight
			Else
				Return MoveSelectionRectangleDirection.JumpEndStage
			End If
			
		Case VK_PRIOR ' PageUp
			Dim ControlKeyState As Short = GetKeyState(VK_CONTROL)
			Dim ControlPressed As Boolean = HIBYTE(ControlKeyState)
			If ControlPressed = 0 Then
				Return MoveSelectionRectangleDirection.JumpNextUp
			Else
				Return MoveSelectionRectangleDirection.JumpBeginUp
			End If
			
		Case VK_NEXT ' PageDown
			Dim ControlKeyState As Short = GetKeyState(VK_CONTROL)
			Dim ControlPressed As Boolean = HIBYTE(ControlKeyState)
			If ControlPressed = 0 Then
				Return MoveSelectionRectangleDirection.JumpNextDown
			Else
				Return MoveSelectionRectangleDirection.JumpEndDown
			End If
			
	End Select
	
	Return MoveSelectionRectangleDirection.JumpBeginStage
	
End Function

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
		ByVal pScene As Scene Ptr, _
		ByVal pModel As GameModel Ptr _
	)As InputHandler Ptr
	
	Dim pHandler As InputHandler Ptr = Allocate(SizeOf(InputHandler))
	If pHandler = NULL Then
		Return NULL
	End If
	Dim hrCreate As HRESULT = CreateInstance( _
		@CLSID_EMPTYCOMMAND, _
		@IID_ICommand, _
		@pHandler->pEmptyCommand _
	)
	If FAILED(hrCreate) Then
		Deallocate(pHandler)
		Return NULL
	End If
	
	pHandler->pStage = pStage
	pHandler->pScene = pScene
	pHandler->pModel = pModel
	
	Return pHandler
	
End Function

Sub DestroyInputHandler( _
		ByVal pHandler As InputHandler Ptr _
	)
	
	ICommand_Release(pHandler->pEmptyCommand)
	Deallocate(pHandler)
	
End Sub

Function InputHandlerLMouseDown( _
		ByVal pHandler As InputHandler Ptr, _
		ByVal pp As POINT Ptr, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	Dim CellCoord As Point = Any
	Dim CellExists As Boolean = GetCellFromPoint( _
		pHandler->pStage, _
		pHandler->pScene, _
		pp, _
		@CellCoord _
	)
	If CellExists Then
		Dim pCommand As IPushCellCommand Ptr = Any
		Dim hrCreate As HRESULT = CreateInstance( _
			@CLSID_PUSHCELLCOMMAND, _
			@IID_IPushCellCommand, _
			@pCommand _
		)
		If FAILED(hrCreate) Then
			*ppvObject = NULL
			Return hrCreate
		End If
		
		IPushCellCommand_SetGameModel(pCommand, pHandler->pModel)
		
		IPushCellCommand_SetPushCellCoord(pCommand, @CellCoord)
		
		*ppvObject = pCommand
		Return S_OK
		
	End If
	
	ICommand_AddRef(pHandler->pEmptyCommand)
	*ppvObject = pHandler->pEmptyCommand
	Return S_FALSE
	
End Function

Function InputHandlerLMouseUp( _
		ByVal pHandler As InputHandler Ptr, _
		ByVal pp As POINT Ptr, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	Dim CellCoord As Point = Any
	Dim CellExists As Boolean = GetCellFromPoint( _
		pHandler->pStage, _
		pHandler->pScene, _
		pp, _
		@CellCoord _
	)
	If CellExists Then
		Return InputHandlerKeyUp( _
			pHandler, _
			VK_SPACE, _
			ppvObject _
		)
	End If
	
	ICommand_AddRef(pHandler->pEmptyCommand)
	*ppvObject = pHandler->pEmptyCommand
	Return S_FALSE
	
End Function

Function InputHandlerKeyDown( _
		ByVal pHandler As InputHandler Ptr, _
		ByVal Key As Integer, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	Select Case Key
		
		Case VK_TAB, VK_LEFT, VK_UP, VK_RIGHT, VK_DOWN, VK_HOME, VK_END, VK_PRIOR, VK_NEXT
			Dim pCommand As IMoveSelectionRectangleCommand Ptr = Any
			Dim hrCreate As HRESULT = CreateInstance( _
				@CLSID_MOVESELECTIONRECTANGLECOMMAND, _
				@IID_IMoveSelectionRectangleCommand, _
				@pCommand _
			)
			If FAILED(hrCreate) Then
				*ppvObject = NULL
				Return hrCreate
			End If
			
			IMoveSelectionRectangleCommand_SetGameModel(pCommand, pHandler->pModel)
			
			Dim Direction As MoveSelectionRectangleDirection = GetDirection(Key)
			IMoveSelectionRectangleCommand_SetMoveDirection(pCommand, Direction)
			
			*ppvObject = pCommand
			Return S_OK
			
		Case VK_ESCAPE
			Dim pCommand As IDeselectBallCommand Ptr = Any
			Dim hrCreate As HRESULT = CreateInstance( _
				@CLSID_DESELECTBALLCOMMAND, _
				@IID_IDeselectBallCommand, _
				@pCommand _
			)
			If FAILED(hrCreate) Then
				*ppvObject = NULL
				Return hrCreate
			End If
			
			IDeselectBallCommand_SetGameModel(pCommand, pHandler->pModel)
			
			*ppvObject = pCommand
			Return S_OK
			
		Case VK_SPACE, VK_RETURN
			Dim pCommand As IPushCellCommand Ptr = Any
			Dim hrCreate As HRESULT = CreateInstance( _
				@CLSID_PUSHCELLCOMMAND, _
				@IID_IPushCellCommand, _
				@pCommand _
			)
			If FAILED(hrCreate) Then
				*ppvObject = NULL
				Return hrCreate
			End If
			
			IPushCellCommand_SetGameModel(pCommand, pHandler->pModel)
			
			Dim SelectedCell As POINT = Any
			GameModelGetSelectedCell( _
				pHandler->pModel, _
				@SelectedCell _
			)
			IPushCellCommand_SetPushCellCoord(pCommand, @SelectedCell)
			
			*ppvObject = pCommand
			Return S_OK
			
	End Select
	
	ICommand_AddRef(pHandler->pEmptyCommand)
	*ppvObject = pHandler->pEmptyCommand
	Return S_FALSE
	
End Function

Function InputHandlerKeyUp( _
		ByVal pHandler As InputHandler Ptr, _
		ByVal Key As Integer, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	Select Case Key
		
		Case VK_SPACE, VK_RETURN
			Dim pCommand As IPullCellCommand Ptr = Any
			Dim hrCreate As HRESULT = CreateInstance( _
				@CLSID_PULLCELLCOMMAND, _
				@IID_IPullCellCommand, _
				@pCommand _
			)
			If FAILED(hrCreate) Then
				*ppvObject = NULL
				Return hrCreate
			End If
			
			IPullCellCommand_SetGameModel(pCommand, pHandler->pModel)
			
			' Dim SelectedCell As POINT = Any
			' GameModelGetSelectedCell( _
				' pHandler->pModel, _
				' @SelectedCell _
			' )
			' IPushCellCommand_SetPushCellCoord(pCommand, @SelectedCell)
			
			*ppvObject = pCommand
			Return S_OK
			
	End Select
	
	ICommand_AddRef(pHandler->pEmptyCommand)
	*ppvObject = pHandler->pEmptyCommand
	Return S_FALSE
	
End Function
