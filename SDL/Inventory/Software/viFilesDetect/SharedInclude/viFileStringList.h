// viFileStringList.h: interface for the CviFileStringList class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_VIFILESTRINGLIST_H__4C15E393_07CC_11D5_B1F4_00508B8F0099__INCLUDED_)
#define AFX_VIFILESTRINGLIST_H__4C15E393_07CC_11D5_B1F4_00508B8F0099__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "viCollection.h"
#include "viString.h"



class CviFileStringList  
{
public:
	virtual BOOL WriteToFile( LPCTSTR strFileName );

	CviFileStringList();
	virtual ~CviFileStringList();

	BOOL  Add( LPCTSTR strText );
	
	CviString * Line( ULONG ulPos );

	void   Clear( void );
	ULONG  Count( void );

	virtual void DumpCollection( void );

private:

	CCollection<CviString> m_cStringList;

};

#endif // !defined(AFX_VIFILESTRINGLIST_H__4C15E393_07CC_11D5_B1F4_00508B8F0099__INCLUDED_)


