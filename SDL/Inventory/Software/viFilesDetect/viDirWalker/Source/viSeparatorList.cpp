/*******************************************************************************************
*                                                                                          *
*          Projekt: viSeparatorList                                                *
*                                                                          A               *
*            Datei: CommaList.cpp                                         AAA              *
*        Ersteller: Sylko Zschiedrich                                    AAAAA             *
*            Datum: 1.12.2000                                           A     A            *
* letzte Aenderung:                                                    AAA   AAA           *
*                                                                     AAAAA AAAAA          *
*                                                                    A           A         *
*                                                                   AAA         AAA        *
*                                                                  AAAAA       AAAAA       *
*                                                                 A     A     A     A      *
*                                                                AAA   AAA   AAA   AAA     *
*                                                               AAAAA AAAAA AAAAA AAAAA    *
*  Voelcker Informatik AG                                                                  *
*                                                                                          *
*     Beschreibung:     *
*                                         *
*                                                                                          * 
*                                                                                          *
********************************************************************************************/

#include "stdafx.h"
#include "viSeparatorList.h"


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CviSeparatorList::CviSeparatorList()
{
	m_cstrSeparators = _T(",");
}

CviSeparatorList::~CviSeparatorList()
{
	
}

LPCTSTR CviSeparatorList::GetStringList()
{
	return (LPCTSTR) m_cstrList;
}

void CviSeparatorList::SetStringList( LPCTSTR strStringList )
{
	m_cstrList = strStringList;

	_ProcessStringList( m_cstrList );
}

HRESULT CviSeparatorList::_ProcessStringList(LPCTSTR strStringList)
{
	LPTSTR    strListCopy;
	LPTSTR    strListPos;
	LPTSTR    strNextSeparator;
	HRESULT   hr = S_OK;
	CviString * pString;

	m_cStringList.Clear();

	if ( strStringList && (_tcslen( strStringList ) > 0) )
	{
		// copy the liststring
		strListCopy = _tcsdup( strStringList );

		strListPos = strListCopy;

		strNextSeparator = _NextSeparator( strListPos );

		while ( strNextSeparator )
		{
			// terminate the string
			*strNextSeparator = _T('\0');

			pString = new CviString(strListPos);
			
			// add the listelement
			if ( ! m_cStringList.Add( pString ) )
			{
				if( pString) 
				{ 
					delete( pString );
					pString = NULL;
				}
			}
			
			// move the List Position
			strListPos = strNextSeparator + 1;

			// try to find next separator
			strNextSeparator = _NextSeparator(strListPos);
		}

		// add the rest
		pString = new CviString(strListPos);
			
		// add the listelement
		if ( ! m_cStringList.Add( pString ) )
		{
			if ( pString ) delete( pString );
		}


		if (strListCopy ) free( strListCopy );
	}

	return S_OK;
}

LONG CviSeparatorList::GetCount()
{
	return m_cStringList.Count();
}

CviString * CviSeparatorList::GetIndex( LONG iIndex )
{
	return m_cStringList.Item( iIndex );
}

void CviSeparatorList::Clear()
{
	// clear the List
	m_cStringList.Clear();

	// and clear the string
	m_cstrList.Clear();
}

void CviSeparatorList::SetSeparators( LPCTSTR strSeparators )
{
	m_cstrSeparators = strSeparators;
}


TCHAR * CviSeparatorList::_NextSeparator( TCHAR * strName )
{
	TCHAR * pPos = strName;

	while( (*pPos) && (! _IsSeparator( *pPos)) )
	{
		pPos++;
	}

	return (*pPos) ? pPos: NULL;
}

BOOL CviSeparatorList::_IsSeparator( TCHAR tChar )
{
	LPCTSTR pPos = (LPCTSTR) m_cstrSeparators;

	while(*pPos) 
	{
		if ( (*pPos) == tChar )
			return TRUE;

		pPos++;
	}
	
	return FALSE;
}

/*************************************************************************************************
 *
 *	write collectiondata to console
 *
 *************************************************************************************************/
void CviSeparatorList::DumpCollection()
{
	LONG ulPos;
	CviString * pviString;

	for ( ulPos=0; ulPos < GetCount(); ulPos++)
	{
		pviString = m_cStringList.Item(ulPos);

		VITRACE2( "%05d - '%s'\n", ulPos, pviString->operator LPCTSTR() ); 

	}
}
