#ifndef IMOVESELECTIONRECTANGLECOMMAND_BI
#define IMOVESELECTIONRECTANGLECOMMAND_BI

#include once "ICommand.bi"

Type IMoveSelectionRectangleCommand As IMoveSelectionRectangleCommand_

Type LPIMOVESELECTIONRECTANGLECOMMAND As IMoveSelectionRectangleCommand Ptr

Extern IID_IMoveSelectionRectangleCommand Alias "IID_IMoveSelectionRectangleCommand" As Const IID

Type IMoveSelectionRectangleCommandVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IMoveSelectionRectangleCommand Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IMoveSelectionRectangleCommand Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IMoveSelectionRectangleCommand Ptr _
	)As ULONG
	
	Execute As Function( _
		ByVal this As IMoveSelectionRectangleCommand Ptr _
	)As HRESULT
	
	Undo As Function( _
		ByVal this As IMoveSelectionRectangleCommand Ptr _
	)As HRESULT
	
	GetCommandType As Function( _
		ByVal this As IMoveSelectionRectangleCommand Ptr, _
		ByVal pType As CommandType Ptr _
	)As HRESULT
	
End Type

Type IMoveSelectionRectangleCommand_
	Dim lpVtbl As IMoveSelectionRectangleCommandVirtualTable Ptr
End Type

#define IMoveSelectionRectangleCommand_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IMoveSelectionRectangleCommand_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IMoveSelectionRectangleCommand_Release(this) (this)->lpVtbl->Release(this)
#define IMoveSelectionRectangleCommand_Execute(this) (this)->lpVtbl->Execute(this)
#define IMoveSelectionRectangleCommand_Undo(this) (this)->lpVtbl->Undo(this)
#define IMoveSelectionRectangleCommand_GetCommandType(this, pType) (this)->lpVtbl->GetCommandType(this, pType)

#endif
