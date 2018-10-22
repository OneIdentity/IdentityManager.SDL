/*******************************************************************************************
*                                                                                          *
*          Projekt: viFileImprint                                                          *
*                                                                          A               *
*            Datei: viFileImprint.h                                       AAA              *
*        Ersteller: Sylko Zschiedrich                                    AAAAA             *
*            Datum: 20.06.2001                                          A     A            *
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
*     Beschreibung: C++ Library zur Erstellung von Binär-Imprints von Dateien.             *
*                   Die Library stellt sowohl vollständige also auch iterative             *
*                   Verfahren zur Imprinmterzeugung bereit.                                *
*                                                                                          *
********************************************************************************************/

#ifndef VIFILEIMPRINT

#include <stdio.h>

/****************************************************************
 *
 *  Global Definitions 
 *
 *  DO NOT EDIT THIS PARAMETER
 *
 ****************************************************************/

#define STARTPOS        10			// unknown files start at filepos
#define STEPWIDTH       15			// the stepwidth is doubled every x iteratios
#define STARTSTEP       5           // the initialstepwith
#define MINIMPRINTLEN   20          // the imprint must min include xx elements
#define MAXIMPRINTLEN   256         // max element count in imprint

/*******************************************************************************
 *
 * This function creates a File-Imprint from a given file(handle). The Imprint is
 * a hex-notation, zero-terminated string.
 *
 * Parameter: File * pFile		-> handle to a file opend by "fopen"
 *            char * strBuffer  -> returnbuffer for the imprint
 *            long   lBufSize   -> size of strBuffer ( min 512 Byte )
 *
 * Returnvalues: true -> no errors accured
 *               false -> GetLastError() with errorcode
 *					ERROR_INVALID_PARAMETER		-> invalid Parameter (NULL-pointer?)
 *					ERROR_INSUFFICIENT_BUFFER	-> strBuffer/lBufSize is to small
 *                  ERROR_SOURCE_ELEMENT_EMPTY  -> the imprint is to small
 *
 *******************************************************************************/
bool viGetFullImprint_FileHandle( FILE * pFile, char * strBuffer, long lBufSize);


/*******************************************************************************
 *
 * This function creates a File-Imprint from a given filename. The Imprint is
 * a hex-notation, zero-terminated string. 
 *
 * Parameter: const char * strFile -> handle to a file opend by "fopen"
 *            char * strBuffer     -> returnbuffer for the imprint
 *            long   lBufSize      -> size of strBuffer ( min 513 Byte )
 *
 * Returnvalues: Same as viGetFullImprint_FileHandle()
 *
 *******************************************************************************/
bool viGetFullImprint_FileName( const char * strFile, char * strBuffer, long lBufSize);


/*******************************************************************************
 *
 * Workstructure to handle iterative imprintcreation.
 *
 * The only interesting Element is TheByte.
 *
 * ATTENTION: Do not edit any values in this structure.
 *
 *******************************************************************************/
struct viIMPRINT
{
	FILE * m_pFile;			// the filehandle -- DO NOT EDIT
	long   m_lStepWidth;	// the stepwidth  -- DO NOT EDIT
	long   m_lIteration;	// the itterationcounter -- DO NOT EDIT
	unsigned char TheByte;	// the Imprint-Byte -- READ ONLY
};


/*******************************************************************************
 *
 * This function initializes the viIMPRINT-structure and returns the first 
 * imprintbyte. Do not close the file while processing.
 *
 * Parameter: viIMPRINT * pImprint -> Pointer to a viIMPRINT-structure
 *            File * pFile		   -> handle to a file opend by "fopen"
 *
 * Returnvalues: true ->  First ImprintByte in pImprint->TheByte
 *               false -> end of imprint reached
 *
 *******************************************************************************/
bool viGetFirstImprintByte_FileHandle( viIMPRINT * pImprint, FILE * pFile );


/*******************************************************************************
 *
 * This function initializes the viIMPRINT-structure and returns the first 
 * imprintbyte. You have to call viCloseImprint after processing.
 *
 * Parameter: viIMPRINT * pImprint -> Pointer to a viIMPRINT-structure
 *            const char * strFile -> Name of file
 *
 * Returnvalues: true -> First ImprintByte in pImprint->TheByte
 *               false -> end of imprint reached
 *
 *******************************************************************************/
bool viGetFirstImprintByte_FileName( viIMPRINT * pImprint, const char * strFile );

/*******************************************************************************
 *
 * This function returns the next imprintbyte. The Structure must be initialized
 * with viGetFirstImprintByte_FileHandle() or viGetFirstImprintByte_FileName().
 *
 * Parameter: viIMPRINT * pImprint -> Pointer to a viIMPRINT-structure
 *
 * Returnvalues: true -> Next ImprintByte in pImprint->TheByte
 *               false -> end of imprint reached
 *
 *******************************************************************************/
bool viGetNextImprintByte( viIMPRINT * pImprint );


/*******************************************************************************
 *
 * Close the file and cleanup the viIMPRINT-structure. You must call this
 * function if you initialize the structure with viGetFirstImprintByte_FileName()
 *
 * Parameter: viIMPRINT * pImprint -> Pointer to a viIMPRINT-structure
 *
 * Returnvalues: true -> no error
 *               false -> errorcode in GetLastError()
 *
 *******************************************************************************/
bool viCloseImprint( viIMPRINT * pImprint );


#define VIFILEIMPRINT
#endif