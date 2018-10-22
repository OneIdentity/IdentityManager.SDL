// viMessageCollection.h: interface for the CviMessageCollection class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_VIMESSAGECOLLECTION_H__DFCBA7B7_FB42_11D4_B1E4_00508B8F0099__INCLUDED_)
#define AFX_VIMESSAGECOLLECTION_H__DFCBA7B7_FB42_11D4_B1E4_00508B8F0099__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "viCollection.h"
#include "viMessage.h"

//---------------------------------------
// Initial-Parameter for Collection
//---------------------------------------

typedef enum TLanguage
{
	L_GERMAN = 0,
	L_ENGLISH = 2000
};

#define MC_INITIAL_SIZE		100
#define MC_HASH_SIZE		101

class CviMessageCollection;  

class CviMessageCollection  
{
public:
	
	CviMessageCollection();
	virtual ~CviMessageCollection();

	BOOL  Add( CviMessage * pMessage );
	BOOL  Add( ULONG ulNumber, LPCTSTR strText = _T(""), tVIMessagePriority tPriority = mpError );
	BOOL  Appand( CviMessageCollection * pMessageCollection );

	CviMessage * Item( ULONG ulPos );

	void   Clear( void );
	ULONG  Count( void );

	TLanguage Language();
	void      Language( TLanguage NewLang );

	virtual void DumpCollection( void );

	LPCTSTR GetResourceString( INT iResID );

	HINSTANCE m_hInstance;

private:

	CCollection<CviMessage> * m_pMessageCollection;

	TLanguage m_tLanguage;		// our offset for LanguageSettings

};


extern CviMessageCollection g_cMsgColl;


#endif // !defined(AFX_VIMESSAGECOLLECTION_H__DFCBA7B7_FB42_11D4_B1E4_00508B8F0099__INCLUDED_)
