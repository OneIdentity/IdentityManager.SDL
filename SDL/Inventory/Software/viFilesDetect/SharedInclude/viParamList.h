/*******************************************************************************************
*                                                                                          *
*          Projekt: shared                                                                 *
*                                                                          A               *
*            Datei: CommaList.h                                           AAA              *
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
*     Beschreibung:																		   *
*																						   *
*                                                                                          *
********************************************************************************************/


#if !defined(AFX_PARAMLIST_H__3E93AFA7_BBA0_11D4_B23A_00508B8F0099__INCLUDED_)
#define AFX_PARAMLIST_H__3E93AFA7_BBA0_11D4_B23A_00508B8F0099__INCLUDED_

#include "viCollection.h"

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "viString.h"

class CviParamList
{
public:
	virtual BOOL RemoveParameter( LPCTSTR strParamName );
	virtual BOOL RemoveParameter( ULONG iPos );
	virtual LPCTSTR GetParamData( LPCTSTR strParamName );
	virtual ULONG FindParam( LPCTSTR strParamName );
	virtual BOOL ProcessCMDLine( LPCTSTR strCmdLine );


	CviParamList();
	virtual ~CviParamList();


	virtual LONG    GetCount( void );
	virtual CviString * GetIndex( LONG iIndex );

	virtual void DumpCollection();
	virtual void Clear( void );

private:

	CCollection<CviString> m_cStringList;

protected:
	
	virtual BOOL _ProcessCmdLine(LPCTSTR strCmdLine);
	virtual BOOL _ProcessParamsFromFile(LPCTSTR strParamFile );

};

#endif // !defined(AFX_PARAMLIST_H__3E93AFA7_BBA0_11D4_B23A_00508B8F0099__INCLUDED_)
