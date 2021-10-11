#include once "ICommand.bi"
#include once "EmptyCommand.bi"
#include once "ContainerOf.bi"

Extern GlobalEmptyCommandVirtualTable As Const ICommandVirtualTable

Type _EmptyCommand
	lpVtbl As Const ICommandVirtualTable Ptr
	RefCounter As Integer
End Type

Sub InitializeEmptyCommand( _
		ByVal this As EmptyCommand Ptr _
	)
	
	this->lpVtbl = @GlobalEmptyCommandVirtualTable
	this->RefCounter = 0
	
End Sub

Sub UnInitializeEmptyCommand( _
		ByVal this As EmptyCommand Ptr _
	)
	
End Sub

Function CreateEmptyCommand( _
	)As EmptyCommand Ptr
	
	Dim this As EmptyCommand Ptr = Allocate( _
		SizeOf(EmptyCommand) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeEmptyCommand(this)
	
	Return this
	
End Function

Sub DestroyEmptyCommand( _
		ByVal this As EmptyCommand Ptr _
	)
	
	Deallocate(this)
	
End Sub

Function EmptyCommandQueryInterface( _
		ByVal this As EmptyCommand Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
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
	
	EmptyCommandAddRef(this)
	
	Return S_OK
	
End Function

Function EmptyCommandAddRef( _
		ByVal this As EmptyCommand Ptr _
	)As ULONG
	
	this->RefCounter += 1
	
	Return 1
	
End Function

Function EmptyCommandRelease( _
		ByVal this As EmptyCommand Ptr _
	)As ULONG
	
	this->RefCounter -= 1
	
	If this->RefCounter = 0 Then
		
		DestroyEmptyCommand(this)
		
		Return 0
	End If
	
	Return 1
	
End Function

Function EmptyCommandExecute( _
		ByVal this As EmptyCommand Ptr _
	)As HRESULT
	
	Return S_OK
	
End Function

Function EmptyCommandUndo( _
		ByVal this As EmptyCommand Ptr _
	)As HRESULT
	
	Return S_OK
	
End Function

Function EmptyCommandGetCommandType( _
		ByVal this As EmptyCommand Ptr, _
		ByVal pType As CommandType Ptr _
	)As HRESULT
	
	*pType = CommandType.Empty
	
	Return S_OK
	
End Function


Function ICommandQueryInterface( _
		ByVal this As ICommand Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return EmptyCommandQueryInterface(ContainerOf(this, EmptyCommand, lpVtbl), riid, ppvObject)
End Function

Function ICommandAddRef( _
		ByVal this As ICommand Ptr _
	)As ULONG
	Return EmptyCommandAddRef(ContainerOf(this, EmptyCommand, lpVtbl))
End Function

Function ICommandRelease( _
		ByVal this As ICommand Ptr _
	)As ULONG
	Return EmptyCommandRelease(ContainerOf(this, EmptyCommand, lpVtbl))
End Function

Function ICommandExecute( _
		ByVal this As ICommand Ptr _
	)As ULONG
	Return EmptyCommandExecute(ContainerOf(this, EmptyCommand, lpVtbl))
End Function

Function ICommandUndo( _
		ByVal this As ICommand Ptr _
	)As ULONG
	Return EmptyCommandUndo(ContainerOf(this, EmptyCommand, lpVtbl))
End Function

Function ICommandGetCommandType( _
		ByVal this As ICommand Ptr, _
		ByVal pType As CommandType Ptr _
	)As ULONG
	Return EmptyCommandGetCommandType(ContainerOf(this, EmptyCommand, lpVtbl), pType)
End Function

Dim GlobalEmptyCommandVirtualTable As Const ICommandVirtualTable = Type( _
	@ICommandQueryInterface, _
	@ICommandAddRef, _
	@ICommandRelease, _
	@ICommandExecute, _
	@ICommandUndo, _
	@ICommandGetCommandType _
)
