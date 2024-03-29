#include once "WinMain.bi"
#include once "win\commctrl.bi"
#include once "win\GdiPlus.bi"
#include once "DisplayError.bi"
#include once "MainFormWndProc.bi"
#include once "Resources.RH"

Const MainWindowClassName = __TEXT("ColorLines")

Const COMMONCONTROLS_ERRORSTRING = __TEXT("Failed to register Common Controls")
Const REGISTERWINDOWCLASS_ERRORSTRING = __TEXT("Failed to register WNDCLASSEX")
Const CREATEWINDOW_ERRORSTRING = __TEXT("Failed to create Main Window")
Const GETMESSAGE_ERRORSTRING = __TEXT("Error in GetMessage")
Const GDIPLUS_ERRORSTRING = __TEXT("Failed to initialize GDIPlus")
Const ACCELERATOR_ERRORSTRING = __TEXT("Failed to load Accelerators")

Const TCHARFIXEDVECTOR_CAPACITY As Integer = 512

Type TCharFixedVector
	Buffer(TCHARFIXEDVECTOR_CAPACITY - 1 + 1) As TCHAR
End Type

Function wWinMain Alias "wWinMain"( _
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
		Dim hAccel As HACCEL = LoadAccelerators(hInst, Cast(TCHAR Ptr, ID_ACCEL))
		If hAccel = NULL Then
			DisplayError(GetLastError(), ACCELERATOR_ERRORSTRING)
			Return 1
		End If
		
		Dim WindowText As TCharFixedVector = Any
		LoadString(hInst, IDS_WINDOWTITLE, @WindowText.Buffer(0), TCHARFIXEDVECTOR_CAPACITY)
		
		Dim hWndMain As HWND = CreateWindowEx( _
			WS_EX_OVERLAPPEDWINDOW, _
			@MainWindowClassName, _
			@WindowText.Buffer(0), _
			WS_OVERLAPPEDWINDOW, _
			CW_USEDEFAULT, _
			CW_USEDEFAULT, _
			CW_USEDEFAULT, _
			CW_USEDEFAULT, _
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
		
		Dim wMsg As MSG = Any
		Dim GetMessageResult As Integer = GetMessage(@wMsg, NULL, 0, 0)
		
		Do While GetMessageResult <> 0
			
			If GetMessageResult = -1 Then
				DisplayError(GetLastError(), GETMESSAGE_ERRORSTRING)
				Return 1
			End If
			
			If TranslateAccelerator(hWndMain, hAccel, @wMsg) = 0 Then
				TranslateMessage(@wMsg)
				DispatchMessage(@wMsg)
			End If
			
			GetMessageResult = GetMessage(@wMsg, NULL, 0, 0)
			
		Loop
		
		' GDI+ Uninitialize
		GdiPlus.GdiplusShutdown(GdiplusToken)
		
		Return wMsg.WPARAM
	End Scope
	
End Function
