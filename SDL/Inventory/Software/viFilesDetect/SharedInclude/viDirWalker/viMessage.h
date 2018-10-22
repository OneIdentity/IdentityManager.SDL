// viMessage.h: interface for the CviMessage class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_VIMESSAGE_H__DFCBA7B6_FB42_11D4_B1E4_00508B8F0099__INCLUDED_)
#define AFX_VIMESSAGE_H__DFCBA7B6_FB42_11D4_B1E4_00508B8F0099__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "viString.h"

typedef enum { mpInfo = 0, mpWarning, mpError } tVIMessagePriority;

class CviMessage  
{
public:

	virtual CviMessage * Copy( void );

	virtual void Priority( tVIMessagePriority tPriority );
	virtual tVIMessagePriority Priority( void );
	
	virtual void Number( ULONG ulNumber );
	virtual ULONG Number( void );

	virtual void Text( LPCTSTR strText );
	virtual LPCTSTR MessageText( void );

	CviMessage();
	CviMessage( ULONG ulNumber, LPCTSTR strText = _T(""), tVIMessagePriority tPriority = mpError);
	virtual ~CviMessage();

private:

	ULONG               m_ulNumber; 
	CviString           m_cstrText;
	tVIMessagePriority  m_tPriority;

};

#endif // !defined(AFX_VIMESSAGE_H__DFCBA7B6_FB42_11D4_B1E4_00508B8F0099__INCLUDED_)
