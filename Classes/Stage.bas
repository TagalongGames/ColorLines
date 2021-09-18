#include once "Stage.bi"
#include once "crt.bi"

Const CellWidth As UINT = 40
Const CellHeight As UINT = 40
Const BallWidth As UINT = 30
Const BallHeight As UINT = 30
Const BallMarginWidth As UINT = (CellWidth - BallWidth) \ 2
Const BallMarginHeight As UINT = (CellHeight - BallHeight) \ 2

Function GetRandomBoolean()As Boolean
	
	Dim RndValue As Long = rand()
	
	If RndValue > RAND_MAX \ 2 Then
		Return True
	End If
	
	Return False
	
End Function

Function GetRandomBallColor()As BallColors
	
	Dim RndValue As Long = rand()
	
	Return Cast(BallColors, RndValue Mod 7)
	
End Function

Function GetRandomStageX()As Integer
	
	Dim RndValue As Long = rand()
	
	Return CInt(RndValue Mod 9)
	
End Function

Function GetRandomStageY()As Integer
	
	Dim RndValue As Long = rand()
	
	Return CInt(RndValue Mod 9)
	
End Function

Function CreateStage( _
		ByVal HiScore As Integer, _
		ByVal CallBacks As StageCallBacks Ptr, _
		ByVal Context As Any Ptr _
	)As Stage Ptr
	
	Dim pStage As Stage Ptr = Allocate(SizeOf(Stage))
	If pStage = NULL Then
		Return NULL
	End If
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			SetRect(@pStage->Lines(j, i).Rectangle, _
				i * CellWidth, _
				j * CellHeight, _
				i * CellWidth + CellWidth, _
				j * CellHeight + CellHeight _
			)
			
			Scope
				' pStage->Lines(j, i).Ball.Color = BallColors.Red
				pStage->Lines(j, i).Ball.Frame = AnimationFrames.Stopped
				
				SetRect(@pStage->Lines(j, i).Ball.Rectangle, _
					i * CellWidth + BallMarginWidth, _
					j * CellHeight + BallMarginHeight, _
					i * CellWidth + CellWidth - BallMarginWidth, _
					j * CellHeight + CellHeight - BallMarginHeight _
				)
				' pStage->Lines(j, i).Ball.Exist = True
			End Scope
			
			pStage->Lines(j, i).Selected = False
			
		Next
	Next
	
	pStage->Lines(0, 0).Selected = True
	
	For j As Integer = 0 To 2
		
		CopyRect(@pStage->Tablo(j).Rectangle, @pStage->Lines(j + 1, 8).Rectangle)
		OffsetRect(@pStage->Tablo(j).Rectangle, 2 * CellWidth, 0)
		
		CopyRect(@pStage->Tablo(j).Ball.Rectangle, @pStage->Lines(j + 1, 8).Ball.Rectangle)
		OffsetRect(@pStage->Tablo(j).Ball.Rectangle, 2 * CellWidth, 0)
		
		pStage->Tablo(j).Selected = False
		
	Next
	
	' pStage->MovedBall.Color = BallColors.Red
	pStage->MovedBall.Frame = AnimationFrames.Stopped
	' pStage->MovedBall.Rectangle = False
	pStage->MovedBall.Exist = False
	
	pStage->CallBacks = *CallBacks
	pStage->Context = Context
	pStage->Score = 0
	pStage->HiScore = HiScore
	
	Return pStage
	
End Function

Sub DestroyStage( _
		ByVal pStage As Stage Ptr _
	)
	
	Deallocate(pStage)
	
End Sub

Sub StageNewGame( _
		ByVal pStage As Stage Ptr _
	)
	
	' Обнуление
	
	pStage->Score = 0
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			pStage->Lines(j, i).Ball.Frame = AnimationFrames.Stopped
			pStage->Lines(j, i).Ball.Exist = False
		Next
	Next
	
	For i As Integer = 0 To 2
		pStage->Tablo(i).Ball.Frame = AnimationFrames.Stopped
		pStage->Tablo(i).Ball.Exist = False
	Next
	
	pStage->MovedBall.Frame = AnimationFrames.Stopped
	pStage->MovedBall.Exist = False
	
	For i As Integer = 0 To 2
		' Выбрать случайные координаты и цвет
		Dim x As Integer = GetRandomStageX()
		Dim y As Integer = GetRandomStageY()
		Dim RandomColor As BallColors = GetRandomBallColor()
		
		/'
		Dim buffer As WString * (255 + 1) = Any
		Const ffFormat = WStr("{%d, %d}, %d")
		swprintf(@buffer, @ffFormat, x, y, RandomColor)
		buffer[255] = 0
		MessageBoxW(NULL, @buffer, NULL, MB_OK)
		'/
		
		' Поместить на игровое поле
		pStage->Lines(y, x).Ball.Color = RandomColor
		pStage->Lines(y, x).Ball.Frame = AnimationFrames.Birth0
		pStage->Lines(y, x).Ball.Exist = True
	Next
	
	For i As Integer = 0 To 2
		' Выбрать случайные цвета
		' Поместить в табло
		Dim RandomColor As BallColors = GetRandomBallColor()
		pStage->Tablo(i).Ball.Color = RandomColor
		pStage->Tablo(i).Ball.Frame = AnimationFrames.Stopped
		pStage->Tablo(i).Ball.Exist = True
	Next
	
	Dim UpdateRectangle(1) As RECT = Any
	SetRect(@UpdateRectangle(0), _
		pStage->Lines(0, 0).Rectangle.left, _
		pStage->Lines(0, 0).Rectangle.top, _
		pStage->Lines(8, 8).Rectangle.right, _
		pStage->Lines(8, 8).Rectangle.bottom _
	)
	SetRect(@UpdateRectangle(1), _
		pStage->Tablo(0).Rectangle.left, _
		pStage->Tablo(0).Rectangle.top, _
		pStage->Tablo(2).Rectangle.right, _
		pStage->Tablo(2).Rectangle.bottom _
	)
	pStage->CallBacks.Render( _
		pStage->Context, _
		@UpdateRectangle(0), _
		2 _
	)
	
End Sub

Function StageGetCellFromPoint( _
		ByVal pStage As Stage Ptr, _
		ByVal pp As POINT Ptr, _
		ByVal pCell As POINT Ptr _
	)As Boolean
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			If PtInRect(@pStage->Lines(j, i).Rectangle, *pp) Then
				pCell->x = i
				pCell->y = j
				Return True
			End If
		Next
	Next
	
	pCell->x = 0
	pCell->y = 0
	
	Return False
	
End Function

Sub StageClick( _
		ByVal pStage As Stage Ptr, _
		ByVal pp As POINT Ptr _
	)
	
	' Если мы можем тыкать — то получить координаты ячейки
	Dim CellCoord As POINT = Any
	Dim b As Boolean = StageGetCellFromPoint( _
		pStage, _
		pp, _
		@CellCoord _
	)
	If b Then
		' Получить ячейку
		' Если она существует, то если шар был выбран — развыбрать и выбрать новый шар
		' Если не существует и шар выбран — найти путь для перемещения и переместить
	End If
	
End Sub

Sub StageKeyPress( _
		ByVal pStage As Stage Ptr, _
		ByVal Key As StageKeys _
	)
	
End Sub

Function StageTick( _
		ByVal pStage As Stage Ptr _
	)As Boolean
	
	Return False
	
End Function

Function StageCommand( _
		ByVal pStage As Stage Ptr, _
		ByVal cmd As StageCommands _
	)As Boolean
	
	Return False
	
End Function

Function StageGetWidth( _
		ByVal pStage As Stage Ptr _
	)As Integer
	
	Return pStage->Lines(0, 0).Rectangle.left + pStage->Tablo(0).Rectangle.right
	
End Function

Function StageGetHeight( _
		ByVal pStage As Stage Ptr _
	)As Integer
	
	Return pStage->Lines(0, 0).Rectangle.top + pStage->Lines(8, 0).Rectangle.bottom
	
End Function
