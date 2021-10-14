#include once "CreateInstance.bi"
#include once "DeselectBallCommand.bi"
#include once "EmptyCommand.bi"
#include once "MoveSelectionRectangleCommand.bi"
#include once "PullCellCommand.bi"
#include once "PushCellCommand.bi"

Function CreateInstance( _
		ByVal rclsid As REFCLSID, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	*ppv = NULL
	
	If IsEqualCLSID(@CLSID_DESELECTBALLCOMMAND, rclsid) Then
		Dim pCommand As DeselectBallCommand Ptr = CreateDeselectBallCommand()
		If pCommand = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = DeselectBallCommandQueryInterface(pCommand, riid, ppv)
		If FAILED(hr) Then
			DestroyDeselectBallCommand(pCommand)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_EMPTYCOMMAND, rclsid) Then
		Dim pCommand As EmptyCommand Ptr = CreateEmptyCommand()
		If pCommand = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = EmptyCommandQueryInterface(pCommand, riid, ppv)
		If FAILED(hr) Then
			DestroyEmptyCommand(pCommand)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_MOVESELECTIONRECTANGLECOMMAND, rclsid) Then
		Dim pCommand As MoveSelectionRectangleCommand Ptr = CreateMoveSelectionRectangleCommand()
		If pCommand = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = MoveSelectionRectangleCommandQueryInterface(pCommand, riid, ppv)
		If FAILED(hr) Then
			DestroyMoveSelectionRectangleCommand(pCommand)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_PULLCELLCOMMAND, rclsid) Then
		Dim pCommand As PullCellCommand Ptr = CreatePullCellCommand()
		If pCommand = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = PullCellCommandQueryInterface(pCommand, riid, ppv)
		If FAILED(hr) Then
			DestroyPullCellCommand(pCommand)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_PUSHCELLCOMMAND, rclsid) Then
		Dim pCommand As PushCellCommand Ptr = CreatePushCellCommand()
		If pCommand = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = PushCellCommandQueryInterface(pCommand, riid, ppv)
		If FAILED(hr) Then
			DestroyPushCellCommand(pCommand)
		End If
		
		Return hr
	End If
	
	Return CLASS_E_CLASSNOTAVAILABLE
	
End Function
