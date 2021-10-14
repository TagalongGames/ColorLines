#ifndef DESELECTBALLCOMMAND_BI
#define DESELECTBALLCOMMAND_BI

#include once "ICommand.bi"
#include once "IDeselectBallCommand.bi"

Extern CLSID_DESELECTBALLCOMMAND Alias "CLSID_DESELECTBALLCOMMAND" As Const CLSID

Type DeselectBallCommand As _DeselectBallCommand

Type LPDeselectBallCommand As _DeselectBallCommand Ptr

Declare Function CreateDeselectBallCommand( _
)As DeselectBallCommand Ptr

Declare Sub DestroyDeselectBallCommand( _
	ByVal this As DeselectBallCommand Ptr _
)

Declare Function DeselectBallCommandQueryInterface( _
	ByVal this As DeselectBallCommand Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function DeselectBallCommandAddRef( _
	ByVal this As DeselectBallCommand Ptr _
)As ULONG

Declare Function DeselectBallCommandRelease( _
	ByVal this As DeselectBallCommand Ptr _
)As ULONG

Declare Function DeselectBallCommandExecute( _
	ByVal this As DeselectBallCommand Ptr _
)As HRESULT

Declare Function DeselectBallCommandUndo( _
	ByVal this As DeselectBallCommand Ptr _
)As HRESULT

Declare Function DeselectBallCommandGetCommandType( _
	ByVal this As DeselectBallCommand Ptr, _
	ByVal pType As CommandType Ptr _
)As HRESULT

Declare Function DeselectBallCommandSetGameModel( _
	ByVal this As DeselectBallCommand Ptr, _
	ByVal pModel As GameModel Ptr _
)As HRESULT

#endif
