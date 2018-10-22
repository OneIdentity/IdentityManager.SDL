// viFilesTree.h: interface for the CviFilesTree class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_VIFILESTREE_H__B3B57599_0693_11D6_B24E_0002A5961A32__INCLUDED_)
#define AFX_VIFILESTREE_H__B3B57599_0693_11D6_B24E_0002A5961A32__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "viTree.h"
#include "viFileInfo.h"

typedef CviTree<CviFileInfo,CviFileInfo>       CviFilesTree;

typedef CviTreeNode <CviFileInfo, CviFileInfo> CviTreeDir;
typedef CviTreeValue<CviFileInfo, CviFileInfo> CviTreeFile;

#endif // !defined(AFX_VIFILESTREE_H__B3B57599_0693_11D6_B24E_0002A5961A32__INCLUDED_)
