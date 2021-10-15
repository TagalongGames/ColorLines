#include once "ICommand.bi"
#include once "IDeselectBallCommand.bi"
#include once "DeselectBallCommand.bi"
#include once "ContainerOf.bi"

Extern GlobalDeselectBallCommandVirtualTable As Const IDeselectBallCommandVirtualTable

Type _DeselectBallCommand
	lpVtbl As Const IDeselectBallCommandVirtualTable Ptr
	RefCounter As Integer
	pModel As GameModel Ptr
	SelectionBallCoord As SquareCoord
End Type

Sub InitializeDeselectBallCommand( _
		ByVal this As DeselectBallCommand Ptr _
	)
	
	this->lpVtbl = @GlobalDeselectBallCommandVirtualTable
	this->RefCounter = 0
	this->pModel = NULL
	this->SelectionBallCoord.x = 0
	this->SelectionBallCoord.y = 0
	
End Sub

Sub UnInitializeDeselectBallCommand( _
		ByVal this As DeselectBallCommand Ptr _
	)
	
End Sub

Function CreateDeselectBallCommand( _
	)As DeselectBallCommand Ptr
	
	Dim this As DeselectBallCommand Ptr = Allocate( _
		SizeOf(DeselectBallCommand) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeDeselectBallCommand(this)
	
	Return this
	
End Function

Sub DestroyDeselectBallCommand( _
		ByVal this As DeselectBallCommand Ptr _
	)
	
	Deallocate(this)
	
End Sub

Function DeselectBallCommandQueryInterface( _
		ByVal this As DeselectBallCommand Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IDeselectBallCommand, riid) Then
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
	
	DeselectBallCommandAddRef(this)
	
	Return S_OK
	
End Function

Function DeselectBallCommandAddRef( _
		ByVal this As DeselectBallCommand Ptr _
	)As ULONG
	
	this->RefCounter += 1
	
	Return 1
	
End Function

Function DeselectBallCommandRelease( _
		ByVal this As DeselectBallCommand Ptr _
	)As ULONG
	
	this->RefCounter -= 1
	
	If this->RefCounter = 0 Then
		
		DestroyDeselectBallCommand(this)
		
		Return 0
	End If
	
	Return 1
	
End Function

Function DeselectBallCommandExecute( _
		ByVal this As DeselectBallCommand Ptr _
	)As HRESULT
	
	GameModelGetSelectedBall( _
		this->pModel, _
		@this->SelectionBallCoord _
	)
	GameModelDeselectBall(this->pModel)
	
	Return S_OK
	
End Function

Function DeselectBallCommandUndo( _
		ByVal this As DeselectBallCommand Ptr _
	)As HRESULT
	
	GameModelSelectBall( _
		this->pModel, _
		@this->SelectionBallCoord _
	)
	
	Return S_OK
	
End Function

Function DeselectBallCommandGetCommandType( _
		ByVal this As DeselectBallCommand Ptr, _
		ByVal pType As CommandType Ptr _
	)As HRESULT
	
	*pType = CommandType.DeselectBall
	
	Return S_OK
	
End Function

Function DeselectBallCommandSetGameModel( _
		ByVal this As DeselectBallCommand Ptr, _
		ByVal pModel As GameModel Ptr _
	)As HRESULT
	
	this->pModel = pModel
	
	Return S_OK
	
End Function


Function IDeselectBallCommandQueryInterface( _
		ByVal this As IDeselectBallCommand Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return DeselectBallCommandQueryInterface(ContainerOf(this, DeselectBallCommand, lpVtbl), riid, ppvObject)
End Function

Function IDeselectBallCommandAddRef( _
		ByVal this As IDeselectBallCommand Ptr _
	)As ULONG
	Return DeselectBallCommandAddRef(ContainerOf(this, DeselectBallCommand, lpVtbl))
End Function

Function IDeselectBallCommandRelease( _
		ByVal this As IDeselectBallCommand Ptr _
	)As ULONG
	Return DeselectBallCommandRelease(ContainerOf(this, DeselectBallCommand, lpVtbl))
End Function

Function IDeselectBallCommandExecute( _
		ByVal this As IDeselectBallCommand Ptr _
	)As ULONG
	Return DeselectBallCommandExecute(ContainerOf(this, DeselectBallCommand, lpVtbl))
End Function

Function IDeselectBallCommandUndo( _
		ByVal this As IDeselectBallCommand Ptr _
	)As ULONG
	Return DeselectBallCommandUndo(ContainerOf(this, DeselectBallCommand, lpVtbl))
End Function

Function IDeselectBallCommandGetCommandType( _
		ByVal this As IDeselectBallCommand Ptr, _
		ByVal pType As CommandType Ptr _
	)As ULONG
	Return DeselectBallCommandGetCommandType(ContainerOf(this, DeselectBallCommand, lpVtbl), pType)
End Function

Function IDeselectBallCommandSetGameModel( _
		ByVal this As IDeselectBallCommand Ptr, _
		ByVal pModel As GameModel Ptr _
	)As ULONG
	Return DeselectBallCommandSetGameModel(ContainerOf(this, DeselectBallCommand, lpVtbl), pModel)
End Function

Dim GlobalDeselectBallCommandVirtualTable As Const IDeselectBallCommandVirtualTable = Type( _
	@IDeselectBallCommandQueryInterface, _
	@IDeselectBallCommandAddRef, _
	@IDeselectBallCommandRelease, _
	@IDeselectBallCommandExecute, _
	@IDeselectBallCommandUndo, _
	@IDeselectBallCommandGetCommandType, _
	@IDeselectBallCommandSetGameModel _
)
