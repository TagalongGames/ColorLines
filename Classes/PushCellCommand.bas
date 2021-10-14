#include once "PushCellCommand.bi"
#include once "ContainerOf.bi"

Extern GlobalPushCellCommandVirtualTable As Const IPushCellCommandVirtualTable

Type _PushCellCommand
	lpVtbl As Const IPushCellCommandVirtualTable Ptr
	RefCounter As Integer
	pModel As GameModel Ptr
	PushCellCoord As POINT
End Type

Sub InitializePushCellCommand( _
		ByVal this As PushCellCommand Ptr _
	)
	
	this->lpVtbl = @GlobalPushCellCommandVirtualTable
	this->RefCounter = 0
	this->pModel = NULL
	this->PushCellCoord.x = 0
	this->PushCellCoord.y = 0
	
End Sub

Sub UnInitializePushCellCommand( _
		ByVal this As PushCellCommand Ptr _
	)
	
End Sub

Function CreatePushCellCommand( _
	)As PushCellCommand Ptr
	
	Dim this As PushCellCommand Ptr = Allocate( _
		SizeOf(PushCellCommand) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializePushCellCommand(this)
	
	Return this
	
End Function

Sub DestroyPushCellCommand( _
		ByVal this As PushCellCommand Ptr _
	)
	
	Deallocate(this)
	
End Sub

Function PushCellCommandQueryInterface( _
		ByVal this As PushCellCommand Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IPushCellCommand, riid) Then
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
	
	PushCellCommandAddRef(this)
	
	Return S_OK
	
End Function

Function PushCellCommandAddRef( _
		ByVal this As PushCellCommand Ptr _
	)As ULONG
	
	this->RefCounter += 1
	
	Return 1
	
End Function

Function PushCellCommandRelease( _
		ByVal this As PushCellCommand Ptr _
	)As ULONG
	
	this->RefCounter -= 1
	
	If this->RefCounter = 0 Then
		
		DestroyPushCellCommand(this)
		
		Return 0
	End If
	
	Return 1
	
End Function

Function PushCellCommandExecute( _
		ByVal this As PushCellCommand Ptr _
	)As HRESULT
	
	GameModelPushCell(this->pModel, @this->PushCellCoord)
	
	Return S_OK
	
End Function

Function PushCellCommandUndo( _
		ByVal this As PushCellCommand Ptr _
	)As HRESULT
	
	GameModelUnPushCell(this->pModel)
	
	Return S_OK
	
End Function

Function PushCellCommandGetCommandType( _
		ByVal this As PushCellCommand Ptr, _
		ByVal pType As CommandType Ptr _
	)As HRESULT
	
	*pType = CommandType.PushCell
	
	Return S_OK
	
End Function

Function PushCellCommandSetGameModel( _
		ByVal this As PushCellCommand Ptr, _
		ByVal pModel As GameModel Ptr _
	)As HRESULT
	
	this->pModel = pModel
	
	Return S_OK
	
End Function

Function PushCellCommandSetPushCellCoord( _
		ByVal this As PushCellCommand Ptr, _
		ByVal pPushCellCoord As POINT Ptr _
	)As HRESULT
	
	this->PushCellCoord = *pPushCellCoord
	
	Return S_OK
	
End Function

Function IPushCellCommandQueryInterface( _
		ByVal this As IPushCellCommand Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return PushCellCommandQueryInterface(ContainerOf(this, PushCellCommand, lpVtbl), riid, ppvObject)
End Function

Function IPushCellCommandAddRef( _
		ByVal this As IPushCellCommand Ptr _
	)As ULONG
	Return PushCellCommandAddRef(ContainerOf(this, PushCellCommand, lpVtbl))
End Function

Function IPushCellCommandRelease( _
		ByVal this As IPushCellCommand Ptr _
	)As ULONG
	Return PushCellCommandRelease(ContainerOf(this, PushCellCommand, lpVtbl))
End Function

Function IPushCellCommandExecute( _
		ByVal this As IPushCellCommand Ptr _
	)As ULONG
	Return PushCellCommandExecute(ContainerOf(this, PushCellCommand, lpVtbl))
End Function

Function IPushCellCommandUndo( _
		ByVal this As IPushCellCommand Ptr _
	)As ULONG
	Return PushCellCommandUndo(ContainerOf(this, PushCellCommand, lpVtbl))
End Function

Function IPushCellCommandGetCommandType( _
		ByVal this As IPushCellCommand Ptr, _
		ByVal pType As CommandType Ptr _
	)As ULONG
	Return PushCellCommandGetCommandType(ContainerOf(this, PushCellCommand, lpVtbl), pType)
End Function

Function IPushCellCommandSetGameModel( _
		ByVal this As IPushCellCommand Ptr, _
		ByVal pModel As GameModel Ptr _
	)As ULONG
	Return PushCellCommandSetGameModel(ContainerOf(this, PushCellCommand, lpVtbl), pModel)
End Function

Function IPushCellCommandSetPushCellCoord( _
		ByVal this As IPushCellCommand Ptr, _
		ByVal pPushCellCoord As POINT Ptr _
	)As ULONG
	Return PushCellCommandSetPushCellCoord(ContainerOf(this, PushCellCommand, lpVtbl), pPushCellCoord)
End Function

Dim GlobalPushCellCommandVirtualTable As Const IPushCellCommandVirtualTable = Type( _
	@IPushCellCommandQueryInterface, _
	@IPushCellCommandAddRef, _
	@IPushCellCommandRelease, _
	@IPushCellCommandExecute, _
	@IPushCellCommandUndo, _
	@IPushCellCommandGetCommandType, _
	@IPushCellCommandSetGameModel, _
	@IPushCellCommandSetPushCellCoord _
)
