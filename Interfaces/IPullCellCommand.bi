#ifndef IPULLCELLCOMMAND_BI
#define IPULLCELLCOMMAND_BI

#include once "ICommand.bi"
#include once "GameModel.bi"

Type IPullCellCommand As IPullCellCommand_

Type LPIPULLCELLCOMMAND As IPullCellCommand Ptr

Extern IID_IPullCellCommand Alias "IID_IPullCellCommand" As Const IID

Type IPullCellCommandVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IPullCellCommand Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IPullCellCommand Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IPullCellCommand Ptr _
	)As ULONG
	
	Execute As Function( _
		ByVal this As IPullCellCommand Ptr _
	)As HRESULT
	
	Undo As Function( _
		ByVal this As IPullCellCommand Ptr _
	)As HRESULT
	
	GetCommandType As Function( _
		ByVal this As IPullCellCommand Ptr, _
		ByVal pType As CommandType Ptr _
	)As HRESULT
	
	SetGameModel As Function( _
		ByVal this As IPullCellCommand Ptr, _
		ByVal pModel As GameModel Ptr _
	)As HRESULT
	
End Type

Type IPullCellCommand_
	Dim lpVtbl As IPullCellCommandVirtualTable Ptr
End Type

#define IPullCellCommand_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IPullCellCommand_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IPullCellCommand_Release(this) (this)->lpVtbl->Release(this)
#define IPullCellCommand_Execute(this) (this)->lpVtbl->Execute(this)
#define IPullCellCommand_Undo(this) (this)->lpVtbl->Undo(this)
#define IPullCellCommand_GetCommandType(this, pType) (this)->lpVtbl->GetCommandType(this, pType)
#define IPullCellCommand_SetGameModel(this, pModel) (this)->lpVtbl->SetGameModel(this, pModel)

#endif
