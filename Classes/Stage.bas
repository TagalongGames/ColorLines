#include once "Stage.bi"

Function GetRandomBoolean()As Boolean
	
	Dim RndValue As Long = rand()
	
	If RndValue > RAND_MAX \ 2 Then
		Return True
	End If
	
	Return False
	
End Function

Function GetRandomBallColor()As BallColors
	
	Const SevenPart As Long = RAND_MAX \ 7
	Dim RndValue As Long = rand()
	
	Return Cast(BallColors, RndValue Mod 7)
	
End Function

Function CreateStage( _
		ByVal HiScore As Integer _
	)As Stage Ptr
	
	Dim pStage As Stage Ptr = Allocate(SizeOf(Stage))
	If pStage = NULL Then
		Return NULL
	End If
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			' Dim RndExists As Boolean = GetRandomBoolean()
			pStage->Lines(j, i).Ball.Exist = True 'RndExists
			
			Dim RndColor As BallColors = GetRandomBallColor()
			pStage->Lines(j, i).Ball.Color = RndColor
		Next
	Next
	
	' Три случайных цвета
	
	
	Return pStage
	
End Function

Sub DestroyStage( _
		ByVal pStage As Stage Ptr _
	)
	
	Deallocate(pStage)
	
End Sub
