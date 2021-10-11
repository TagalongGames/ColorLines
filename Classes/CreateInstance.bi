#ifndef CREATEINSTANCE_BI
#define CREATEINSTANCE_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Declare Function CreateInstance( _
	ByVal rclsid As REFCLSID, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
