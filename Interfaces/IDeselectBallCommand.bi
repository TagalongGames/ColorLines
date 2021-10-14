#ifndef IDESELECTBALLCOMMAND_BI
#define IDESELECTBALLCOMMAND_BI

#include once "ICommand.bi"
#include once "GameModel.bi"

Type IDeselectBallCommand As IDeselectBallCommand_

Type LPIDESELECTBALLCOMMAND As IDeselectBallCommand Ptr

Extern IID_IDeselectBallCommand Alias "IID_IDeselectBallCommand" As Const IID

Type IDeselectBallCommandVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IDeselectBallCommand Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IDeselectBallCommand Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IDeselectBallCommand Ptr _
	)As ULONG
	
	Execute As Function( _
		ByVal this As IDeselectBallCommand Ptr _
	)As HRESULT
	
	Undo As Function( _
		ByVal this As IDeselectBallCommand Ptr _
	)As HRESULT
	
	GetCommandType As Function( _
		ByVal this As IDeselectBallCommand Ptr, _
		ByVal pType As CommandType Ptr _
	)As HRESULT
	
	SetGameModel As Function( _
		ByVal this As IDeselectBallCommand Ptr, _
		ByVal pModel As GameModel Ptr _
	)As HRESULT
	
End Type

Type IDeselectBallCommand_
	Dim lpVtbl As IDeselectBallCommandVirtualTable Ptr
End Type

#define IDeselectBallCommand_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IDeselectBallCommand_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IDeselectBallCommand_Release(this) (this)->lpVtbl->Release(this)
#define IDeselectBallCommand_Execute(this) (this)->lpVtbl->Execute(this)
#define IDeselectBallCommand_Undo(this) (this)->lpVtbl->Undo(this)
#define IDeselectBallCommand_GetCommandType(this, pType) (this)->lpVtbl->GetCommandType(this, pType)
#define IDeselectBallCommand_SetGameModel(this, pModel) (this)->lpVtbl->SetGameModel(this, pModel)

#endif
