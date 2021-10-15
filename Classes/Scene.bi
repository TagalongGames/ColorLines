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

Declare Sub SceneTranslateBounds( _
	ByVal pScene As Scene Ptr, _
	ByVal pObjectBounds As RECT Ptr, _
	ByVal pPosition As XFORM Ptr, _
	ByVal pScreenBounds As RECT Ptr _
)

Declare Sub SceneShear( _
	ByVal pScene As Scene Ptr, _
	ByVal Horizontal As Single, _
	ByVal Vertical As Single _
)

Declare Sub SceneScale( _
	ByVal pScene As Scene Ptr, _
	ByVal ScaleX As Single, _
	ByVal ScaleY As Single _
)

Declare Sub SceneReflect( _
	ByVal pScene As Scene Ptr, _
	ByVal x As Boolean, _
	ByVal y As Boolean _
)

Declare Sub SceneRRotate( _
	ByVal pScene As Scene Ptr, _
	ByVal AngleSine As Single, _
	ByVal AngleCosine As Single _
)

Declare Sub SceneLRotate( _
	ByVal pScene As Scene Ptr, _
	ByVal AngleSine As Single, _
	ByVal AngleCosine As Single _
)

Declare Sub SceneTranslate( _
	ByVal pScene As Scene Ptr, _
	ByVal dx As Single, _
	ByVal dy As Single _
)

Declare Sub SceneLoadIdentity( _
	ByVal pScene As Scene Ptr _
)

#endif
