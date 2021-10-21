#include once "EntryPoint.bi"
#include once "WinMain.bi"

#ifdef WITHOUT_RUNTIME
Sub ENTRYPOINT Alias "ENTRYPOINT"()
#endif
	
	Dim RetCode As Long = tWinMain( _
		GetModuleHandle(0), _
		NULL, _
		GetCommandLine(), _
		SW_SHOW _
	)
	
	#ifdef WITHOUT_RUNTIME
		ExitProcess(RetCode)
	#else
		End(RetCode)
	#endif
	
#ifdef WITHOUT_RUNTIME
End Sub
#endif
