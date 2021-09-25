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
	Visible As Boolean
	Selected As Boolean
End Type

Type Cell
	Rectangle As RECT
	Ball As ColorBall
	Selected As Boolean
End Type

Type Stage
	Lines(0 To 8, 0 To 8) As Cell
	Tablo(0 To 2) As Cell
	MovedBall As ColorBall
	SelectedCellX As Integer
	SelectedCellY As Integer
	SelectedBallX As Integer
	SelectedBallY As Integer
	Score As Integer
	HiScore As Integer
End Type

Declare Function CreateStage( _
	ByVal HiScore As Integer _
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
