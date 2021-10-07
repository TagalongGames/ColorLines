#include once "Settings.bi"
#include once "windows.bi"

Const RegSection = __TEXT("Software\TagalongGames\ColorLines\1.0.0.0")
Const RegKeyHiScore = __TEXT("HiScore")
Const RegKeyRenderType = __TEXT("RenderType")

' Dim ValueLength As DWORD = GetPrivateProfileStringW( _
	' @WebServerSectionString, _
	' @ListenAddressKeyString, _
	' @DefaultAddressString, _
	' @buf, _
	' Cast(DWORD, BufferLength), _
	' @this->WebServerIniFileName _
' )

Function OpenRegistry( _
		ByVal samDesired As REGSAM _
	)As HKEY
	
	Dim dwDisposition As DWORD = Any
	Dim hRegistry As HKEY = Any
	Dim hrOpen As Long = RegCreateKeyEx( _
		HKEY_CURRENT_USER, _ /' hKey '/
		@RegSection, _       /' lpSubKey '/
		0, _                 /' Reserved '/
		NULL, _              /' lpClass '/
		0, _                 /' dwOptions '/
		samDesired, _        /' samDesired '/
		NULL, _              /' lpSecurityAttributes '/
		@hRegistry, _        /' phkResult '/
		@dwDisposition _     /' lpdwDisposition '/
	)
	If hrOpen <> ERROR_SUCCESS Then
		Return NULL
	End If
	
	Return hRegistry
	
End Function

Function GetRegistrySettingsDword( _
		ByVal lpKey As LPCTSTR _
	)As DWORD
	
	Dim hRegistry As HKEY = OpenRegistry( _
		KEY_QUERY_VALUE _
	)
	If hRegistry = NULL Then
		Return 0
	End If
	
	Dim Value As DWORD = 0
	Dim ValueSize As DWORD = SizeOf(DWORD)
	Dim dwValueType As DWORD = REG_DWORD
	' Dim hrQuery As Long = RegQueryValueEx( _
	RegQueryValueEx( _
		hRegistry, _              /' hKey '/
		lpKey, _                  /' lpValueName '/
		NULL, _                   /' lpReserved '/
		@dwValueType, _           /' lpType '/
		CPtr(Byte Ptr, @Value), _ /' lpData '/
		@ValueSize _              /' lpcbData '/
	)
	' If hrQuery <> ERROR_SUCCESS Then
		' RegCloseKey(hRegistry)
		' Return 0
	' End If
	
	RegCloseKey(hRegistry)
	
	Return Value
	
End Function

Sub SetRegistrySettingsDword( _
		ByVal lpKey As LPCTSTR, _
		ByVal dwValue As DWORD _
	)
	
	Dim hRegistry As HKEY = OpenRegistry( _
		KEY_SET_VALUE _
	)
	If hRegistry = NULL Then
		Return
	End If
	
	' Dim hrSet As Long = RegSetValueEx( _
	RegSetValueEx( _
		hRegistry, _                /' hKey '/
		lpKey, _                    /' lpValueName '/
		0, _                        /' Reserved '/
		REG_DWORD, _                /' dwType '/
		CPtr(Byte Ptr, @dwValue), _ /' lpData '/
		SizeOf(DWORD) _             /' cbData '/
	)
	' If hrSet <> ERROR_SUCCESS Then
		' RegCloseKey(hRegistry)
	' End If
	
	RegCloseKey(hRegistry)
	
End Sub

Function SettingsGetHiScore( _
	)As Integer
	
	Dim dwHiScore As DWORD = GetRegistrySettingsDword(RegKeyHiScore)
	
	Return CInt(dwHiScore)
	
End Function

Sub SettingsSetHiScore( _
		ByVal HiScore As Integer _
	)
	
	SetRegistrySettingsDword(RegKeyHiScore, Cast(DWORD, HiScore))
	
End Sub

Function SettingsGetRenderType( _
	)As RenderType
	
	Dim dwRenderType As DWORD = GetRegistrySettingsDword(RegKeyRenderType)
	
	Return Cast(RenderType, dwRenderType)
	
End Function

Sub SettingsSetRenderType( _
		ByVal tRender As RenderType _
	)
	
	SetRegistrySettingsDword(RegKeyRenderType, Cast(DWORD, tRender))
	
End Sub

/'
Function SetSettingsValue( _
		ByVal Key As WString Ptr, _
		ByVal Value As WString Ptr _
	)As Boolean
	
	Dim reg As HKEY = Any
	Dim lpdwDisposition As DWORD = Any
	Dim hr As Long = RegCreateKeyEx(HKEY_CURRENT_USER, @RegSection, 0, 0, 0, KEY_SET_VALUE, NULL, @reg, @lpdwDisposition)
	
	If hr <> ERROR_SUCCESS Then
		Return False
	End If
	
	hr = RegSetValueEx(reg, Key, 0, REG_SZ, CPtr(Byte Ptr, Value), (lstrlen(Value) + 1) * SizeOf(WString))
	If hr <> ERROR_SUCCESS Then
		RegCloseKey(reg)
		Return False
	End If
	
	RegCloseKey(reg)
	
	Return True
	
End Function

Function GetSettingsValue( _
		ByVal Buffer As WString Ptr, _
		ByVal BufferLength As Integer, _
		ByVal Key As WString Ptr _
	)As Integer
	
	Dim reg As HKEY = Any
	Dim lpdwDisposition As DWORD = Any
	Dim hr As Long = RegCreateKeyEx(HKEY_CURRENT_USER, @RegSection, 0, 0, 0, KEY_QUERY_VALUE, NULL, @reg, @lpdwDisposition)

	If hr <> ERROR_SUCCESS Then
		Return -1
	End If
	
	Dim pdwType As DWORD = RRF_RT_REG_SZ
	Dim BufferLength2 As DWORD = (BufferLength + 1) * SizeOf(WString)
	hr = RegQueryValueEx(reg, Key, 0, @pdwType, CPtr(Byte Ptr, Buffer), @BufferLength2)
	If hr <> ERROR_SUCCESS Then
		RegCloseKey(reg)
		Return -1
	End If
	
	RegCloseKey(reg)
	
	Return BufferLength \ SizeOf(WString) - 1
	
End Function

Function SetSettingsValue( _
		ByVal Key As WString Ptr, _
		ByVal Value As WString Ptr _
	)As Boolean
	
	Dim reg As HKEY = Any
	Dim lpdwDisposition As DWORD = Any
	Dim hr As Long = RegCreateKeyEx(HKEY_CURRENT_USER, @RegSection, 0, 0, 0, KEY_SET_VALUE, NULL, @reg, @lpdwDisposition)
	
	If hr <> ERROR_SUCCESS Then
		Return False
	End If
	
	hr = RegSetValueEx(reg, Key, 0, REG_SZ, CPtr(Byte Ptr, Value), (lstrlen(Value) + 1) * SizeOf(WString))
	If hr <> ERROR_SUCCESS Then
		RegCloseKey(reg)
		Return False
	End If
	
	RegCloseKey(reg)
	
	Return True
	
End Function
'/
