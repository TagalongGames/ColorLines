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

Type ColorBall
	Color As BallColors
	BallRectangle As RECT
	Exist As Boolean
End Type

Type Cell
	CellRectangle As RECT
	Ball As ColorBall
End Type

Type Stage
	Lines(0 To 8, 0 To 8) As Cell
	Tablo(0 To 2) As Cell
	MovedBall As ColorBall
	Score As Integer
	HiScore As Integer
End Type

Declare Function CreateStage( _
	ByVal HiScore As Integer _
)As Stage Ptr

Declare Sub DestroyStage( _
	ByVal pStage As Stage Ptr _
)

#endif
