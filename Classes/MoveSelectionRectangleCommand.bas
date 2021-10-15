#include once "ICommand.bi"
#include once "IMoveSelectionRectangleCommand.bi"
#include once "MoveSelectionRectangleCommand.bi"
#include once "ContainerOf.bi"

Extern GlobalMoveSelectionRectangleCommandVirtualTable As Const IMoveSelectionRectangleCommandVirtualTable

Type _MoveSelectionRectangleCommand
	lpVtbl As Const IMoveSelectionRectangleCommandVirtualTable Ptr
	RefCounter As Integer
	pModel As GameModel Ptr
	MoveDirection As MoveSelectionRectangleDirection
	SelectionCellCoord As SquareCoord
End Type

Sub InitializeMoveSelectionRectangleCommand( _
		ByVal this As MoveSelectionRectangleCommand Ptr _
	)
	
	this->lpVtbl = @GlobalMoveSelectionRectangleCommandVirtualTable
	this->RefCounter = 0
	this->SelectionCellCoord.x = 0
	this->SelectionCellCoord.y = 0
	this->MoveDirection = MoveSelectionRectangleDirection.Left
	this->pModel = NULL
	
End Sub

Sub UnInitializeMoveSelectionRectangleCommand( _
		ByVal this As MoveSelectionRectangleCommand Ptr _
	)
	
End Sub

Function CreateMoveSelectionRectangleCommand( _
	)As MoveSelectionRectangleCommand Ptr
	
	Dim this As MoveSelectionRectangleCommand Ptr = Allocate( _
		SizeOf(MoveSelectionRectangleCommand) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeMoveSelectionRectangleCommand(this)
	
	Return this
	
End Function

Sub DestroyMoveSelectionRectangleCommand( _
		ByVal this As MoveSelectionRectangleCommand Ptr _
	)
	
	Deallocate(this)
	
End Sub

Function MoveSelectionRectangleCommandQueryInterface( _
		ByVal this As MoveSelectionRectangleCommand Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IMoveSelectionRectangleCommand, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_ICommand, riid) Then
			*ppv = @this->lpVtbl
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @this->lpVtbl
			Else
				*ppv = NULL
				Return E_NOINTERFACE
			End If
		End If
	End If
	
	MoveSelectionRectangleCommandAddRef(this)
	
	Return S_OK
	
End Function

Function MoveSelectionRectangleCommandAddRef( _
		ByVal this As MoveSelectionRectangleCommand Ptr _
	)As ULONG
	
	this->RefCounter += 1
	
	Return 1
	
End Function

Function MoveSelectionRectangleCommandRelease( _
		ByVal this As MoveSelectionRectangleCommand Ptr _
	)As ULONG
	
	this->RefCounter -= 1
	
	If this->RefCounter = 0 Then
		
		DestroyMoveSelectionRectangleCommand(this)
		
		Return 0
	End If
	
	Return 1
	
End Function

Function MoveSelectionRectangleCommandExecute( _
		ByVal this As MoveSelectionRectangleCommand Ptr _
	)As HRESULT
	
	GameModelGetSelectedCell( _
		this->pModel, _
		@this->SelectionCellCoord _
	)
	GameModelMoveSelectionRectangle(this->pModel, this->MoveDirection)
	
	Return S_OK
	
End Function

Function MoveSelectionRectangleCommandUndo( _
		ByVal this As MoveSelectionRectangleCommand Ptr _
	)As HRESULT
	
	GameModelMoveSelectionRectangleTo(this->pModel, @this->SelectionCellCoord)
	
	Return S_OK
	
End Function

Function MoveSelectionRectangleCommandGetCommandType( _
		ByVal this As MoveSelectionRectangleCommand Ptr, _
		ByVal pType As CommandType Ptr _
	)As HRESULT
	
	*pType = CommandType.MoveSelectionRectangle
	
	Return S_OK
	
End Function

Function MoveSelectionRectangleCommandSetGameModel( _
		ByVal this As MoveSelectionRectangleCommand Ptr, _
		ByVal pModel As GameModel Ptr _
	)As HRESULT
	
	this->pModel = pModel
	
	Return S_OK
	
End Function

Function MoveSelectionRectangleCommandSetMoveDirection( _
		ByVal this As MoveSelectionRectangleCommand Ptr, _
		ByVal Direction As MoveSelectionRectangleDirection _
	)As HRESULT
	
	this->MoveDirection = Direction
	
	Return S_OK
	
End Function


Function IMoveSelectionRectangleCommandQueryInterface( _
		ByVal this As IMoveSelectionRectangleCommand Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return MoveSelectionRectangleCommandQueryInterface(ContainerOf(this, MoveSelectionRectangleCommand, lpVtbl), riid, ppvObject)
End Function

Function IMoveSelectionRectangleCommandAddRef( _
		ByVal this As IMoveSelectionRectangleCommand Ptr _
	)As ULONG
	Return MoveSelectionRectangleCommandAddRef(ContainerOf(this, MoveSelectionRectangleCommand, lpVtbl))
End Function

Function IMoveSelectionRectangleCommandRelease( _
		ByVal this As IMoveSelectionRectangleCommand Ptr _
	)As ULONG
	Return MoveSelectionRectangleCommandRelease(ContainerOf(this, MoveSelectionRectangleCommand, lpVtbl))
End Function

Function IMoveSelectionRectangleCommandExecute( _
		ByVal this As IMoveSelectionRectangleCommand Ptr _
	)As ULONG
	Return MoveSelectionRectangleCommandExecute(ContainerOf(this, MoveSelectionRectangleCommand, lpVtbl))
End Function

Function IMoveSelectionRectangleCommandUndo( _
		ByVal this As IMoveSelectionRectangleCommand Ptr _
	)As ULONG
	Return MoveSelectionRectangleCommandUndo(ContainerOf(this, MoveSelectionRectangleCommand, lpVtbl))
End Function

Function IMoveSelectionRectangleCommandGetCommandType( _
		ByVal this As IMoveSelectionRectangleCommand Ptr, _
		ByVal pType As CommandType Ptr _
	)As ULONG
	Return MoveSelectionRectangleCommandGetCommandType(ContainerOf(this, MoveSelectionRectangleCommand, lpVtbl), pType)
End Function

Function IMoveSelectionRectangleCommandSetGameModel( _
		ByVal this As IMoveSelectionRectangleCommand Ptr, _
		ByVal pModel As GameModel Ptr _
	)As ULONG
	Return MoveSelectionRectangleCommandSetGameModel(ContainerOf(this, MoveSelectionRectangleCommand, lpVtbl), pModel)
End Function

Function IMoveSelectionRectangleCommandSetMoveDirection( _
		ByVal this As IMoveSelectionRectangleCommand Ptr, _
		ByVal Direction As MoveSelectionRectangleDirection _
	)As ULONG
	Return MoveSelectionRectangleCommandSetMoveDirection(ContainerOf(this, MoveSelectionRectangleCommand, lpVtbl), Direction)
End Function

Dim GlobalMoveSelectionRectangleCommandVirtualTable As Const IMoveSelectionRectangleCommandVirtualTable = Type( _
	@IMoveSelectionRectangleCommandQueryInterface, _
	@IMoveSelectionRectangleCommandAddRef, _
	@IMoveSelectionRectangleCommandRelease, _
	@IMoveSelectionRectangleCommandExecute, _
	@IMoveSelectionRectangleCommandUndo, _
	@IMoveSelectionRectangleCommandGetCommandType, _
	@IMoveSelectionRectangleCommandSetGameModel, _
	@IMoveSelectionRectangleCommandSetMoveDirection _
)
