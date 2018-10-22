// stdafx.h : include file for standard system include files,
//  or project specific include files that are used frequently, but
//      are changed infrequently
//

#if !defined(AFX_STDAFX_H__B7BB5EF7_0CB6_11D5_B1F8_00508B8F0099__INCLUDED_)
#define AFX_STDAFX_H__B7BB5EF7_0CB6_11D5_B1F8_00508B8F0099__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#define VC_EXTRALEAN		// Exclude rarely-used stuff from Windows headers

#include <afx.h>
#include <afxwin.h>
#include <viString.h>

// TODO: reference additional headers your program requires here

#ifdef _DEBUG

	CviString g_TraceString;

	#ifndef VITRACE0
		#define VITRACE(a) \
		static CviString g_TraceString; g_TraceString=a; OutputDebugString( g_TraceString.operator LPCTSTR() );
	#endif

	#ifndef VITRACE1
		#define VITRACE1(a,b) \
		static CviString g_TraceString; g_TraceString.Format(a,b); OutputDebugString( g_TraceString.operator LPCTSTR() );
	#endif

	#ifndef VITRACE2
		#define VITRACE2(a,b,c) \
		static CviString g_TraceString; g_TraceString.Format(a,b,c); OutputDebugString( g_TraceString.operator LPCTSTR() );
	#endif

	#ifndef VITRACE3
		#define VITRACE3(a,b,c,d) \
		static CviString g_TraceString; g_TraceString.Format(a,b,c,d); OutputDebugString( g_TraceString.operator LPCTSTR() );
	#endif
#else
	#ifndef VITRACE0
		#define VITRACE(a)
	#endif

	#ifndef VITRACE1
		#define VITRACE1(a,b) 
	#endif

	#ifndef VITRACE2
		#define VITRACE2(a,b,c)
	#endif

	#ifndef VITRACE3
		#define VITRACE3(a,b,c,d)
	#endif

#endif


//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDAFX_H__B7BB5EF7_0CB6_11D5_B1F8_00508B8F0099__INCLUDED_)
