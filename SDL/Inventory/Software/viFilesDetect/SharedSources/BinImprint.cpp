// Implementation of the BinImprint-Functions
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"

#include "BinImprint.h"
#include <viString.h>
#include <viDirWalker_INC.h>
#include "viHelper.h"

#define IMPRINTSIZE 1023

// the returned Sting must be released with free
LPTSTR GetBinImprint_V1( LPCTSTR strFileName )
{
	FILE      * pFile;
	
	CviString   cstrBinImprint;
	TCHAR       vByte[3];
	UCHAR       iByte;
	LONG		lFileSize;
	LONG		lStepSize;
	LONG        lRemaSize;
	ldiv_t      div_result;
	LONG		lRemainder;
	LONG        lStep;
	size_t      tRead;
	
	// initialize Imprint-String
	cstrBinImprint = _T("");

	// open the file
	pFile = fopen( strFileName, _T("rb") );

	// errorhandling
	if (pFile)
	{
		// get filesize
		fseek( pFile, 0, SEEK_END );
		lFileSize = ftell(pFile);
		fseek(pFile, 0, SEEK_SET);

		// 
		if (lFileSize>IMPRINTSIZE)
		{
			div_result = ldiv( lFileSize, IMPRINTSIZE );
   
			lStepSize  = div_result.quot;
			lRemaSize  = div_result.rem;
			lRemainder = 0;    

			// loop
			for( lStep=0; lStep<IMPRINTSIZE; lStep++)
			{
				// read the byte
				tRead = fread( (void *) &iByte, 1, 1, pFile );

				if ( ferror(pFile) || (tRead == 0))
				{
					cstrBinImprint = _T("");
					break;
				}

				// convert byte to hex
				sprintf(vByte, "%02X", iByte & 0xFF );

				// appand to BinImprint
				cstrBinImprint += vByte;

				// add the remainder
				lRemainder += lRemaSize; 

				// remainder large enough
				if (lRemainder>=IMPRINTSIZE)
				{
					// process remainder
					div_result = ldiv( lRemainder, 1023 );
					lRemainder = div_result.rem;

					// set new filepos
					fseek( pFile, lStepSize + div_result.quot - 1, SEEK_CUR);
				}
				else
				{
					// set new filepos
					fseek( pFile, lStepSize - 1, SEEK_CUR);
				}
			} // end for...

			if ( ferror(pFile) )
			{
				CviString cstrError;
				cstrError.Format( g_cMsgColl.GetResourceString( IDS_STRING_DE_107 ), strFileName, ferror(pFile), GetErrorText(ferror(pFile)).operator LPCTSTR() );
				g_cMsgColl.Add( 107, cstrError.operator LPCTSTR() );
			}

		}
		else
		{
			// Error "FileToSmall
		}

		fclose(pFile);
	}
	else
	{
		CviString cstrError;
		cstrError.Format( g_cMsgColl.GetResourceString( IDS_STRING_DE_107 ), strFileName, GetLastError(), GetErrorText(GetLastError()).operator LPCTSTR() );
		g_cMsgColl.Add( 107, cstrError.operator LPCTSTR() );
	}

	if ( cstrBinImprint.GetLength() == (IMPRINTSIZE*2) )
		return _tcsdup(cstrBinImprint.operator LPCTSTR());
	else
		return NULL;
}

#define STEP_SIZE_1 100L
#define STEP_SIZE_2 1000L

LPTSTR GetBinImprint_V2( LPCTSTR strFileName )
{
	FILE      * pFile;
	
	CviString   cstrBinImprint;
	TCHAR       vByte[3];
	UCHAR       iByte;
	LONG		lStepSize = STEP_SIZE_1;
	LONG        lStep = 0;
	LONG        lFileSize;

	
	// initialize Imprint-String
	cstrBinImprint = _T("");

	// open the file
	pFile = fopen( strFileName, _T("rb") );

	// errorhandling
	if (pFile)
	{
		// get filesize
		fseek( pFile, 0, SEEK_END );
		lFileSize = ftell(pFile);
		fseek(pFile, 0, SEEK_SET);

		if (lFileSize >= 20000)
		{
			while( fread( (void *) &iByte, 1, 1, pFile ) == 1 )
			{
				// convert byte to hex
				sprintf(vByte, "%02X", iByte & 0xFF );

				// appand to BinImprint
				cstrBinImprint += vByte;

				// set new filepos
				fseek( pFile, lStepSize - 1, SEEK_CUR);

				// increment step's
				lStep++;

				if (lStep >= 400)
				{
					// set larger stepsize
					lStepSize = STEP_SIZE_2;
				}

			} // end while...

			if ( ! feof(pFile) )
			{
				// errorhandling
				if ( ferror(pFile) )
				{
					CviString cstrError;
					cstrError.Format( g_cMsgColl.GetResourceString( IDS_STRING_DE_107 ), strFileName, GetLastError(), GetErrorText(GetLastError()).operator LPCTSTR() );
					g_cMsgColl.Add( 107, cstrError.operator LPCTSTR() );
					cstrBinImprint = _T("");
				}

				cstrBinImprint = _T("");
			}
		}
		else
		{
			cstrBinImprint = ""; 
		}


		// close the file
		fclose(pFile);

	}
	else
	{
		CviString cstrError;
		cstrError.Format( g_cMsgColl.GetResourceString( IDS_STRING_DE_107 ), strFileName, GetLastError(), GetErrorText(GetLastError()).operator LPCTSTR() );
		g_cMsgColl.Add( 107, cstrError.operator LPCTSTR() );
	}

	if ( cstrBinImprint.GetLength() > 0 )
		return _tcsdup(cstrBinImprint.operator LPCTSTR());
	else
		return NULL;

	return NULL;
}
