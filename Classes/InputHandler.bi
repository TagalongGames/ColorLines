#ifndef INPUTHANDLER_BI
#define INPUTHANDLER_BI

#include once "Scene.bi"
#include once "Stage.bi"

Type InputHandler As _InputHandler

Declare Function CreateInputHandler( _
	ByVal pStage As Stage Ptr, _
	ByVal pScene As Scene Ptr _
)As InputHandler Ptr

Declare Sub DestroyInputHandler( _
	ByVal pHandler As InputHandler Ptr _
)

Declare Sub InputHandlerLMouseDown( _
	ByVal pHandler As InputHandler Ptr, _
	ByVal pp As POINT Ptr _
)

Declare Sub InputHandlerLMouseUp( _
	ByVal pHandler As InputHandler Ptr, _
	ByVal pp As POINT Ptr _
)

Declare Sub InputHandlerKeyDown( _
	ByVal pHandler As InputHandler Ptr, _
	ByVal Key As Integer _
)

Declare Sub InputHandlerKeyUp( _
	ByVal pHandler As InputHandler Ptr, _
	ByVal Key As Integer _
)

#endif
