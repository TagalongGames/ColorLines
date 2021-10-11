#ifndef ICOMMAND_BI
#define ICOMMAND_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Type ICommand As ICommand_

Type LPICOMMAND As ICommand Ptr

Extern IID_ICommand Alias "IID_ICommand" As Const IID

Enum CommandType
	MoveSelectionRectangle
	PushCell
	PullCell
	DeselectBall
	NewGame
End Enum

Type ICommandVirtualTable
	
	QueryInterface As Function( _
		ByVal this As ICommand Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As ICommand Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As ICommand Ptr _
	)As ULONG
	
	Execute As Function( _
		ByVal this As ICommand Ptr _
	)As HRESULT
	
	Undo As Function( _
		ByVal this As ICommand Ptr _
	)As HRESULT
	
	GetCommandType As Function( _
		ByVal this As ICommand Ptr, _
		ByVal pType As CommandType Ptr _
	)As HRESULT
	
End Type

Type ICommand_
	Dim lpVtbl As ICommandVirtualTable Ptr
End Type

#define ICommand_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define ICommand_AddRef(this) (this)->lpVtbl->AddRef(this)
#define ICommand_Release(this) (this)->lpVtbl->Release(this)
#define ICommand_Execute(this) (this)->lpVtbl->Execute(this)
#define ICommand_Undo(this) (this)->lpVtbl->Undo(this)
#define ICommand_GetCommandType(this, pType) (this)->lpVtbl->GetCommandType(this, pType)

#endif
