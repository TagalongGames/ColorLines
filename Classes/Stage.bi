#ifndef STAGE_BI
#define STAGE_BI

#include once "windows.bi"

Enum StageKeys
	Tab
	ShiftTab
	KeyReturn
	Left
	Up
	Right
	Down
	Escape
End Enum

Enum StageCommands
	Undo
End Enum

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

Type StageCallBacks
	Render As Function(ByVal Context As Any Ptr, ByVal pRenderRectangles As RECT Ptr, ByVal Count As Integer)As Integer
	AnimateFunction As Function(ByVal Context As Any Ptr)As Integer
End Type

Type Stage
	Lines(0 To 8, 0 To 8) As Cell
	SelectedCellX As Integer
	SelectedCellY As Integer
	Tablo(0 To 2) As Cell
	MovedBall As ColorBall
	CallBacks As StageCallBacks
	Context As Any Ptr
	Score As Integer
	HiScore As Integer
End Type

Declare Function CreateStage( _
	ByVal HiScore As Integer, _
	ByVal CallBacks As StageCallBacks Ptr, _
	ByVal Context As Any Ptr _
)As Stage Ptr

Declare Sub DestroyStage( _
	ByVal pStage As Stage Ptr _
)

Declare Sub StageNewGame( _
	ByVal pStage As Stage Ptr _
)

Declare Function StageGetCellFromPoint( _
	ByVal pStage As Stage Ptr, _
	ByVal pp As POINT Ptr, _
	ByVal pCell As POINT Ptr _
)As Boolean

Declare Sub StageClick( _
	ByVal pStage As Stage Ptr, _
	ByVal pp As POINT Ptr _
)

Declare Sub StageKeyPress( _
	ByVal pStage As Stage Ptr, _
	ByVal Key As StageKeys _
)

Declare Function StageTick( _
	ByVal pStage As Stage Ptr _
)As Boolean

Declare Function StageCommand( _
	ByVal pStage As Stage Ptr, _
	ByVal cmd As StageCommands _
)As Boolean

Declare Function StageGetWidth( _
	ByVal pStage As Stage Ptr _
)As Integer

Declare Function StageGetHeight( _
	ByVal pStage As Stage Ptr _
)As Integer

#endif
