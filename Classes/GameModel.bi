#ifndef "GAMEMODEL_BI"
#define "GAMEMODEL_BI"

#include once "Stage.bi"
#include once "Scene.bi"

Enum MenuCommands
	Undo
	Redo
End Enum

Enum MoveSelectionRectangleDirection
	Left
	Up
	Right
	Down
	JumpNextLeft
	JumpNextUp
	JumpNextRight
	JumpNextDown
	JumpBeginLeft
	JumpBeginUp
	JumpEndRight
	JumpEndDown
	JumpBeginStage
	JumpEndStage
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
	ByVal pStage As Stage Ptr, _
	ByVal pEvents As StageEvents Ptr, _
	ByVal Context As Any Ptr _
)As GameModel Ptr

Declare Sub DestroyGameModel( _
	ByVal pModel As GameModel Ptr _
)

Declare Function GameModelIsBusy( _
	ByVal pModel As GameModel Ptr _
)As Boolean

Declare Sub GameModelNewGame( _
	ByVal pModel As GameModel Ptr _
)

Declare Function GameModelUpdate( _
	ByVal pModel As GameModel Ptr _
)As Boolean

Declare Sub GameModelGetSelectedCell( _
	ByVal pModel As GameModel Ptr, _
	ByVal pCellCoord As POINT Ptr _
)

Declare Sub GameModelGetSelectedBall( _
	ByVal pModel As GameModel Ptr, _
	ByVal pBallCoord As POINT Ptr _
)

Declare Sub GameModelMoveSelectionRectangle( _
	ByVal pModel As GameModel Ptr, _
	ByVal Direction As MoveSelectionRectangleDirection _
)

Declare Sub GameModelMoveSelectionRectangleTo( _
	ByVal pModel As GameModel Ptr, _
	ByVal pCellCoord As POINT Ptr _
)

Declare Sub GameModelSelectBall( _
	ByVal pModel As GameModel Ptr _
)

Declare Sub GameModelDeselectBall( _
	ByVal pModel As GameModel Ptr _
)

Declare Sub GameModelGetPressedCell( _
	ByVal pModel As GameModel Ptr, _
	ByVal pPressedCellCoord As POINT Ptr _
)

Declare Sub GameModelPushCell( _
	ByVal pModel As GameModel Ptr, _
	ByVal pPushCellCoord As POINT Ptr _
)

Declare Sub GameModelUnPushCell( _
	ByVal pModel As GameModel Ptr _
)

Declare Sub GameModelPullCell( _
	ByVal pModel As GameModel Ptr _
)

Declare Sub GameModelUnPullCell( _
	ByVal pModel As GameModel Ptr _
)

#endif
