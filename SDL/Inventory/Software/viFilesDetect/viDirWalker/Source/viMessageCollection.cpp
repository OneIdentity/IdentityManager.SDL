// viMessageCollection.cpp: implementation of the CviMessageCollection class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "viMessageCollection.h"



/*********************************************************************
 *
 * The global Messagecollection
 *
 *********************************************************************/

 CviMessageCollection g_cMsgColl;



CviMessageCollection::CviMessageCollection()
{
	m_pMessageCollection = new CCollection<CviMessage>(MC_INITIAL_SIZE, MC_HASH_SIZE);
	m_hInstance = NULL;
	m_tLanguage = L_GERMAN;
}

CviMessageCollection::~CviMessageCollection()
{
	if (m_pMessageCollection) delete( m_pMessageCollection );
}


BOOL CviMessageCollection::Add( CviMessage * pMessage )
{
	return m_pMessageCollection->Add( pMessage );
}

BOOL CviMessageCollection::Add( ULONG ulNumber, LPCTSTR strText, tVIMessagePriority tPriority )
{
	CviMessage * pviMessage;
	
	pviMessage = new CviMessage( ulNumber, strText, tPriority );

	if (pviMessage)
	{
		return Add(pviMessage);
	}
	else
	{
		return FALSE;
	}
}

CviMessage * CviMessageCollection::Item( ULONG ulPos )
{
	return m_pMessageCollection->Item( ulPos );
}

void CviMessageCollection::Clear( void )
{	
	m_pMessageCollection->Clear();
}


ULONG CviMessageCollection::Count( void )
{
	return m_pMessageCollection->Count();
}

BOOL CviMessageCollection::Appand( CviMessageCollection * pMessageCollection )
{
	ULONG		 iPos;
	CviMessage * pMessage;
	BOOL         bRetVal = TRUE;

	for (iPos=0; (iPos<pMessageCollection->Count()) && bRetVal; iPos ++)
	{
		pMessage = pMessageCollection->Item(iPos)->Copy();

		if (pMessage)
		{
			bRetVal = Add(pMessage);
		}
		else
		{
			bRetVal = FALSE;
		}
	}		

	return bRetVal;
}

/*************************************************************************************************
 *
 *	write collectiondata to trace
 *
 *************************************************************************************************/
void CviMessageCollection::DumpCollection()
{
	ULONG ulPos;

	if (Count() == 0)
	{
		VITRACE(_T("The MessageCollection is empty.\n") );
	}
	else
	{
		for ( ulPos=0; ulPos < Count(); ulPos++)
		{
			VITRACE3(_T("%05d - Nr: 0x%08X - Text: %s\n"), ulPos, Item(ulPos)->Number(), (LPCTSTR) Item(ulPos)->MessageText(),  );
		}
	}
}

LPCTSTR CviMessageCollection::GetResourceString( INT iBaseResID )
{
	static CviString cstrReturn;

	if (m_hInstance)
		cstrReturn.LoadString( m_hInstance, iBaseResID + (INT) m_tLanguage );
	else
		cstrReturn = _T("No hInstance.");

	return cstrReturn.operator LPCTSTR();
}


TLanguage CviMessageCollection::Language()
{
	return m_tLanguage;
}

void CviMessageCollection::Language( TLanguage NewLang )
{
	m_tLanguage = NewLang;
}