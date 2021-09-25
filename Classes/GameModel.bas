#include once "GameModel.bi"

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

Type _GameModel
	Events As StageEvents
	Context As Any Ptr
	SelectedCellX As Integer
	SelectedCellY As Integer
	SelectedBallX As Integer
	SelectedBallY As Integer
End Type

Sub GenerateTablo( _
		ByVal pModel As GameModel Ptr, _
		ByVal pStage As Stage Ptr _
	)
	
	For i As Integer = 0 To 2
		Dim RandomColor As BallColors = GetRandomBallColor()
		pStage->Tablo(i).Ball.Color = RandomColor
	Next
	
	pModel->Events.OnTabloChanged( _
		pModel->Context _
	)
	
End Sub

Function ExtractBalls( _
		ByVal pModel As GameModel Ptr, _
		ByVal pStage As Stage Ptr _
	)As Boolean
	
	For i As Integer = 0 To 2
		' ������� ��������� ��������� ������
		' ���� ������ ���, �� ������� ������
		Dim x As Integer = GetRandomStageX()
		Dim y As Integer = GetRandomStageY()
		
		Dim RandomColor As BallColors = pStage->Tablo(i).Ball.Color
		
		/'
		Dim buffer As WString * (255 + 1) = Any
		Const ffFormat = WStr("{%d, %d}, %d")
		swprintf(@buffer, @ffFormat, x, y, RandomColor)
		buffer[255] = 0
		MessageBoxW(NULL, @buffer, NULL, MB_OK)
		'/
		
		' ��������� �� ������� ����
		pStage->Lines(y, x).Ball.Color = RandomColor
		pStage->Lines(y, x).Ball.Frame = AnimationFrames.Birth0
		pStage->Lines(y, x).Ball.Visible = True
		
		' ���� ��� �����, �� ������� ������
		
		' ������� 5 � ���
		
		' ���� ���� ��������, �� ������������ ����� �� ����
		
	Next
	
	' Dim UpdateRectangle As RECT = Any
	' SetRect(@UpdateRectangle, _
		' pStage->Lines(0, 0).Rectangle.left, _
		' pStage->Lines(0, 0).Rectangle.top, _
		' pStage->Lines(8, 8).Rectangle.right, _
		' pStage->Lines(8, 8).Rectangle.bottom _
	' )
	' pModel->Events.OnChanged( _
		' pModel->Context, _
		' @UpdateRectangle, _
		' 1 _
	' )
	
	Return False
	
End Function

Function CreateGameModel( _
		ByVal pEvents As StageEvents Ptr, _
		ByVal Context As Any Ptr _
	)As GameModel Ptr
	
	Dim pModel As GameModel Ptr = Allocate(SizeOf(GameModel))
	If pModel = NULL Then
		Return NULL
	End If
	
	pModel->Events = *pEvents
	pModel->Context = Context
	pModel->SelectedCellX = 0
	pModel->SelectedCellY = 0
	pModel->SelectedBallX = 0
	pModel->SelectedBallY = 0
	
	Return pModel
	
End Function

Sub DestroyGameModel( _
		ByVal pModel As GameModel Ptr _
	)
	
	Deallocate(pModel)
	
End Sub

Sub GameModelNewGame( _
		ByVal pModel As GameModel Ptr, _
		ByVal pStage As Stage Ptr _
	)
	
	' ���������
	
	pStage->Score = 0
	pModel->Events.OnScoreChanged( _
		pModel->Context _
	)
	
	Dim pts(9 * 9 - 1) As POINT = Any
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			pStage->Lines(j, i).Ball.Frame = AnimationFrames.Stopped
			pStage->Lines(j, i).Ball.Visible = False
			pStage->Lines(j, i).Ball.Selected = False
			
			pts(j * 9 + i).x = i
			pts(j * 9 + i).y = j
		Next
	Next
	
	pModel->Events.OnLinesChanged( _
		pModel->Context, _
		@pts(0), _
		9 * 9 _
	)
	
	pStage->MovedBall.Frame = AnimationFrames.Stopped
	pStage->MovedBall.Visible = False
	
	pModel->Events.OnMovedBallChanged( _
		pModel->Context _
	)
	
	ExtractBalls(pModel, pStage)
	
	GenerateTablo(pModel, pStage)
	
End Sub

Sub GameModelLMouseDown( _
		ByVal pModel As GameModel Ptr, _
		ByVal pStage As Stage Ptr, _
		ByVal pScene As Scene Ptr, _
		ByVal pp As POINT Ptr _
	)
	
	' ���� �� ����� ������ � �� �������� ���������� ������
	' Dim CellCoord As POINT = Any
	' Dim b As Boolean = StageGetCellFromPoint( _
		' pStage, _
		' pp, _
		' @CellCoord _
	' )
	' If b Then
		' �������� ������
		' ���� ��� ����������, �� ���� ��� ��� ������ � ���������� � ������� ����� ���
		' ���� �� ���������� � ��� ������ � ����� ���� ��� ����������� � �����������
	' End If
	
End Sub

Sub GameModelKeyDown( _
		ByVal pModel As GameModel Ptr, _
		ByVal pStage As Stage Ptr, _
		ByVal Key As Integer _
	)
	
	Select Case Key
		
		Case VK_TAB
			' ������ �� ��������� ���
			
		Case StageKeys.ShiftTab
			' ���� Shift+TAB �� �� ���������� ���
			
		Case VK_SPACE, VK_RETURN
			' ����� ����, ���������� ������ ����
			If pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Ball.Visible Then
				
				pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Ball.Selected = Not pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Ball.Selected
				
				pModel->SelectedBallX = pModel->SelectedCellX
				pModel->SelectedBallY = pModel->SelectedCellY
				
				Dim pts As POINT = Any
				pts.x = pModel->SelectedCellX
				pts.y = pModel->SelectedCellY
				pModel->Events.OnLinesChanged( _
					pModel->Context, _
					@pts, _
					1 _
				)
			Else
				If pStage->Lines(pModel->SelectedBallY, pModel->SelectedBallX).Ball.Selected Then
					' ����������� ���
				End If
			End If
			
		Case VK_LEFT
			Dim pts(1) As POINT = Any
			pts(0).x = pModel->SelectedCellX
			pts(0).y = pModel->SelectedCellY
			
			pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Selected = False
			
			pModel->SelectedCellX -= 1
			If pModel->SelectedCellX < 0 Then
				pModel->SelectedCellX = 8
			End If
			pts(1).x = pModel->SelectedCellX
			pts(1).y = pModel->SelectedCellY
			
			pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Selected = True
			
			pModel->Events.OnLinesChanged( _
				pModel->Context, _
				@pts(0), _
				2 _
			)
			
		Case VK_UP
			Dim pts(1) As POINT = Any
			pts(0).x = pModel->SelectedCellX
			pts(0).y = pModel->SelectedCellY
			
			pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Selected = False
			
			pModel->SelectedCellY -= 1
			If pModel->SelectedCellY < 0 Then
				pModel->SelectedCellY = 8
			End If
			pts(1).x = pModel->SelectedCellX
			pts(1).y = pModel->SelectedCellY
			
			pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Selected = True
			
			pModel->Events.OnLinesChanged( _
				pModel->Context, _
				@pts(0), _
				2 _
			)
			
		Case VK_RIGHT
			Dim pts(1) As POINT = Any
			pts(0).x = pModel->SelectedCellX
			pts(0).y = pModel->SelectedCellY
			
			pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Selected = False
			
			pModel->SelectedCellX += 1
			If pModel->SelectedCellX > 8 Then
				pModel->SelectedCellX = 0
			End If
			pts(1).x = pModel->SelectedCellX
			pts(1).y = pModel->SelectedCellY
			
			pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Selected = True
			
			pModel->Events.OnLinesChanged( _
				pModel->Context, _
				@pts(0), _
				2 _
			)
			
		Case VK_DOWN
			Dim pts(1) As POINT = Any
			pts(0).x = pModel->SelectedCellX
			pts(0).y = pModel->SelectedCellY
			
			pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Selected = False
			
			pModel->SelectedCellY += 1
			If pModel->SelectedCellY > 8 Then
				pModel->SelectedCellY = 0
			End If
			pts(1).x = pModel->SelectedCellX
			pts(1).y = pModel->SelectedCellY
			
			pStage->Lines(pModel->SelectedCellY, pModel->SelectedCellX).Selected = True
			
			pModel->Events.OnLinesChanged( _
				pModel->Context, _
				@pts(0), _
				2 _
			)
			
		Case VK_ESCAPE
			' ����� ����� ����
			If pStage->Lines(pModel->SelectedBallY, pModel->SelectedBallX).Ball.Selected Then
				pStage->Lines(pModel->SelectedBallY, pModel->SelectedBallX).Ball.Selected = False
				
				Dim pts As POINT = Any
				pts.x = pModel->SelectedBallX
				pts.y = pModel->SelectedBallY
				pModel->Events.OnLinesChanged( _
					pModel->Context, _
					@pts, _
					1 _
				)
			End If
			
	End Select
	
End Sub

Function GameModelUpdate( _
		ByVal pModel As GameModel Ptr, _
		ByVal pStage As Stage Ptr _
	)As Boolean
	
	Return False
	
End Function

Function GameModelCommand( _
		ByVal pModel As GameModel Ptr, _
		ByVal pStage As Stage Ptr, _
		ByVal cmd As StageCommands _
	)As Boolean
	
	Return False
	
End Function
