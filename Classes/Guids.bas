#include once "windows.bi"

#ifndef DEFINE_GUID
#define DEFINE_GUID(n, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8) Extern n Alias #n As Const GUID : _ 
	Dim n As Const GUID = Type(l, w1, w2, {b1, b2, b3, b4, b5, b6, b7, b8})
#endif

#ifndef DEFINE_IID
#define DEFINE_IID(n, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8) Extern n Alias #n As Const IID : _ 
	Dim n As Const IID = Type(l, w1, w2, {b1, b2, b3, b4, b5, b6, b7, b8})
#endif

#ifndef DEFINE_CLSID
#define DEFINE_CLSID(n, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8) Extern n Alias #n As Const CLSID : _ 
	Dim n As Const CLSID = Type(l, w1, w2, {b1, b2, b3, b4, b5, b6, b7, b8})
#endif

#ifndef DEFINE_LIBID
#define DEFINE_LIBID(n, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8) Extern n Alias #n As Const GUID : _ 
	Dim n As Const GUID = Type(l, w1, w2, {b1, b2, b3, b4, b5, b6, b7, b8})
#endif

' {4D1199EB-2DD9-4969-9BD8-CDF3FB2B7A5E}
DEFINE_CLSID(CLSID_MOVESELECTIONRECTANGLECOMMAND, _
	&h4d1199eb, &h2dd9, &h4969, &h9b, &hd8, &hcd, &hf3, &hfb, &h2b, &h7a, &h5e _
)

' {F6369A61-726B-4617-A6B2-50FF97FDE53E}
DEFINE_IID(IID_ICommand, _
	&hf6369a61, &h726b, &h4617, &ha6, &hb2, &h50, &hff, &h97, &hfd, &he5, &h3e _
)

' {22A3603C-85C8-45EA-B839-C696663F74DA}
DEFINE_IID(IID_IMoveSelectionRectangleCommand, _
	&h22a3603c, &h85c8, &h45ea, &hb8, &h39, &hc6, &h96, &h66, &h3f, &h74, &hda _
)
