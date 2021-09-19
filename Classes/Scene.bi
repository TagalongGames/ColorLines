#ifndef SCENE_BI
#define SCENE_BI

#include once "Stage.bi"

Type Scene As _Scene

Declare Function CreateScene( _
	ByVal hWin As HWND, _
	ByVal ScreenWidth As UINT, _
	ByVal ScreenHeight As UINT _
)As Scene Ptr

Declare Sub DestroyScene( _
	ByVal pScene As Scene Ptr _
)

Declare Sub SceneRender( _
	ByVal pScene As Scene Ptr, _
	ByVal pStage As Stage Ptr _
)

Declare Sub SceneCopyRectangle( _
	ByVal pScene As Scene Ptr, _
	ByVal hDCDestination As HDC, _
	ByVal pRectangle As RECT Ptr _
)

Declare Sub SceneTranslateRectangle( _
	ByVal pScene As Scene Ptr, _
	ByVal pStage As Stage Ptr, _
	ByVal pRectangle As RECT Ptr, _
	ByVal pTranslatedRectangle As RECT Ptr _
)

Declare Sub SceneClick( _
	ByVal pScene As Scene Ptr, _
	ByVal pStage As Stage Ptr, _
	ByVal pScreenPoint As POINT Ptr _
)

Declare Sub SceneSetProjectionMatrix( _
	ByVal pScene As Scene Ptr, _
	ByVal pProjectionMatrix As XFORM Ptr _
)

Declare Sub SceneSetViewMatrix( _
	ByVal pScene As Scene Ptr, _
	ByVal pViewMatrix As XFORM Ptr _
)

Declare Sub SceneSetWorldMatrix( _
	ByVal pScene As Scene Ptr, _
	ByVal pWorldMatrix As XFORM Ptr _
)

#endif
