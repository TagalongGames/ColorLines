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

' {6352DA7B-D2A3-4BD5-AD71-BD946D03CC25}
DEFINE_GUID(CLSID_DESELECTBALLCOMMAND, _
	&h6352da7b, &hd2a3, &h4bd5, &had, &h71, &hbd, &h94, &h6d, &h3, &hcc, &h25 _
)

' {AD4D5980-343D-4916-A2D9-158775DB0546}
DEFINE_CLSID(CLSID_EMPTYCOMMAND, _
	&had4d5980, &h343d, &h4916, &ha2, &hd9, &h15, &h87, &h75, &hdb, &h5, &h46 _
)

' {4D1199EB-2DD9-4969-9BD8-CDF3FB2B7A5E}
DEFINE_CLSID(CLSID_MOVESELECTIONRECTANGLECOMMAND, _
	&h4d1199eb, &h2dd9, &h4969, &h9b, &hd8, &hcd, &hf3, &hfb, &h2b, &h7a, &h5e _
)

' {C3637BCB-9A0A-4D5D-95C4-025F1291A95A}
DEFINE_GUID(CLSID_PULLCELLCOMMAND, _
	&hc3637bcb, &h9a0a, &h4d5d, &h95, &hc4, &h2, &h5f, &h12, &h91, &ha9, &h5a _
)

' {B6041150-B0F2-4FED-8A8A-72A9652627AA}
DEFINE_GUID(CLSID_PUSHCELLCOMMAND, _
	&hb6041150, &hb0f2, &h4fed, &h8a, &h8a, &h72, &ha9, &h65, &h26, &h27, &haa _
)

' {F6369A61-726B-4617-A6B2-50FF97FDE53E}
DEFINE_IID(IID_ICommand, _
	&hf6369a61, &h726b, &h4617, &ha6, &hb2, &h50, &hff, &h97, &hfd, &he5, &h3e _
)

' {08D2995E-05B1-4EA9-9956-973DA96AE64F}
DEFINE_GUID(IID_IDeselectBallCommand, _
	&h8d2995e, &h5b1, &h4ea9, &h99, &h56, &h97, &h3d, &ha9, &h6a, &he6, &h4f _
)

' {22A3603C-85C8-45EA-B839-C696663F74DA}
DEFINE_IID(IID_IMoveSelectionRectangleCommand, _
	&h22a3603c, &h85c8, &h45ea, &hb8, &h39, &hc6, &h96, &h66, &h3f, &h74, &hda _
)

' {BC01FF80-7328-4217-9E65-87926120BF3B}
DEFINE_GUID(IID_IPullCellCommand, _
	&hbc01ff80, &h7328, &h4217, &h9e, &h65, &h87, &h92, &h61, &h20, &hbf, &h3b _
)

' {F518590C-8A2F-4386-9341-E01ADCC747AD}
DEFINE_GUID(IID_IPushCellCommand, _
	&hf518590c, &h8a2f, &h4386, &h93, &h41, &he0, &h1a, &hdc, &hc7, &h47, &had _
)
