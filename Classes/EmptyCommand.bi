#ifndef EMPTYCOMMAND_BI
#define EMPTYCOMMAND_BI

#include once "ICommand.bi"

Extern CLSID_EMPTYCOMMAND Alias "CLSID_EMPTYCOMMAND" As Const CLSID

Type EmptyCommand As _EmptyCommand

Type LPEmptyCommand As _EmptyCommand Ptr

Declare Function CreateEmptyCommand( _
)As EmptyCommand Ptr

Declare Sub DestroyEmptyCommand( _
	ByVal this As EmptyCommand Ptr _
)

Declare Function EmptyCommandQueryInterface( _
	ByVal this As EmptyCommand Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function EmptyCommandAddRef( _
	ByVal this As EmptyCommand Ptr _
)As ULONG

Declare Function EmptyCommandRelease( _
	ByVal this As EmptyCommand Ptr _
)As ULONG

Declare Function EmptyCommandExecute( _
	ByVal this As EmptyCommand Ptr _
)As HRESULT

Declare Function EmptyCommandUndo( _
	ByVal this As EmptyCommand Ptr _
)As HRESULT

Declare Function EmptyCommandGetCommandType( _
	ByVal this As EmptyCommand Ptr, _
	ByVal pType As CommandType Ptr _
)As HRESULT

#endif
