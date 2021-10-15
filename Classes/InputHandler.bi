#ifndef INPUTHANDLER_BI
#define INPUTHANDLER_BI

#include once "ICommand.bi"
#include once "GameModel.bi"
#include once "Scene.bi"
#include once "Stage.bi"

Type InputHandler As _InputHandler

Declare Function CreateInputHandler( _
	ByVal pStage As Stage Ptr, _
	ByVal pScene As Scene Ptr, _
	ByVal pModel As GameModel Ptr _
)As InputHandler Ptr

Declare Sub DestroyInputHandler( _
	ByVal pHandler As InputHandler Ptr _
)

/'
	Returns OK:
		S_OK
		S_FALSE
	Returns FAIL:
		Any error code
'/
Declare Function InputHandlerLMouseDown( _
	ByVal pHandler As InputHandler Ptr, _
	ByVal pp As POINT Ptr, _
	ByVal ppvObject As Any Ptr Ptr _
)As HRESULT

Declare Function InputHandlerLMouseUp( _
	ByVal pHandler As InputHandler Ptr, _
	ByVal pp As POINT Ptr, _
	ByVal ppvObject As Any Ptr Ptr _
)As HRESULT

Declare Function InputHandlerKeyDown( _
	ByVal pHandler As InputHandler Ptr, _
	ByVal Key As Integer, _
	ByVal ppvObject As Any Ptr Ptr _
)As HRESULT

Declare Function InputHandlerKeyUp( _
	ByVal pHandler As InputHandler Ptr, _
	ByVal Key As Integer, _
	ByVal ppvObject As Any Ptr Ptr _
)As HRESULT

#endif
