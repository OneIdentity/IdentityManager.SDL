// viDialogMain.h: interface for the CviDialogMain class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_VIDIALOGMAIN_H__39CE6B63_096E_11D5_B1F6_00508B8F0099__INCLUDED_)
#define AFX_VIDIALOGMAIN_H__39CE6B63_096E_11D5_B1F6_00508B8F0099__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

class CviDialogMain  
{
public:
	virtual void ShowText( LPCTSTR strText );
	virtual BOOL Create( void );
	virtual BOOL Show( void );
	CviDialogMain();
	virtual ~CviDialogMain();

	virtual void NotifyAdd( void );
	virtual void NotifyDelete( void );

private:

	virtual BOOL _TrayMessage(HWND hDlg, DWORD dwMessage, UINT uID, HICON hIcon, LPCTSTR strTip);
	virtual LRESULT _IconDrawItem(LPDRAWITEMSTRUCT lpdi);

	HWND m_hWnd;
};

extern CviDialogMain g_cDialogMain;

#endif // !defined(AFX_VIDIALOGMAIN_H__39CE6B63_096E_11D5_B1F6_00508B8F0099__INCLUDED_)
