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

Declare Sub GameModelNewGame( _
	ByVal pModel As GameModel Ptr _
)

Declare Function GameModelCommand( _
	ByVal pModel As GameModel Ptr, _
	ByVal cmd As MenuCommands _
)As Boolean

Declare Function GameModelUpdate( _
	ByVal pModel As GameModel Ptr _
)As Boolean

Declare Sub GameModelGetSelectedCell( _
	ByVal pModel As GameModel Ptr, _
	ByVal pCellCoord As POINT Ptr _
)

Declare Sub GameModelMoveSelectionRectangle( _
	ByVal pModel As GameModel Ptr, _
	ByVal Direction As MoveSelectionRectangleDirection _
)

#endif
