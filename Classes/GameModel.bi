#ifndef "GAMEMODEL_BI"
#define "GAMEMODEL_BI"

#include once "Stage.bi"

Enum StageCommands
	Undo
End Enum

Type GameModel As _GameModel

Declare Function CreateGameModel( _
)As GameModel Ptr

Declare Sub DestroyGameModel( _
	ByVal pModel As GameModel Ptr _
)

Declare Sub GameModelNewGame( _
	ByVal pModel As GameModel Ptr, _
	ByVal pStage As Stage Ptr _
)

Declare Sub GameModelClick( _
	ByVal pStage As Stage Ptr, _
	ByVal pp As POINT Ptr _
)

Declare Sub GameModelKeyDown( _
	ByVal pStage As Stage Ptr, _
	ByVal Key As Integer _
)

Declare Sub GameModelKeyUp( _
	ByVal pStage As Stage Ptr, _
	ByVal Key As Integer _
)

Declare Function GameModelTick( _
	ByVal pStage As Stage Ptr _
)As Boolean

Declare Function GameModelCommand( _
	ByVal pStage As Stage Ptr, _
	ByVal cmd As StageCommands _
)As Boolean


#endif
