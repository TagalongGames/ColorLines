#ifndef STAGE_BI
#define STAGE_BI

#include once "windows.bi"

Enum ColorBallKind
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

#ifndef _SQUARECOORD_DEFINED_
#define _SQUARECOORD_DEFINED_

Type SquareCoord
	X As Integer
	Y As Integer
End Type

#endif

Type ColorBall
	Bounds As RECT
	Position As XFORM
	Kind As ColorBallKind
	Frame As AnimationFrames
	Visible As Boolean
	Selected As Boolean
End Type

Type ColorCell
	Bounds As RECT
	Position As XFORM
	Selected As Boolean
	Pressed As Boolean
End Type

Type Stage
	Cells(0 To 8, 0 To 8) As ColorCell
	Balls(0 To 8, 0 To 8) As ColorBall
	TabloCells(0 To 2) As ColorCell
	TabloBalls(0 To 2) As ColorBall
	MovedBall As ColorBall
	Score As Integer
	HiScore As Integer
End Type

Declare Function GenerateRandomColorBallKind( _
)As ColorBallKind

Declare Function CreateStage( _
	ByVal HiScore As Integer _
)As Stage Ptr

Declare Sub DestroyStage( _
	ByVal pStage As Stage Ptr _
)

Declare Sub StageGetBounds( _
	ByVal pStage As Stage Ptr, _
	ByVal pBounds As RECT Ptr _
)

Declare Function StageGetRandomEmptyCellCoord( _
	ByVal pStage As Stage Ptr, _
	ByVal pp As SquareCoord Ptr _
)As Boolean

Declare Function RowSequenceLength( _
	ByVal pStage As Stage Ptr, _
	ByVal X As Integer, _
	ByVal Y As Integer, _
	ByVal BallColor As ColorBallKind _
)As Integer

Declare Function ColSequenceLength( _
	ByVal pStage As Stage Ptr, _
	ByVal X As Integer, _
	ByVal Y As Integer, _
	ByVal BallColor As ColorBallKind _
)As Integer

Declare Function ForwardDiagonalSequenceLength( _
	ByVal pStage As Stage Ptr, _
	ByVal X As Integer, _
	ByVal Y As Integer, _
	ByVal BallColor As ColorBallKind _
)As Integer

Declare Function BackwardDiagonalSequenceLength( _
	ByVal pStage As Stage Ptr, _
	ByVal X As Integer, _
	ByVal Y As Integer, _
	ByVal BallColor As ColorBallKind _
)As Integer

#endif
