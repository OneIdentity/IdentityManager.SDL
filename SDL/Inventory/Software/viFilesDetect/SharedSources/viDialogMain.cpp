// viDialogMain.cpp: implementation of the CviDialogMain class.
//
//////////////////////////////////////////////////////////////////////

#include "..\SharedInclude\stdafx.h"
#include "..\SharedInclude\viDialogMain.h"
#include "..\SharedInclude\viDirWalker_INC.h"
#include <ShellApi.h>
#include <WindowsX.h>


CviDialogMain g_cDialogMain;

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

#define MYWM_NOTIFYICON		(WM_APP+100)

#define VIFILESDETECT_NOTIFY	(1235)

BOOL CALLBACK DialogCallBack(HWND hDlg, UINT uMsg, WPARAM wParam, LPARAM lParam);

CviDialogMain::CviDialogMain()
{
	m_hWnd = NULL;
}

CviDialogMain::~CviDialogMain()
{
	if (m_hWnd)
	{
		DestroyWindow( m_hWnd );
	}
}

BOOL CALLBACK DialogCallBack(HWND hDlg, UINT uMsg, WPARAM wParam, LPARAM lParam)
{

	switch (uMsg)
	{
	case WM_INITDIALOG:
		HWND hWnd;
	
		hWnd = GetDlgItem( hDlg, IDC_BUTTON_HIDE );

		if (hWnd)
		{
			SetWindowText( hWnd, g_cMsgColl.GetResourceString( IDS_STRING_DE_113 ) );
		}

		break;
/*
	case WM_DRAWITEM:
		return(_IconDrawItem((LPDRAWITEMSTRUCT)lParam));
		break;
*/
	case WM_DESTROY:
			g_cDialogMain.NotifyDelete();
		break;

	case WM_COMMAND:
		switch (GET_WM_COMMAND_ID(wParam, lParam))
		{
		case IDC_BUTTON_HIDE:
			ShowWindow(hDlg, SW_HIDE);
			break;
		}
		break;
		
	case MYWM_NOTIFYICON:
		switch (lParam)
		{
			/*
		case WM_LBUTTONDOWN:
			switch (wParam)
			{
			case IDC_NOTIFY1:
				StateChange(hDlg, 0, (UINT)-1);
				break;

			case IDC_NOTIFY2:
				StateChange(hDlg, 1, (UINT)-1);
				break;

			case IDC_NOTIFY3:
				StateChange(hDlg, 2, (UINT)-1);
				break;

			default:
				break;
			}
			break; */

		case WM_LBUTTONDOWN:
			ShowWindow(hDlg, SW_SHOW);
			SetForegroundWindow(hDlg);	// make us come to the front
			break;

		default:
			break;
		}
		break;

	default:
		return(FALSE);
	}

	return(TRUE);
}

BOOL CviDialogMain::Show()
{
	if (!m_hWnd)
		return FALSE;
	
	 ShowWindow( m_hWnd, SW_SHOWNORMAL );

	 UpdateWindow( m_hWnd );

	return TRUE;
}

BOOL CviDialogMain::Create()
{
	m_hWnd = CreateDialog( g_cMsgColl.m_hInstance, MAKEINTRESOURCE(IDD_DIALOG_MAIN), NULL, DialogCallBack);

	if (!m_hWnd)
		g_cMsgColl.Add( 0, _T("Create Dialog failed.") );
	else
	{
		NotifyAdd();
	}

	return (m_hWnd != NULL);
}


BOOL CviDialogMain::_TrayMessage(HWND hDlg, DWORD dwMessage, UINT uID, HICON hIcon, LPCTSTR strTip)
{
    BOOL res;

	NOTIFYICONDATA tnd;

	tnd.cbSize		= sizeof(NOTIFYICONDATA);
	tnd.hWnd		= hDlg;
	tnd.uID			= uID;

	tnd.uFlags		= NIF_MESSAGE|NIF_ICON|NIF_TIP;
	tnd.uCallbackMessage	= MYWM_NOTIFYICON;
	tnd.hIcon		= hIcon;

	if (strTip)
	{
		lstrcpyn(tnd.szTip, strTip, sizeof(tnd.szTip));
	}
	else
	{
		tnd.szTip[0] = '\0';
	}

	res = Shell_NotifyIcon(dwMessage, &tnd);

	if (hIcon)
	    DestroyIcon(hIcon);

	return res;
}

LRESULT CviDialogMain::_IconDrawItem(LPDRAWITEMSTRUCT lpdi)
{
	HICON hIcon;

	hIcon = (HICON)LoadImage(g_cMsgColl.m_hInstance, MAKEINTRESOURCE(lpdi->CtlID), IMAGE_ICON,
		16, 16, 0);
	if (!hIcon)
	{
		return(FALSE);
	}

	DrawIconEx(lpdi->hDC, lpdi->rcItem.left, lpdi->rcItem.top, hIcon,
		16, 16, 0, NULL, DI_NORMAL);

	return(TRUE);
}


void CviDialogMain::NotifyDelete()
{
	_TrayMessage( m_hWnd, NIM_DELETE, VIFILESDETECT_NOTIFY, NULL, NULL);
}


void CviDialogMain::NotifyAdd()
{
	HICON hIcon;

	hIcon = LoadIcon( g_cMsgColl.m_hInstance, MAKEINTRESOURCE(IDI_ICON_TRAY));

	_TrayMessage(m_hWnd, NIM_ADD, VIFILESDETECT_NOTIFY, hIcon, g_cMsgColl.GetResourceString( IDS_STRING_DE_111 ));
}

void CviDialogMain::ShowText(LPCTSTR strText)
{
	HWND hWnd;
	CviString cstrText;

	// errorhandling
	if (!m_hWnd)
		return;

	// copy the text
	cstrText = strText;

	if (cstrText.GetLength() > 45)
	{
		cstrText.Format( _T("...%s"), cstrText.Right(45).operator LPCTSTR() );
	}

	hWnd = GetDlgItem( m_hWnd, IDC_TEXT );

	if (hWnd)
	{
		SetWindowText( hWnd, cstrText.operator LPCTSTR() );
	}
	
}
