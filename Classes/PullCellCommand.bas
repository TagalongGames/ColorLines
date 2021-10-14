#include once "PullCellCommand.bi"
#include once "ContainerOf.bi"

Extern GlobalPullCellCommandVirtualTable As Const IPullCellCommandVirtualTable

Type _PullCellCommand
	lpVtbl As Const IPullCellCommandVirtualTable Ptr
	RefCounter As Integer
	pModel As GameModel Ptr
End Type

Sub InitializePullCellCommand( _
		ByVal this As PullCellCommand Ptr _
	)
	
	this->lpVtbl = @GlobalPullCellCommandVirtualTable
	this->RefCounter = 0
	this->pModel = NULL
	
End Sub

Sub UnInitializePullCellCommand( _
		ByVal this As PullCellCommand Ptr _
	)
	
End Sub

Function CreatePullCellCommand( _
	)As PullCellCommand Ptr
	
	Dim this As PullCellCommand Ptr = Allocate( _
		SizeOf(PullCellCommand) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializePullCellCommand(this)
	
	Return this
	
End Function

Sub DestroyPullCellCommand( _
		ByVal this As PullCellCommand Ptr _
	)
	
	Deallocate(this)
	
End Sub

Function PullCellCommandQueryInterface( _
		ByVal this As PullCellCommand Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IPullCellCommand, riid) Then
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
	
	PullCellCommandAddRef(this)
	
	Return S_OK
	
End Function

Function PullCellCommandAddRef( _
		ByVal this As PullCellCommand Ptr _
	)As ULONG
	
	this->RefCounter += 1
	
	Return 1
	
End Function

Function PullCellCommandRelease( _
		ByVal this As PullCellCommand Ptr _
	)As ULONG
	
	this->RefCounter -= 1
	
	If this->RefCounter = 0 Then
		
		DestroyPullCellCommand(this)
		
		Return 0
	End If
	
	Return 1
	
End Function

Function PullCellCommandExecute( _
		ByVal this As PullCellCommand Ptr _
	)As HRESULT
	
	GameModelPullCell(this->pModel)
	
	Return S_OK
	
End Function

Function PullCellCommandUndo( _
		ByVal this As PullCellCommand Ptr _
	)As HRESULT
	
	GameModelUnPullCell(this->pModel)
	
	Return S_OK
	
End Function

Function PullCellCommandGetCommandType( _
		ByVal this As PullCellCommand Ptr, _
		ByVal pType As CommandType Ptr _
	)As HRESULT
	
	*pType = CommandType.PullCell
	
	Return S_OK
	
End Function

Function PullCellCommandSetGameModel( _
		ByVal this As PullCellCommand Ptr, _
		ByVal pModel As GameModel Ptr _
	)As HRESULT
	
	this->pModel = pModel
	
	Return S_OK
	
End Function


Function IPullCellCommandQueryInterface( _
		ByVal this As IPullCellCommand Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return PullCellCommandQueryInterface(ContainerOf(this, PullCellCommand, lpVtbl), riid, ppvObject)
End Function

Function IPullCellCommandAddRef( _
		ByVal this As IPullCellCommand Ptr _
	)As ULONG
	Return PullCellCommandAddRef(ContainerOf(this, PullCellCommand, lpVtbl))
End Function

Function IPullCellCommandRelease( _
		ByVal this As IPullCellCommand Ptr _
	)As ULONG
	Return PullCellCommandRelease(ContainerOf(this, PullCellCommand, lpVtbl))
End Function

Function IPullCellCommandExecute( _
		ByVal this As IPullCellCommand Ptr _
	)As ULONG
	Return PullCellCommandExecute(ContainerOf(this, PullCellCommand, lpVtbl))
End Function

Function IPullCellCommandUndo( _
		ByVal this As IPullCellCommand Ptr _
	)As ULONG
	Return PullCellCommandUndo(ContainerOf(this, PullCellCommand, lpVtbl))
End Function

Function IPullCellCommandGetCommandType( _
		ByVal this As IPullCellCommand Ptr, _
		ByVal pType As CommandType Ptr _
	)As ULONG
	Return PullCellCommandGetCommandType(ContainerOf(this, PullCellCommand, lpVtbl), pType)
End Function

Function IPullCellCommandSetGameModel( _
		ByVal this As IPullCellCommand Ptr, _
		ByVal pModel As GameModel Ptr _
	)As ULONG
	Return PullCellCommandSetGameModel(ContainerOf(this, PullCellCommand, lpVtbl), pModel)
End Function

Dim GlobalPullCellCommandVirtualTable As Const IPullCellCommandVirtualTable = Type( _
	@IPullCellCommandQueryInterface, _
	@IPullCellCommandAddRef, _
	@IPullCellCommandRelease, _
	@IPullCellCommandExecute, _
	@IPullCellCommandUndo, _
	@IPullCellCommandGetCommandType, _
	@IPullCellCommandSetGameModel _
)
