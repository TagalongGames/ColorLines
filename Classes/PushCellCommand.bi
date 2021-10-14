#ifndef PUSHCELLCOMMAND_BI
#define PUSHCELLCOMMAND_BI

#include once "IPushCellCommand.bi"

Extern CLSID_PUSHCELLCOMMAND Alias "CLSID_PUSHCELLCOMMAND" As Const CLSID

Type PushCellCommand As _PushCellCommand

Type LPPushCellCommand As _PushCellCommand Ptr

Declare Function CreatePushCellCommand( _
)As PushCellCommand Ptr

Declare Sub DestroyPushCellCommand( _
	ByVal this As PushCellCommand Ptr _
)

Declare Function PushCellCommandQueryInterface( _
	ByVal this As PushCellCommand Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function PushCellCommandAddRef( _
	ByVal this As PushCellCommand Ptr _
)As ULONG

Declare Function PushCellCommandRelease( _
	ByVal this As PushCellCommand Ptr _
)As ULONG

Declare Function PushCellCommandExecute( _
	ByVal this As PushCellCommand Ptr _
)As HRESULT

Declare Function PushCellCommandUndo( _
	ByVal this As PushCellCommand Ptr _
)As HRESULT

Declare Function PushCellCommandGetCommandType( _
	ByVal this As PushCellCommand Ptr, _
	ByVal pType As CommandType Ptr _
)As HRESULT

Declare Function PushCellCommandSetGameModel( _
	ByVal this As PushCellCommand Ptr, _
	ByVal pModel As GameModel Ptr _
)As HRESULT

Declare Function PushCellCommandSetPushCellCoord( _
	ByVal this As PushCellCommand Ptr, _
	ByVal pPushCellCoord As POINT Ptr _
)As HRESULT

#endif
