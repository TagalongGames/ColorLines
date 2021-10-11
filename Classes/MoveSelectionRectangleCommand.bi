#ifndef MOVESELECTIONRECTANGLECOMMAND_BI
#define MOVESELECTIONRECTANGLECOMMAND_BI

#include once "ICommand.bi"
#include once "IMoveSelectionRectangleCommand.bi"

Extern CLSID_MOVESELECTIONRECTANGLECOMMAND Alias "CLSID_MOVESELECTIONRECTANGLECOMMAND" As Const CLSID

Type MoveSelectionRectangleCommand As _MoveSelectionRectangleCommand

Type LPMoveSelectionRectangleCommand As _MoveSelectionRectangleCommand Ptr

Declare Function CreateMoveSelectionRectangleCommand( _
)As MoveSelectionRectangleCommand Ptr

Declare Sub DestroyMoveSelectionRectangleCommand( _
	ByVal this As MoveSelectionRectangleCommand Ptr _
)

Declare Function MoveSelectionRectangleCommandQueryInterface( _
	ByVal this As MoveSelectionRectangleCommand Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function MoveSelectionRectangleCommandAddRef( _
	ByVal this As MoveSelectionRectangleCommand Ptr _
)As ULONG

Declare Function MoveSelectionRectangleCommandRelease( _
	ByVal this As MoveSelectionRectangleCommand Ptr _
)As ULONG

Declare Function MoveSelectionRectangleCommandExecute( _
	ByVal this As MoveSelectionRectangleCommand Ptr _
)As HRESULT

Declare Function MoveSelectionRectangleCommandUndo( _
	ByVal this As MoveSelectionRectangleCommand Ptr _
)As HRESULT

Declare Function MoveSelectionRectangleCommandGetCommandType( _
	ByVal this As MoveSelectionRectangleCommand Ptr, _
	ByVal pType As CommandType Ptr _
)As HRESULT

Declare Function MoveSelectionRectangleCommandSetGameModel( _
	ByVal this As MoveSelectionRectangleCommand Ptr, _
	ByVal pModel As GameModel Ptr _
)As HRESULT

Declare Function MoveSelectionRectangleCommandSetMoveDirection( _
	ByVal this As MoveSelectionRectangleCommand Ptr, _
	ByVal Direction As MoveSelectionRectangleDirection _
)As HRESULT

#endif
