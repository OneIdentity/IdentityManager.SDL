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


#if !defined(AFX_FKLIST_H__3E93AFA7_BBA0_11D4_B23A_00508B8F0099__INCLUDED_)
#define AFX_FKLIST_H__3E93AFA7_BBA0_11D4_B23A_00508B8F0099__INCLUDED_

#include <viCollection.h>

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <viString.h>

class CviSeparatorList
{
public:

	CviSeparatorList();
	virtual ~CviSeparatorList();

	virtual  void   SetStringList( LPCTSTR strStringList );
	virtual  LPCTSTR GetStringList( void );

	virtual  void Clear( void );

	virtual  LONG GetCount( void );
	virtual  CviString * GetIndex( LONG iIndex );

	virtual  void SetSeparators( LPCTSTR strSeparator);
	virtual  void DumpCollection();

private:

	TCHAR * _NextSeparator( TCHAR * strName );
	BOOL   _IsSeparator( TCHAR tChar );

	CCollection<CviString> m_cStringList;

	CviString              m_cstrList;
	CviString              m_cstrSeparators;

protected:
	
	virtual HRESULT _ProcessStringList( LPCTSTR strStringList );

};

#endif // !defined(AFX_FKLIST_H__3E93AFA7_BBA0_11D4_B23A_00508B8F0099__INCLUDED_)
