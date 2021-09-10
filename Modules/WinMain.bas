#include once "WinMain.bi"
#include once "win\commctrl.bi"
#include once "win\GdiPlus.bi"
#include once "ColorLinesWndProc.bi"
#include once "Resources.RH"
#include once "DisplayError.bi"

Const MainWindowClassName = __TEXT("ColorLines")

Const COMMONCONTROLS_ERRORSTRING = __TEXT("Failed to register Common Controls")
Const REGISTERWINDOWCLASS_ERRORSTRING = __TEXT("Failed to register WNDCLASSEX")
Const CREATEWINDOW_ERRORSTRING = __TEXT("Failed to create Main Window")
Const GETMESSAGE_ERRORSTRING = __TEXT("Error in GetMessage")
Const GDIPLUS_ERRORSTRING = __TEXT("Failed to initialize GDIPlus")

Function wWinMain( _
		Byval hInst As HINSTANCE, _
		ByVal hPrevInstance As HINSTANCE, _
		ByVal lpCmdLine As LPWSTR, _
		ByVal iCmdShow As Long _
	)As Long
	
	' GDI+ Initialize
	Dim gsi As GdiPlus.GdiplusStartupInput = Any
	ZeroMemory(@gsi, SizeOf(GdiPlus.GdiplusStartupInput))
	gsi.GdiplusVersion = 1
	Dim GdiplusToken As ULONG_PTR = Any
	Dim st As GdiPlus.GpStatus = GdiPlus.GdiplusStartup(@GdiplusToken, @gsi, NULL)
	If st <> GdiPlus.Ok Then
		DisplayError(st, GDIPLUS_ERRORSTRING)
		Return 1
	End If
	
	Scope
		Dim icc As INITCOMMONCONTROLSEX = Any
		icc.dwSize = SizeOf(INITCOMMONCONTROLSEX)
		icc.dwICC = ICC_ANIMATE_CLASS Or _
			ICC_BAR_CLASSES Or _
			ICC_COOL_CLASSES Or _
			ICC_DATE_CLASSES Or _
			ICC_HOTKEY_CLASS Or _
			ICC_INTERNET_CLASSES Or _
			ICC_LINK_CLASS Or _
			ICC_LISTVIEW_CLASSES Or _
			ICC_NATIVEFNTCTL_CLASS Or _
			ICC_PAGESCROLLER_CLASS Or _
			ICC_PROGRESS_CLASS Or _
			ICC_STANDARD_CLASSES Or _
			ICC_TAB_CLASSES Or _
			ICC_TREEVIEW_CLASSES Or _
			ICC_UPDOWN_CLASS Or _
			ICC_USEREX_CLASSES Or _
		ICC_WIN95_CLASSES
		
		If InitCommonControlsEx(@icc) = False Then
			DisplayError(GetLastError(), COMMONCONTROLS_ERRORSTRING)
			Return 1
		End If
	End Scope
	
	Scope
		Dim wcls As WNDCLASSEX = Any
		With wcls
			.cbSize        = SizeOf(WNDCLASSEX)
			.style         = CS_HREDRAW Or CS_VREDRAW
			.lpfnWndProc   = @MainFormWndProc
			.cbClsExtra    = 0
			.cbWndExtra    = 0
			.hInstance     = hInst
			.hIcon         = LoadIcon(hInst, Cast(TCHAR Ptr, IDI_MAIN))
			.hCursor       = LoadCursor(NULL, IDC_ARROW)
			.hbrBackground = NULL
			.lpszMenuName  = Cast(LPTSTR, IDM_MENU)
			.lpszClassName = @MainWindowClassName
			.hIconSm       = NULL
		End With
		
		If RegisterClassEx(@wcls) = FALSE Then
			DisplayError(GetLastError(), REGISTERWINDOWCLASS_ERRORSTRING)
			Return 1
		End If
	End Scope
	
	Scope
		Dim WindowWidth As Long = 640
		Dim WindowHeight As Long = 480
		
		Dim WindowText(255) As TCHAR = Any
		LoadString(hInst, IDS_WINDOWTITLE, @WindowText(0), 255)
		
		Const WindowPositionX As Long = 0
		Const WindowPositionY As Long = 0
		Const StyleEx As DWORD = WS_EX_OVERLAPPEDWINDOW
		Const Style As DWORD = WS_OVERLAPPEDWINDOW
		
		Dim hWndMain As HWND = CreateWindowEx( _
			StyleEx, _
			@MainWindowClassName, _
			@WindowText(0), _
			Style, _
			CW_USEDEFAULT, _
			CW_USEDEFAULT, _
			WindowWidth, _
			WindowHeight, _
			NULL, _
			Cast(HMENU, NULL), _
			hInst, _
			NULL _
		)
		If hWndMain = NULL Then
			DisplayError(GetLastError(), CREATEWINDOW_ERRORSTRING)
			Return 1
		End If
		
		ShowWindow(hWndMain, iCmdShow)
		UpdateWindow(hWndMain)
	End Scope
	
	Scope
		Dim wMsg As MSG = Any
		Dim GetMessageResult As Integer = GetMessage(@wMsg, NULL, 0, 0)
		
		Do While GetMessageResult <> 0
			
			If GetMessageResult = -1 Then
				DisplayError(GetLastError(), GETMESSAGE_ERRORSTRING)
				Return 1
			End If
			
			TranslateMessage(@wMsg)
			DispatchMessage(@wMsg)
			
			GetMessageResult = GetMessage(@wMsg, NULL, 0, 0)
			
		Loop
		
		' GDI+ Uninitialize
		GdiPlus.GdiplusShutdown(GdiplusToken)
		
		Return wMsg.WPARAM
	End Scope
	
End Function
