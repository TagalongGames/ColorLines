#ifndef SETTINGS_BI
#define SETTINGS_BI

Enum RenderType
	RenderTypeGdi = 0
	RenderTypeGdiPlus = 1
End Enum

Declare Function SettingsGetHiScore( _
)As Integer

Declare Sub SettingsSetHiScore( _
	ByVal HiScore As Integer _
)

Declare Function SettingsGetRenderType( _
)As RenderType

Declare Sub SettingsSetRenderType( _
	ByVal tRender As RenderType _
)

#endif
