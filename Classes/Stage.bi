#ifndef STAGE_BI
#define STAGE_BI

#include once "windows.bi"

Enum BallColors
	Red
	Green
	Blue
	Yellow
	Magenta
	DarkRed
	Cyan
End Enum

Enum AnimationFrames
	Stopped
	' Появление: от 0 до 7
	Birth0
	Birth1
	Birth2
	Birth3
	Birth4
	Birth5
	Birth6
	Birth7
	' Смерть: от 0 до 7
	Death0
	Death1
	Death2
	Death3
	Death4
	Death5
	Death6
	Death7
	' Подпрыгивание: от 0 до 7 и обратно
	Bouncing0
	Bouncing1
	Bouncing2
	Bouncing3
	Bouncing4
	Bouncing5
	Bouncing6
	Bouncing7
End Enum

Type ColorBall
	Color As BallColors
	Frame As AnimationFrames
	Rectangle As RECT
	Exist As Boolean
End Type

Type Cell
	Rectangle As RECT
	Ball As ColorBall
	Selected As Boolean
End Type

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
		ByVal pContext As Any Ptr _
	)
	
	OnHiScoreChanged As Sub( _
		ByVal pContext As Any Ptr _
	)
	
	OnAnimated As Sub( _
		ByVal Context As Any Ptr _
	)
	
End Type

Type Stage
	Lines(0 To 8, 0 To 8) As Cell
	SelectedCellX As Integer
	SelectedCellY As Integer
	Tablo(0 To 2) As Cell
	MovedBall As ColorBall
	Events As StageEvents
	Context As Any Ptr
	Score As Integer
	HiScore As Integer
End Type

Declare Function CreateStage( _
	ByVal HiScore As Integer, _
	ByVal pEvents As StageEvents Ptr, _
	ByVal Context As Any Ptr _
)As Stage Ptr

Declare Sub DestroyStage( _
	ByVal pStage As Stage Ptr _
)

Declare Function StageGetWidth( _
	ByVal pStage As Stage Ptr _
)As Integer

Declare Function StageGetHeight( _
	ByVal pStage As Stage Ptr _
)As Integer

Declare Function GetRandomBoolean()As Boolean

Declare Function GetRandomBallColor()As BallColors

Declare Function GetRandomStageX()As Integer

Declare Function GetRandomStageY()As Integer

#endif
