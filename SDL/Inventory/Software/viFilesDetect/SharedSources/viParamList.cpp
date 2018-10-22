/*******************************************************************************************
*                                                                                          *
*          Projekt: viParamList                                                            *
*                                                                          A               *
*            Datei: viParamList.cpp                                       AAA              *
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
*     Beschreibung:                                                                        *
*                                                                                          *
*                                                                                          * 
*                                                                                          *
********************************************************************************************/

#include "..\SharedInclude\stdafx.h"
#include "..\SharedInclude\viParamList.h"
#include "..\SharedInclude\viHelper.h"
#include "..\SharedInclude\viDirWalker_INC.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////


CviParamList::CviParamList()
{
	
}

CviParamList::~CviParamList()
{
	
}


BOOL CviParamList::_ProcessCmdLine(LPCTSTR strCmdLine)
{
	LPCTSTR   strListPos;
	CviString * pString;
	CviString cstrToken;
	INT       iState;
	INT       iBSCount;
	INT       i;

	m_cStringList.Clear();

	if ( strCmdLine )
	{
		strListPos = strCmdLine;

		iState    = 0;
		cstrToken = "";
		iBSCount  = 0;

		// go through the string
		while (*strListPos)
		{
			switch(iState)
			{
			case 0: switch(*strListPos)  // startprocessing
					{
					case '\t':
					case ' ':  iState = 0; break;
					case '\"': iState = 2; break;
					case '\\': iState = 3; iBSCount=1; break;
					default:
						cstrToken += *strListPos;
						iState = 1;  
					}
					
					break;

			case 1: switch(*strListPos)  // normal in Token
					{
					case '\t':
					case ' ':
						pString = new CviString( (LPCTSTR) cstrToken );
			
						// add the listelement
						if ( ! m_cStringList.Add( pString ) )
						{
							UFM_FREE( pString )
						}

						cstrToken = "";
						iState = 0; 
						break;

					case '\"': 	iState = 2; break;
					case '\\': 	iState = 3; iBSCount=1; break;
					default:
						cstrToken += *strListPos;
					}
					break;


			case 2: switch(*strListPos)  // in double quotation marks
					{
					case '\"': iState = 1; break;
					case '\\': iState = 4; iBSCount=1; break;
					default:
						cstrToken += *strListPos;
					}
					break;

			case 3: switch(*strListPos)  // after '\' 
					{
					case '\\':				// another \\ found
						iState = 3;
						iBSCount++;
						break;

					case '\"':				// '...\"' found
						for (i=0; i<(iBSCount/2);i++) cstrToken += '\\';

						if (iBSCount & 0x01)
						{
							// ungerade anzahl 
							cstrToken += '\"';
							iState = 1;
						}
						else
						{
							// gerade anzahl
							iState = 2;
						}
						iBSCount=0;
			
                        break;

					case '\t':
					case ' ':
						for (i=0; i<iBSCount;i++) cstrToken += '\\';  // add the '\''s
						iBSCount = 0;

						pString = new CviString( (LPCTSTR) cstrToken );
			
						// add the listelement
						if ( ! m_cStringList.Add( pString ) )
						{
							UFM_FREE( pString )
						}

						cstrToken = "";
						iState = 0; 
						break;
					default:
						for (i=0; i<iBSCount;i++) cstrToken += '\\';			// add the '\'
						iBSCount = 0;
						cstrToken += *strListPos;
						iState = 1;
					}
					break;

			case 4: switch(*strListPos)  // after '\' in quotation marks
					{
					
					case '\"':				// '...\"' found

						for (i=0; i<(iBSCount/2);i++) cstrToken += '\\';

						if (iBSCount & 0x01)
						{
							// ungerade anzahl 
							cstrToken += '\"';
							iState = 2;
						}
						else
						{
							// gerade anzahl
							iState = 1;
						}
						iBSCount=0;
			
                        break;
					case '\\': 
						iState = 4; 
						iBSCount++;
						break;
					default:
						for (i=0; i<iBSCount;i++) cstrToken += '\\';  // add the '\''s
						iBSCount = 0;
						cstrToken += *strListPos;
						iState = 2;
					}
					break;
			}

			strListPos++;
		
		}

		if ( (iState == 3) || (iState == 4))
		{
			cstrToken += '\\';
			iState = 1;
		}

		if ( cstrToken.GetLength() > 0)
		{
			// add the rest
			pString = new CviString( (LPCTSTR) cstrToken );
				
			// add the listelement
			if ( ! m_cStringList.Add( pString ) )
			{
				UFM_FREE( pString )
			}
		}
	}

	return TRUE;
}


LONG CviParamList::GetCount()
{
	return m_cStringList.Count();
}

CviString * CviParamList::GetIndex( LONG iIndex )
{
	return m_cStringList.Item( iIndex );
}

void CviParamList::Clear()
{
	// clear the List
	m_cStringList.Clear();
}





/*************************************************************************************************
 *
 *	write collectiondata to console
 *
 *************************************************************************************************/
void CviParamList::DumpCollection()
{
	LONG ulPos;
	CviString * pviString;

	for ( ulPos=0; ulPos < GetCount(); ulPos++)
	{
		pviString = m_cStringList.Item(ulPos);

		VITRACE2( "%05d - '%s'\n", ulPos, pviString->operator LPCTSTR() ); 

	}
}

BOOL CviParamList::ProcessCMDLine(LPCTSTR strCmdLine)
{
	BOOL bOk;
	
	bOk = _ProcessCmdLine( strCmdLine );

	if (bOk)
	{
		if ( m_cStringList.Count() == 1)
		{
			// check for @
			if ( m_cStringList.Item(0UL)->operator[](0) == '@' )
			{
				m_cStringList.Item(0UL)->Delete(0);

				bOk = _ProcessParamsFromFile( m_cStringList.Item(0UL)->operator LPCTSTR() );

			}
		}
	}
	
	return bOk;
}


BOOL CviParamList::_ProcessParamsFromFile(LPCTSTR strParamFile)
{
	BOOL bRetVal = TRUE;
	FILE *pFile = NULL;
	fpos_t pos;
	LPTSTR lpszBuffer = NULL;
	CviString * pString;

	pFile = fopen(strParamFile, _T("r"));

	if (pFile)
	{
		m_cStringList.Clear();

		fseek(pFile, 0L, SEEK_END);
		fgetpos(pFile, &pos);
		fseek(pFile, 0L, SEEK_SET);

		lpszBuffer = new TCHAR[(int)pos + 1];

		while( fgets( lpszBuffer, (int) pos, pFile ) > NULL )
		{
			pString = new CviString;

			if (pString)
			{
				(*pString) = lpszBuffer;

				pString->TrimLeft();
				pString->TrimRight();

				if ( ! m_cStringList.Add( pString ) )
				{
					// add failed
					UFM_DELETE( pString );
					bRetVal = FALSE;
				}
			}
			else
			{
				bRetVal = FALSE;
			}
		}

		UFM_DELETE(lpszBuffer);

		fclose(pFile);
	}
	else
	{
		CviString cstrError;
		cstrError.Format( g_cMsgColl.GetResourceString( IDS_STRING_DE_107 ), strParamFile, GetLastError(), GetErrorText(GetLastError()).operator LPCTSTR() );
		g_cMsgColl.Add( 107, cstrError.operator LPCTSTR() );
		
		bRetVal = FALSE;
	}

	return bRetVal;
}

ULONG CviParamList::FindParam(LPCTSTR strParamName)
{
	ULONG iPos;
	ULONG iLen;

	iLen = _tcslen(strParamName);

	for (iPos=0; iPos<m_cStringList.Count(); iPos++)
	{
		if (_tcsncicmp( m_cStringList.Item(iPos)->operator LPCTSTR(), strParamName, iLen) == 0)
		{
			return iPos;
		}
	}

	// parameter not found
	return -1;
}

LPCTSTR CviParamList::GetParamData(LPCTSTR strParamName)
{
	ULONG iPos;
	ULONG iLen;

	iLen = _tcslen(strParamName);

	for (iPos=0; iPos<m_cStringList.Count(); iPos++)
	{
		if (_tcsncicmp( m_cStringList.Item(iPos)->operator LPCTSTR(), strParamName, iLen) == 0)
		{
			return m_cStringList.Item(iPos)->operator LPCTSTR() + iLen;;
		}
	}

	// parameter not found
	return NULL;
}

BOOL CviParamList::RemoveParameter(ULONG iPos)
{
	return m_cStringList.Remove(iPos);
}

BOOL CviParamList::RemoveParameter(LPCTSTR strParamName)
{
	ULONG iPos;

	iPos = FindParam( strParamName );

	if (iPos==-1) 
		return FALSE;
	else
		return RemoveParameter(iPos);
}
