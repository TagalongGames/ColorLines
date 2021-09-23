#include once "GameModel.bi"

Type _GameModel
	placeholder As Any Ptr
End Type

Sub GenerateTablo( _
		ByVal pStage As Stage Ptr _
	)
	
	For i As Integer = 0 To 2
		Dim RandomColor As BallColors = GetRandomBallColor()
		pStage->Tablo(i).Ball.Color = RandomColor
		pStage->Tablo(i).Ball.Exist = True
	Next
	
	Dim UpdateRectangle As RECT = Any
	SetRect(@UpdateRectangle, _
		pStage->Tablo(0).Rectangle.left, _
		pStage->Tablo(0).Rectangle.top, _
		pStage->Tablo(2).Rectangle.right, _
		pStage->Tablo(2).Rectangle.bottom _
	)
	pStage->CallBacks.Render( _
		pStage->Context, _
		@UpdateRectangle, _
		1 _
	)
	
End Sub

Function ExtractBalls( _
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
		pStage->Lines(y, x).Ball.Exist = True
		
		' ���� ��� �����, �� ������� ������
		
		' ������� 5 � ���
		
		' ���� ���� ��������, �� ������������ ����� �� ����
		
	Next
	
	Dim UpdateRectangle As RECT = Any
	SetRect(@UpdateRectangle, _
		pStage->Lines(0, 0).Rectangle.left, _
		pStage->Lines(0, 0).Rectangle.top, _
		pStage->Lines(8, 8).Rectangle.right, _
		pStage->Lines(8, 8).Rectangle.bottom _
	)
	pStage->CallBacks.Render( _
		pStage->Context, _
		@UpdateRectangle, _
		1 _
	)
	
	Return False
	
End Function

Function CreateGameModel( _
	)As GameModel Ptr
	
	Dim pModel As GameModel Ptr = Allocate(SizeOf(GameModel))
	If pModel = NULL Then
		Return NULL
	End If
	
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
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			pStage->Lines(j, i).Ball.Frame = AnimationFrames.Stopped
			pStage->Lines(j, i).Ball.Exist = False
		Next
	Next
	
	pStage->MovedBall.Frame = AnimationFrames.Stopped
	pStage->MovedBall.Exist = False
	
	ExtractBalls(pStage)
	GenerateTablo(pStage)
	
End Sub

Sub GameModelClick( _
		ByVal pStage As Stage Ptr, _
		ByVal pp As POINT Ptr _
	)
	
	' ���� �� ����� ������ � �� �������� ���������� ������
	Dim CellCoord As POINT = Any
	Dim b As Boolean = StageGetCellFromPoint( _
		pStage, _
		pp, _
		@CellCoord _
	)
	If b Then
		' �������� ������
		' ���� ��� ����������, �� ���� ��� ��� ������ � ���������� � ������� ����� ���
		' ���� �� ���������� � ��� ������ � ����� ���� ��� ����������� � �����������
	End If
	
End Sub

Sub GameModelKeyPress( _
		ByVal pStage As Stage Ptr, _
		ByVal Key As StageKeys _
	)
	
	Select Case Key
		Case StageKeys.Tab
			' ������ �� ��������� ���
		Case StageKeys.ShiftTab
			' ���� Shift+TAB �� �� ���������� ���
		Case StageKeys.KeyReturn
			' ����� ����, ���������� ������ ����
		Case StageKeys.Left
			' ������������� ���������������� ���������
			' ������ ���������
			pStage->Lines(pStage->SelectedCellY, pStage->SelectedCellX).Selected = False
			pStage->CallBacks.Render( _
				pStage->Context, _
				@pStage->Lines(pStage->SelectedCellY, pStage->SelectedCellX).Rectangle, _
				1 _
			)
			' ������� ����������
			pStage->SelectedCellX -= 1
			If pStage->SelectedCellX < 0 Then
				pStage->SelectedCellX = 8
			End If
			' ������������ �������������
			pStage->Lines(pStage->SelectedCellY, pStage->SelectedCellX).Selected = True
			pStage->CallBacks.Render( _
				pStage->Context, _
				@pStage->Lines(pStage->SelectedCellY, pStage->SelectedCellX).Rectangle, _
				1 _
			)
		Case StageKeys.Up
			' ������������� ���������������� ���������
			' ������ ���������
			pStage->Lines(pStage->SelectedCellY, pStage->SelectedCellX).Selected = False
			pStage->CallBacks.Render( _
				pStage->Context, _
				@pStage->Lines(pStage->SelectedCellY, pStage->SelectedCellX).Rectangle, _
				1 _
			)
			' ������� ����������
			pStage->SelectedCellY -= 1
			If pStage->SelectedCellY < 0 Then
				pStage->SelectedCellY = 8
			End If
			' ������������ �������������
			pStage->Lines(pStage->SelectedCellY, pStage->SelectedCellX).Selected = True
			pStage->CallBacks.Render( _
				pStage->Context, _
				@pStage->Lines(pStage->SelectedCellY, pStage->SelectedCellX).Rectangle, _
				1 _
			)
		Case StageKeys.Right
			' ������������� ���������������� ���������
			' ������ ���������
			pStage->Lines(pStage->SelectedCellY, pStage->SelectedCellX).Selected = False
			pStage->CallBacks.Render( _
				pStage->Context, _
				@pStage->Lines(pStage->SelectedCellY, pStage->SelectedCellX).Rectangle, _
				1 _
			)
			' ������� ����������
			pStage->SelectedCellX += 1
			If pStage->SelectedCellX > 8 Then
				pStage->SelectedCellX = 0
			End If
			' ������������ �������������
			pStage->Lines(pStage->SelectedCellY, pStage->SelectedCellX).Selected = True
			pStage->CallBacks.Render( _
				pStage->Context, _
				@pStage->Lines(pStage->SelectedCellY, pStage->SelectedCellX).Rectangle, _
				1 _
			)
		Case StageKeys.Down
			' ������������� ���������������� ���������
			' ������ ���������
			pStage->Lines(pStage->SelectedCellY, pStage->SelectedCellX).Selected = False
			pStage->CallBacks.Render( _
				pStage->Context, _
				@pStage->Lines(pStage->SelectedCellY, pStage->SelectedCellX).Rectangle, _
				1 _
			)
			' ������� ����������
			pStage->SelectedCellY += 1
			If pStage->SelectedCellY > 8 Then
				pStage->SelectedCellY = 0
			End If
			' ������������ �������������
			pStage->Lines(pStage->SelectedCellY, pStage->SelectedCellX).Selected = True
			pStage->CallBacks.Render( _
				pStage->Context, _
				@pStage->Lines(pStage->SelectedCellY, pStage->SelectedCellX).Rectangle, _
				1 _
			)
		Case StageKeys.Escape
			' ����� ����� ����
	End Select
	
End Sub

Function GameModelTick( _
		ByVal pStage As Stage Ptr _
	)As Boolean
	
	Return False
	
End Function

Function GameModelCommand( _
		ByVal pStage As Stage Ptr, _
		ByVal cmd As StageCommands _
	)As Boolean
	
	Return False
	
End Function
