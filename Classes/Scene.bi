#ifndef SCENE_BI
#define SCENE_BI

#include once "Stage.bi"

Type Scene As _Scene

Declare Function CreateScene( _
	ByVal hWin As HWND, _
	ByVal nWidth As UINT, _
	ByVal nHeight As UINT _
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

#endif
