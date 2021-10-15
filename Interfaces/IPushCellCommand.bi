#ifndef IPUSHCELLCOMMAND_BI
#define IPUSHCELLCOMMAND_BI

#include once "ICommand.bi"
#include once "GameModel.bi"

Type IPushCellCommand As IPushCellCommand_

Type LPIPUSHCELLCOMMAND As IPushCellCommand Ptr

Extern IID_IPushCellCommand Alias "IID_IPushCellCommand" As Const IID

Type IPushCellCommandVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IPushCellCommand Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IPushCellCommand Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IPushCellCommand Ptr _
	)As ULONG
	
	Execute As Function( _
		ByVal this As IPushCellCommand Ptr _
	)As HRESULT
	
	Undo As Function( _
		ByVal this As IPushCellCommand Ptr _
	)As HRESULT
	
	GetCommandType As Function( _
		ByVal this As IPushCellCommand Ptr, _
		ByVal pType As CommandType Ptr _
	)As HRESULT
	
	SetGameModel As Function( _
		ByVal this As IPushCellCommand Ptr, _
		ByVal pModel As GameModel Ptr _
	)As HRESULT
	
	SetPushCellCoord As Function( _
		ByVal this As IPushCellCommand Ptr, _
		ByVal pPushCellCoord As SquareCoord Ptr _
	)As HRESULT
	
End Type

Type IPushCellCommand_
	Dim lpVtbl As IPushCellCommandVirtualTable Ptr
End Type

#define IPushCellCommand_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IPushCellCommand_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IPushCellCommand_Release(this) (this)->lpVtbl->Release(this)
#define IPushCellCommand_Execute(this) (this)->lpVtbl->Execute(this)
#define IPushCellCommand_Undo(this) (this)->lpVtbl->Undo(this)
#define IPushCellCommand_GetCommandType(this, pType) (this)->lpVtbl->GetCommandType(this, pType)
#define IPushCellCommand_SetGameModel(this, pModel) (this)->lpVtbl->SetGameModel(this, pModel)
#define IPushCellCommand_SetPushCellCoord(this, pPushCellCoord) (this)->lpVtbl->SetPushCellCoord(this, pPushCellCoord)

#endif
