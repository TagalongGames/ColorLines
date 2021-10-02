#ifndef "GAMEMODEL_BI"
#define "GAMEMODEL_BI"

#include once "Stage.bi"
#include once "Scene.bi"

Enum StageCommands
	Undo
End Enum

Type StageEvents
	
	OnLinesChanged As Sub( _
		ByVal pContext As Any Ptr, _
		ByVal pCoordinates As POINT Ptr, _
		ByVal Count As Integer _
	)
	
	OnTabloChanged As Sub( _
		ByVal pContext As Any Ptr _
	)
	
	OnMovedBallChanged As Sub( _
		ByVal pContext As Any Ptr _
	)
	
	OnScoreChanged As Sub( _
		ByVal pContext As Any Ptr, _
		ByVal Added As Integer _
	)
	
	OnHiScoreChanged As Sub( _
		ByVal pContext As Any Ptr, _
		ByVal Added As Integer _
	)
	
	OnAnimated As Sub( _
		ByVal Context As Any Ptr _
	)
	
	OnPathNotExist As Sub( _
		ByVal Context As Any Ptr _
	)
	
End Type

Type GameModel As _GameModel

Declare Function CreateGameModel( _
	ByVal pEvents As StageEvents Ptr, _
	ByVal Context As Any Ptr _
)As GameModel Ptr

Declare Sub DestroyGameModel( _
	ByVal pModel As GameModel Ptr _
)

Declare Sub GameModelNewGame( _
	ByVal pModel As GameModel Ptr, _
	ByVal pStage As Stage Ptr _
)

Declare Sub GameModelLMouseDown( _
	ByVal pModel As GameModel Ptr, _
	ByVal pStage As Stage Ptr, _
	ByVal pScene As Scene Ptr, _
	ByVal pp As POINT Ptr _
)

Declare Sub GameModelLMouseUp( _
	ByVal pModel As GameModel Ptr, _
	ByVal pStage As Stage Ptr, _
	ByVal pScene As Scene Ptr, _
	ByVal pp As POINT Ptr _
)

Declare Sub GameModelKeyDown( _
	ByVal pModel As GameModel Ptr, _
	ByVal pStage As Stage Ptr, _
	ByVal Key As Integer _
)

Declare Sub GameModelKeyUp( _
	ByVal pModel As GameModel Ptr, _
	ByVal pStage As Stage Ptr, _
	ByVal Key As Integer _
)

Declare Function GameModelCommand( _
	ByVal pModel As GameModel Ptr, _
	ByVal pStage As Stage Ptr, _
	ByVal cmd As StageCommands _
)As Boolean

Declare Function GameModelUpdate( _
	ByVal pModel As GameModel Ptr, _
	ByVal pStage As Stage Ptr _
)As Boolean

#endif
