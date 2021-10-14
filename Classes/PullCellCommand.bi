#ifndef PULLCELLCOMMAND_BI
#define PULLCELLCOMMAND_BI

#include once "IPullCellCommand.bi"

Extern CLSID_PULLCELLCOMMAND Alias "CLSID_PULLCELLCOMMAND" As Const CLSID

Type PullCellCommand As _PullCellCommand

Type LPPullCellCommand As _PullCellCommand Ptr

Declare Function CreatePullCellCommand( _
)As PullCellCommand Ptr

Declare Sub DestroyPullCellCommand( _
	ByVal this As PullCellCommand Ptr _
)

Declare Function PullCellCommandQueryInterface( _
	ByVal this As PullCellCommand Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function PullCellCommandAddRef( _
	ByVal this As PullCellCommand Ptr _
)As ULONG

Declare Function PullCellCommandRelease( _
	ByVal this As PullCellCommand Ptr _
)As ULONG

Declare Function PullCellCommandExecute( _
	ByVal this As PullCellCommand Ptr _
)As HRESULT

Declare Function PullCellCommandUndo( _
	ByVal this As PullCellCommand Ptr _
)As HRESULT

Declare Function PullCellCommandGetCommandType( _
	ByVal this As PullCellCommand Ptr, _
	ByVal pType As CommandType Ptr _
)As HRESULT

Declare Function PullCellCommandSetGameModel( _
	ByVal this As PullCellCommand Ptr, _
	ByVal pModel As GameModel Ptr _
)As HRESULT

#endif
