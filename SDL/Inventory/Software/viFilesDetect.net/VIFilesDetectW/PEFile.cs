#region One Identity - Open Source License
//
// One Identity - Open Source License
//
// Copyright 2018 One Identity LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software. Any and all copies of the above
// copyright and this permission notice contained in the Software shall not be
// removed, obscured, or modified.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
#endregion


using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;
using System.IO;
using System.Runtime.InteropServices;

namespace VIFilesDetectW
{
    class PEFile : IDisposable
    {
        bool is_disposed = false;

        FileStream fin;
        int BufferLength;
        int iNTHeaderOffset;
        int iOptionalHeaderOffset;
        int iSectionOffset;
        int iOffset;
        uint iEntryPoint;
        uint iBaseRVA;
        uint iImageSectionHeaderSize;
        uint nEntries;
        byte[] bData;

        protected virtual void Dispose(bool disposing)
	    {
	        if (!is_disposed) // only dispose once!
	        {
	            if (disposing)
	            {
		            //Console.WriteLine("Not in destructor, OK to reference other objects");
	            }
	            // perform cleanup for this object
                m_VersionInfo.Clear();
                m_IsManaged = false;
                m_BinImprint = String.Empty;
	            //Console.WriteLine("Disposing...");
            }
	        this.is_disposed = true;
	    }

        public void Dispose()
        {
            Dispose(true);
            // tell the GC not to finalize
            GC.SuppressFinalize(this);
        }

        public PEFile(FileStream Fin, int BufferLength)
        {
            this.fin = Fin;
            this.BufferLength = BufferLength;
            this.bData = ReadFile(fin, BufferLength);
        	bool b64 = false;

            unsafe
            {
                fixed (byte* pData = this.bData)
                {
                    IMAGE_DOS_HEADER* pIdh = (IMAGE_DOS_HEADER*)pData;
                    IMAGE_NT_HEADERS32* pInhs32 = (IMAGE_NT_HEADERS32*)(pIdh->e_lfanew + pData);
					IMAGE_NT_HEADERS64* pInhs64 = (IMAGE_NT_HEADERS64*)(pIdh->e_lfanew + pData);

                    if (pInhs32->FileHeader.SizeOfOptionalHeader > 0) // check for non object file
                    {
                        if (pInhs32->OptionalHeader.Magic == 0x10b)
                        {
                           // 32 Bit
                        }

						if (pInhs32->OptionalHeader.Magic == 0x20b)
						{
							// 64 Bit
							b64 = true;
						}

                        if (pInhs32->OptionalHeader.CLRDataDirectory.Size > 0)
                            m_IsManaged = true;
                        else
                            m_IsManaged = false;

						if ((this.bData.Length < 9192) && (pInhs32->OptionalHeader.BaseOfCode > 2048))
							iEntryPoint = 2048;
						else
						{
							if (b64)
								iEntryPoint = pInhs64->OptionalHeader.BaseOfCode;
							else
								iEntryPoint = pInhs32->OptionalHeader.BaseOfCode;
						}

                    	m_BinImprint = viGetFullImprint_ByteArray(bData, iEntryPoint);

                        iNTHeaderOffset = pIdh->e_lfanew;
                        iOptionalHeaderOffset = iNTHeaderOffset + 4 + (int)sizeof(IMAGE_FILE_HEADER);
                        iSectionOffset = iOptionalHeaderOffset + (int)pInhs32->FileHeader.SizeOfOptionalHeader;
                        iOffset = iSectionOffset + (int)pData;

                        for (int i = 0; i < pInhs32->FileHeader.NumberOfSections; i++)
                        {
                            IMAGE_SECTION_HEADER* pIsh = (IMAGE_SECTION_HEADER*)(iOffset + (int)(sizeof(IMAGE_SECTION_HEADER) * i));
                            iBaseRVA = pIsh->PointerToRawData + (uint) pData;

                            if (MakeStringFromUTF8((byte*)&pIsh->Name) == ".rsrc")
                            {
								if (pIsh->VirtualSize > 0)
									iImageSectionHeaderSize = pIsh->VirtualSize;
								else
									iImageSectionHeaderSize = pIsh->SizeOfRawData;

								if (b64)
								{
									if (pInhs64->OptionalHeader.ResourceDataDirectory.VirtualAddress >= pIsh->VirtualAddress &&
										pInhs64->OptionalHeader.ResourceDataDirectory.VirtualAddress < pIsh->VirtualAddress + iImageSectionHeaderSize)
									{
										IMAGE_RESOURCE_DIRECTORY* pIrd = (IMAGE_RESOURCE_DIRECTORY*)(pIsh->PointerToRawData + (uint)pData);
										IMAGE_RESOURCE_DIRECTORY_ENTRY* pIrde = (IMAGE_RESOURCE_DIRECTORY_ENTRY*)(pIrd + 1);
										nEntries = (UInt16)(pIrd->NumberOfIdEntries + pIrd->NumberOfNamedEntries);

										for (int j = 0; j < nEntries; j++)
										{
											if (!processImageResourceDirectory(pIrd, pIrde, iBaseRVA, pIsh, pData))
												throw new Exception("Error during resource directory parsing.");
											pIrde++;
										}
									}
								}
								else
								{
									if (pInhs32->OptionalHeader.ResourceDataDirectory.VirtualAddress >= pIsh->VirtualAddress &&
									    pInhs32->OptionalHeader.ResourceDataDirectory.VirtualAddress < pIsh->VirtualAddress + iImageSectionHeaderSize)
									{
										IMAGE_RESOURCE_DIRECTORY* pIrd = (IMAGE_RESOURCE_DIRECTORY*) (pIsh->PointerToRawData + (uint) pData);
										IMAGE_RESOURCE_DIRECTORY_ENTRY* pIrde = (IMAGE_RESOURCE_DIRECTORY_ENTRY*) (pIrd + 1);
										nEntries = (UInt16) (pIrd->NumberOfIdEntries + pIrd->NumberOfNamedEntries);

										for (int j = 0; j < nEntries; j++)
										{
											if (!processImageResourceDirectory(pIrd, pIrde, iBaseRVA, pIsh, pData))
												throw new Exception("Error during resource directory parsing.");
											pIrde++;
										}
									}
								}
                            }

                            if (iOffset >= iOptionalHeaderOffset + (int)sizeof(IMAGE_OPTIONAL_HEADER32) + 8 * 16 + (int)pData) // just for savety reasons
                                break;

                        }
                    }
                }
            }
        }

        private static byte[] ReadFile(Stream stream, int initialLength)
        {
            if (initialLength < 1)
            {
                initialLength = 32768;
            }

            byte[] buffer = new byte[initialLength];
            int read = 0;

            int chunk;
            while ((chunk = stream.Read(buffer, read, buffer.Length - read)) > 0)
            {
                read += chunk;
                if (read == buffer.Length)
                {
                    int nextByte = stream.ReadByte();
                    if (nextByte == -1)
                    {
                        return buffer;
                    }

                    byte[] newBuffer = new byte[buffer.Length * 2];
                    Array.Copy(buffer, newBuffer, buffer.Length);
                    newBuffer[read] = (byte)nextByte;
                    buffer = newBuffer;
                    read++;
                }
            }
            byte[] ret = new byte[read];
            Array.Copy(buffer, ret, read);

            return ret;
        }

        private static bool IsToIgnore(byte iByte)
        {
            Boolean bRetVal = false;

            switch (iByte)
            {
                case 0x00:
                case 0x01:
                case 0x02:
                case 0x04:
                case 0x10:
                case 0x20:
                case 0x40:
                case 0x50:
                case 0x66:
                case 0x68:
                case 0x74:
                case 0x75:
                case 0x83:
                case 0x8B:
                case 0x8D:
                case 0x90:
                case 0xE8:
                case 0xFF:
                    bRetVal = true;
                    break;
            }

            return bRetVal;
        }

        private static string viGetFullImprint_ByteArray(byte[] bData, uint EntryPoint)
        {
            ArrayList theByte = new ArrayList();
            StringBuilder sBuffer = new StringBuilder();

            string vHexZahl;
            int iDest = 0;
            int iStep = STARTSTEP;
            int offset = 0;
            int f = 0;

            do
            {
                f = 1;
                do
                {
                    if ((EntryPoint + offset + f) < bData.Length)
                    {
                        if (!IsToIgnore(bData[EntryPoint + offset + f]))
                            theByte.Add(bData[EntryPoint + offset + f]);
                        else
                            f++;
                    }
                    else
                    {
                        break;
                    }
                } while (theByte.Count < 1);

                if (theByte.Count > 0)
                {
                    vHexZahl = String.Format("{0:X2}", theByte[0]);
                    sBuffer.Append(vHexZahl[0]);
                    sBuffer.Append(vHexZahl[1]);
                    iDest++;

                    if ((iDest % STEPWIDTH) == 0)
                    {
                        iStep *= 2;
                    }
                    offset = offset + iStep + f;
                    theByte.Clear();
                }
                else
                {
                    break;
                }
            } while (iDest < MAXIMPRINTLEN && (EntryPoint + offset) < bData.Length);

            if (iDest < MINIMPRINTLEN)
                sBuffer.Remove(0, sBuffer.Length);

            return sBuffer.ToString();
        }

        private static unsafe string MakeStringFromUTF8(byte* Text)
        {
            ArrayList tmp_ArrayList = new ArrayList();
            while (*Text != 0x00)
            {
                tmp_ArrayList.Add(*Text);
                Text++;
            }

            UTF8Encoding decoder = new UTF8Encoding();
            byte[] tmp_ByteArray = (Byte[])tmp_ArrayList.ToArray(typeof(byte));

			string str = decoder.GetString(tmp_ByteArray);

			Debug.WriteLine(str);

        	return str;
        }

        private unsafe bool processImageResourceDirectory(IMAGE_RESOURCE_DIRECTORY* pIrd, IMAGE_RESOURCE_DIRECTORY_ENTRY* pIrde, uint baserva, IMAGE_SECTION_HEADER* pIsh, byte* pData)
        {
            string sResType;
            UInt16 nEntries;
            uint i;
            if (Convert.ToBoolean((pIrde->Name & 0x80000000) >> 31)) // pIrde->Name ==> NameIsString? see Winnt.h
            {
            	return true;
                IMAGE_RESOURCE_DIR_STRING_U* pDirStringUnicode = (IMAGE_RESOURCE_DIR_STRING_U*)(pIrd + pIrde->OffsetToData);
                sResType = MakeStringFromUTF8((byte*)&pDirStringUnicode->NameString);
            }
            else
            {
                ResourceType eRT = (ResourceType)pIrde->Name;
                switch (eRT)
                {
                    case ResourceType.RT_VERSION:
                        sResType = ResourceType.RT_VERSION.ToString();
                        break;
                    case ResourceType.RT_ICON:
                        sResType = ResourceType.RT_ICON.ToString();
                        break;
                    case ResourceType.RT_GROUP_ICON:
                        sResType = ResourceType.RT_GROUP_ICON.ToString();
                        break;
                    default:
                        sResType = "Unknown";
                        break;
                }

            }

            if (!Convert.ToBoolean((pIrde->OffsetToData & 0x80000000) >> 31)) // pIrde->OffsetToData ==> DataIsDirectory? see Winnt.h
            {
                throw new Exception("A resource directory was expected but parsing failed");
            }

            IMAGE_RESOURCE_DIRECTORY* pIrdLevel_1 = (IMAGE_RESOURCE_DIRECTORY*)((baserva + pIrde->OffsetToData & 0x7fffffff));
            pIrde = (IMAGE_RESOURCE_DIRECTORY_ENTRY*)(pIrdLevel_1 + 1);

            nEntries = (UInt16)(pIrdLevel_1->NumberOfIdEntries + pIrdLevel_1->NumberOfNamedEntries);
            for (i = 0; i < nEntries; i++)
            {
                if (!processImageResourceDirectoryEntry(pIrdLevel_1, pIrde, baserva, sResType, pIsh, pData))
                {
                    throw new Exception("Error during image resource directory entry parsing.");
                }
                pIrde++;
            }

            return true;
        }

        private unsafe bool processImageResourceDirectoryEntry(IMAGE_RESOURCE_DIRECTORY* pIrd, IMAGE_RESOURCE_DIRECTORY_ENTRY* pIrde, uint baserva, string sResType, IMAGE_SECTION_HEADER* pIsh, byte* pData)
        {
            //string sResName;
            UInt16 nEntries;
            uint i;

			/*
            if (Convert.ToBoolean((pIrde->Name & 0x80000000) >> 31)) // pIrde->Name ==> NameIsString? see Winnt.h
            {
                IMAGE_RESOURCE_DIR_STRING_U* pDirStringUnicode = (IMAGE_RESOURCE_DIR_STRING_U*)(pIrd + pIrde->OffsetToData);
                sResName = MakeStringFromUTF8((byte*)&pDirStringUnicode->NameString);
            }
			 */

            if (!Convert.ToBoolean((pIrde->OffsetToData & 0x80000000) >> 31)) // pIrde->OffsetToData ==> DataIsDirectory? see Winnt.h
            {
                throw new Exception("A resource directory was expected but parsing failed");
            }

            IMAGE_RESOURCE_DIRECTORY* pIrdLevel_2 = (IMAGE_RESOURCE_DIRECTORY*)((baserva + pIrde->OffsetToData & 0x7fffffff));
            IMAGE_RESOURCE_DIRECTORY_ENTRY* pIrdeLevel_2 = (IMAGE_RESOURCE_DIRECTORY_ENTRY*)(pIrdLevel_2 + 1);

            nEntries = (UInt16)(pIrdLevel_2->NumberOfIdEntries + pIrdLevel_2->NumberOfNamedEntries);

            for (i = 0; i < nEntries; i++)
            {
                IMAGE_RESOURCE_DATA_ENTRY* irdata = (IMAGE_RESOURCE_DATA_ENTRY*)(baserva + pIrdeLevel_2->OffsetToData);

                if (sResType == ResourceType.RT_VERSION.ToString())
                {
                    if (!processVersion_Information(irdata, baserva, pIsh, pData))
                        return false;
                }

            	if (sResType == ResourceType.RT_GROUP_ICON.ToString())
            	{
					if (!processVersion_Icon(irdata, baserva, pIsh, pData))
						return false;
            	}

                pIrdeLevel_2++;
            }

            return true;
        }

        private static unsafe string MakeStringFromUTF8_2(byte* Text, int max_length)
        {
            ArrayList tmp_ArrayList = new ArrayList();
            //UTF8Encoding decoder = new UTF8Encoding();
            byte bTmp;
            int iA;
            int iB;

            if (max_length <= 0)
                max_length = (int)Math.Pow(2, 16);

            for (int i = 0; i < max_length; i++)
            {
                // Ugly code but its needed to get 2 byte values...
                iA = *Text;
                Text++;
                iB = *Text;
                bTmp = Convert.ToByte(iA + iB);

                if (bTmp != 0x00)
                {
                    tmp_ArrayList.Add(bTmp);
                    Text++;
                }
                else
                {
                    break;
                }
            }

            byte[] tmp_ByteArray = (Byte[])tmp_ArrayList.ToArray(typeof(byte));
            //return Encoding.Default.GetString(tmp_ByteArray);
            return Encoding.GetEncoding(1252).GetString(tmp_ByteArray);
        }

        private static uint dword_align(uint iOffset, uint iBase)
        {
            iOffset += iBase;
            return (iOffset + 3) - ((iOffset + 3) % 4) - iBase;
        }

        private unsafe bool processVersion_Information(IMAGE_RESOURCE_DATA_ENTRY* irdata, uint baserva, IMAGE_SECTION_HEADER* pIsh, byte* pData)
        {
            uint offset;
            uint ustr_offset;
            string sVersionInfoString;

            offset =      (irdata->OffsetToData - pIsh->VirtualAddress) + pIsh->PointerToRawData; // OffsetFromRVA
            VS_VERSIONINFO* pVI = (VS_VERSIONINFO*)(offset + pData);

            ustr_offset = (irdata->OffsetToData - pIsh->VirtualAddress) + pIsh->PointerToRawData + (uint)sizeof(VS_VERSIONINFO) + (uint)pData;
            IMAGE_RESOURCE_INFO_STRING_U* pDirStringUnicode = (IMAGE_RESOURCE_INFO_STRING_U*)(ustr_offset);

            sVersionInfoString = MakeStringFromUTF8_2((byte*)&pDirStringUnicode->String, (int)pVI->wValueLength);
            if (sVersionInfoString != "VS_VERSION_INFO")
            {
                throw new Exception("Invalid VS_VERSION_INFO block detected");
            }

            uint fixedfileinfo_offset = dword_align(((uint)sizeof(VS_VERSIONINFO) + 2 * ((uint)sVersionInfoString.Length + 1)), (uint)irdata->OffsetToData);
            VS_FIXEDFILEINFO* pFFI = (VS_FIXEDFILEINFO*)(fixedfileinfo_offset + offset + pData);

            if (pFFI->dwSignature != 0xfeef04bd) // 4277077181
            {
                throw new Exception("Wrong VS_FIXED_FILE_INFO signature detected.");
            }

            uint stringfileinfo_offset = dword_align((fixedfileinfo_offset + (uint)sizeof(VS_FIXEDFILEINFO)), (uint)irdata->OffsetToData);
            uint original_stringfileinfo_offset = stringfileinfo_offset;

            while (true)
            {
                STRING_FILE_INFO* pSFI = (STRING_FILE_INFO*)(stringfileinfo_offset + offset + pData);
                IMAGE_RESOURCE_INFO_STRING_U* pDirStringUnicode_2 = (IMAGE_RESOURCE_INFO_STRING_U*)(ustr_offset + stringfileinfo_offset);
                string stringfileinfo_string = MakeStringFromUTF8_2((byte*)&pDirStringUnicode_2->String, pSFI->Length);

                if (stringfileinfo_string.StartsWith("StringFileInfo"))
                {
                    //if (pSFI->Type == 1 && pSFI->ValueLength == 0)
                    //{
                    uint stringtable_offset = dword_align((stringfileinfo_offset + (uint)sizeof(STRING_FILE_INFO) + 2 * ((uint)stringfileinfo_string.Length) + 1), (uint)irdata->OffsetToData);

                    while (true)
                    {
                        STRING_TABLE* pST = (STRING_TABLE*)(stringtable_offset + offset + pData);

                        if ((pST->Length + pST->ValueLength) == 0)
                            break;

                        IMAGE_RESOURCE_INFO_STRING_U* pDirStringUnicode_3 = (IMAGE_RESOURCE_INFO_STRING_U*)(ustr_offset + stringtable_offset);
                        string stringtable_string = MakeStringFromUTF8_2((byte*)&pDirStringUnicode_3->String, pST->Length);

                        uint entry_offset = dword_align(stringtable_offset + (uint)sizeof(STRING_TABLE) + 2 * ((uint)stringtable_string.Length + 1), (uint)irdata->OffsetToData);

                        // Now get all entries

                        while (entry_offset < stringtable_offset + pST->Length)
                        {
                            STRING_FORMAT* pSF = (STRING_FORMAT*)(entry_offset + offset + pData);

                            if ((pSF->Length + pSF->ValueLength) == 0)
                                break;

                            IMAGE_RESOURCE_INFO_STRING_U* pDirStringUnicode_Key = (IMAGE_RESOURCE_INFO_STRING_U*)(ustr_offset + entry_offset);
                            string key = MakeStringFromUTF8_2((byte*)&pDirStringUnicode_Key->String, pSF->Length);
                            uint value_offset = dword_align(entry_offset + 2 + (2 * (uint)key.Length + 1), (uint)irdata->OffsetToData);
                            IMAGE_RESOURCE_INFO_STRING_U* pDirStringUnicode_Value = (IMAGE_RESOURCE_INFO_STRING_U*)(ustr_offset + value_offset - 2);
                            string value = MakeStringFromUTF8_2((byte*)&pDirStringUnicode_Value->String, pSF->ValueLength);

							if (!m_VersionInfo.ContainsKey(key))
								m_VersionInfo.Add(key, value);
							else
								System.Diagnostics.Debug.WriteLine("Schon drinne");


                            if (pSF->Length == 0)
                            {
                                entry_offset = stringtable_offset + pST->Length;
                            }
                            else
                            {
                                entry_offset = dword_align(pSF->Length + entry_offset, (uint)irdata->OffsetToData);
                            }
                        }
                        break;
                    }
                    //}
                }
                else if (stringfileinfo_string.StartsWith("VarFileInfo"))
                {
                    // TODO: Handle VarFileInfo
                }

                stringfileinfo_offset = stringfileinfo_offset + pSFI->Length;
                if (pSFI->Length == 0 || stringfileinfo_offset >= pVI->wLength)
                    break;
            }

            return true;
        }

		private unsafe bool processVersion_Icon(IMAGE_RESOURCE_DATA_ENTRY* irdata, uint baserva, IMAGE_SECTION_HEADER* pIsh, byte* pData)
		{
			uint offset;
			uint ustr_offset;
			string sVersionInfoString;

			offset = irdata->OffsetToData - pIsh->VirtualAddress + pIsh->PointerToRawData; // OffsetFromRVA
			ICOHEADER* piHeader = (ICOHEADER*)(offset + pData);

			if (piHeader->imgcount > 0)
			{
				ICODATA* pIcon = (ICODATA*) (offset + pData + sizeof (ICOHEADER));

				//pIcon->

				BITMAPINFOHEADER* pDIP = (BITMAPINFOHEADER*)(pData + pIcon->imgadr);

			}

			return true;
		}


        #region constants

        private const int STARTPOS = 10;
        private const int STEPWIDTH = 15;
        private const int STARTSTEP = 5;
        private const int MINIMPRINTLEN = 20;
        private const int MAXIMPRINTLEN = 256;

        #endregion

        #region structs

		[StructLayout(LayoutKind.Sequential)]
		public struct BITMAPINFOHEADER
		{
			public uint biSize;
			public int biWidth;
			public int biHeight;
			public ushort biPlanes;
			public ushort biBitCount;
			public uint biCompression;
			public uint biSizeImage;
			public int biXPelsPerMeter;
			public int biYPelsPerMeter;
			public uint biClrUsed;
			public uint biClrImportant;

			public void Init()
			{
				biSize = (uint)Marshal.SizeOf(this);
			}
		}


		private struct ICOHEADER
		{
			public short res0;
			public short imgtype;
			public short imgcount;
		}

		private struct ICODATA
		{
			public byte width;
			public byte height;
			public byte clcount;
			public byte res0;
			public short clplanes;
			public short bpp;
			public int imglen;
			public int imgadr;
		}

		public struct IconInfo
		{
			public bool fIcon;
			public int xHotspot;
			public int yHotspot;
			public IntPtr hbmMask;
			public IntPtr hbmColor;
		}

        [StructLayout(LayoutKind.Explicit)]
        struct IMAGE_DOS_HEADER
        {
            [FieldOffset(60)]
            public int e_lfanew;
        }

        [StructLayout(LayoutKind.Explicit)]
        struct IMAGE_NT_HEADERS32
        {
            [FieldOffset(0)]
            public uint Signature;
            [FieldOffset(4)]
            public IMAGE_FILE_HEADER FileHeader;
            [FieldOffset(24)]
            public IMAGE_OPTIONAL_HEADER32 OptionalHeader;
        } // -> uint -> 32 bit (4 byte), IMAGE_FILE_HEADER 20 byte,

        struct IMAGE_NT_HEADERS64
        {
            public uint Signature;
            public IMAGE_FILE_HEADER FileHeader;
            public IMAGE_OPTIONAL_HEADER64 OptionalHeader;
        } // -> uint -> 32 bit (4 byte), IMAGE_FILE_HEADER 20 byte

        struct IMAGE_FILE_HEADER
        {
            public ushort Machine;
            public ushort NumberOfSections;
            public uint TimeDateStamp;
            public uint PointerToSymbolTable;
            public uint NumberOfSymbols;
            public ushort SizeOfOptionalHeader;
            public ushort Characteristics;
        } // ushort -> 16 bit (2 byte), uint -> 32 bit (4 byte) ==> 8 byte + 12 byte = 20 byte

        [StructLayout(LayoutKind.Explicit)]
        struct IMAGE_OPTIONAL_HEADER32
        {
            [FieldOffset(0)]
            public ushort Magic;
            [FieldOffset(16)]
            public uint AddressOfEntryPoint;
            [FieldOffset(20)]
            public uint BaseOfCode;
            [FieldOffset(28)]
            public uint ImageBase; // -> 4 byte to read
            [FieldOffset(92)]
            public uint NumberOfRvaAndSizes;
            [FieldOffset(96)]
            public IMAGE_DATA_DIRECTORY ExportDataDirectory;
            [FieldOffset(104)]
            public IMAGE_DATA_DIRECTORY ImportDataDirectory;
            [FieldOffset(112)]
            public IMAGE_DATA_DIRECTORY ResourceDataDirectory;
            [FieldOffset(120)]
            public IMAGE_DATA_DIRECTORY ExceptionDataDirectory;
            [FieldOffset(128)]
            public IMAGE_DATA_DIRECTORY CertificateDataDirectory;
            [FieldOffset(136)]
            public IMAGE_DATA_DIRECTORY RelocationDataDirectory;
            [FieldOffset(144)]
            public IMAGE_DATA_DIRECTORY DebugDataDirectory;
            [FieldOffset(152)]
            public IMAGE_DATA_DIRECTORY ArchitectureDataDirectory;
            [FieldOffset(160)]
            public IMAGE_DATA_DIRECTORY GlobalPtrDataDirectory;
            [FieldOffset(168)]
            public IMAGE_DATA_DIRECTORY TLSDataDirectory;
            [FieldOffset(176)]
            public IMAGE_DATA_DIRECTORY ConfigDataDirectory;
            [FieldOffset(184)]
            public IMAGE_DATA_DIRECTORY BoundImportDataDirectory;
            [FieldOffset(192)]
            public IMAGE_DATA_DIRECTORY IATDataDirectory;
            [FieldOffset(200)]
            public IMAGE_DATA_DIRECTORY DelayImportDataDirectory;
            [FieldOffset(208)]
            public IMAGE_DATA_DIRECTORY CLRDataDirectory;
            [FieldOffset(216)]
            public IMAGE_DATA_DIRECTORY ReservedDataDirectory;
        }

        [StructLayout(LayoutKind.Explicit)]
        struct IMAGE_OPTIONAL_HEADER64
        {
            [FieldOffset(0)]
            public ushort Magic;
            [FieldOffset(16)]
            public uint AddressOfEntryPoint;
            [FieldOffset(20)]
            public uint BaseOfCode;
            [FieldOffset(24)]
            public UInt64 ImageBase; // -> 8 byte to read
            [FieldOffset(108)]
            public uint NumberOfRvaAndSizes;
            [FieldOffset(128)]
            public IMAGE_DATA_DIRECTORY ResourceDataDirectory;
            [FieldOffset(224)]
            public IMAGE_DATA_DIRECTORY DataDirectory;
        }

        struct IMAGE_DATA_DIRECTORY
        {
            public uint VirtualAddress; // This is the RVA
            public uint Size;
        } // uint -> 32 bit (4 byte) => 8 byte

        [StructLayout(LayoutKind.Explicit)]
        struct IMAGE_SECTION_HEADER
        {
            [FieldOffset(0)]
            public sbyte Name;
            [FieldOffset(8)]
            public uint VirtualSize;
            [FieldOffset(12)]
            public uint VirtualAddress;
            [FieldOffset(16)]
            public uint SizeOfRawData;
            [FieldOffset(20)]
            public uint PointerToRawData;
            [FieldOffset(24)]
            public uint PointerToRelocations;
            [FieldOffset(28)]
            public uint PointerToLinenumbers;
            [FieldOffset(32)]
            public ushort NumberOfRelocations;
            [FieldOffset(34)]
            public ushort NumberOfLinenumbers;
            [FieldOffset(36)]
            public uint Characteristics;
        } // sbyte -> 1 byte, ushort -> 16 bit (2 byte), uint -> 32 bit (4 byte) => 40 byte

        [StructLayout(LayoutKind.Explicit)]
        struct IMAGE_RESOURCE_DIRECTORY
        {
            [FieldOffset(0)]
            public uint Characteristics;
            [FieldOffset(4)]
            public uint TimeDateStamp;
            [FieldOffset(8)]
            public ushort MajorVersion;
            [FieldOffset(10)]
            public ushort MinorVersion;
            [FieldOffset(12)]
            public ushort NumberOfNamedEntries;
            [FieldOffset(14)]
            public ushort NumberOfIdEntries;
        } // uint -> 32 bit (4 byte), ushort -> 16 bit (2 byte) ==> 16 byte

        struct IMAGE_RESOURCE_DIRECTORY_ENTRY
        {
            public uint Name;
            public uint OffsetToData;
        } // uint -> 32 bit (4 byte) ==> 8 byte

        [StructLayout(LayoutKind.Explicit)]
        struct IMAGE_RESOURCE_DIRECTORY_STRING
        {
            [FieldOffset(0)]
            public ushort Length;
            [FieldOffset(2)]
            public sbyte NameString;
        } // ushort -> 16 bit (2 byte) ==> 3 byte

        [StructLayout(LayoutKind.Explicit)]
        struct IMAGE_RESOURCE_INFO_STRING_U
        {
            [FieldOffset(0)]
            public ushort String;
        } // ushort -> 16 bit (2 byte) ==> 2 byte

        [StructLayout(LayoutKind.Explicit)]
        struct IMAGE_RESOURCE_DIR_STRING_U
        {
            [FieldOffset(0)]
            public ushort Length;
            [FieldOffset(2)]
            public char NameString;
        } // ushort -> 16 bit (2 byte), char -> 16 bit (2 byte) ==> 4 byte

        struct IMAGE_RESOURCE_DATA_ENTRY
        {
            public uint OffsetToData;
            public uint Size;
            public uint CodePage;
            public uint Reserved;
        } // uint -> 32 bit (4 byte) ==> 16 byte

        struct VS_FIXEDFILEINFO
        {
            public uint dwSignature;
            public uint dwStrucVersion;
            public uint dwFileVersionMS;
            public uint dwFileVersionLS;
            public uint dwProductVersionMS;
            public uint dwProductVersionLS;
            public uint dwFileFlagMask;
            public uint dwFileFlags;
            public uint dwFileOS;
            public uint dwFileType;
            public uint dwFileSubtype;
            public uint dwFileDateMS;
            public uint dwFileDateLS;
        }

        [StructLayout(LayoutKind.Explicit)]
        struct VS_VERSIONINFO
        {
            [FieldOffset(0)]
            public ushort wLength;
            [FieldOffset(2)]
            public ushort wValueLength;
            [FieldOffset(4)]
            public ushort wType;
        } // ushort -> 16 bit (2 byte) ==> 6 byte

        [StructLayout(LayoutKind.Explicit)]
        struct STRING_FILE_INFO
        {
            [FieldOffset(0)]
            public ushort Length;
            [FieldOffset(2)]
            public ushort ValueLength;
            [FieldOffset(4)]
            public ushort Type;
        } // ushort -> 16 bit (2 byte) ==> 6 byte

        [StructLayout(LayoutKind.Explicit)]
        struct STRING_TABLE
        {
            [FieldOffset(0)]
            public ushort Length;
            [FieldOffset(2)]
            public ushort ValueLength;
            [FieldOffset(4)]
            public ushort Type;
        } // ushort -> 16 bit (2 byte) ==> 6 byte

        [StructLayout(LayoutKind.Explicit)]
        struct STRING_FORMAT
        {
            [FieldOffset(0)]
            public ushort Length;
            [FieldOffset(2)]
            public ushort ValueLength;
            [FieldOffset(4)]
            public ushort Type;
        } // ushort -> 16 bit (2 byte) ==> 6 byte

        [StructLayout(LayoutKind.Explicit)]
        struct RGBQUAD
        {
            [FieldOffset(0)]
            public byte rgbBlue;
            [FieldOffset(1)]
            public byte rgbGreen;
            [FieldOffset(2)]
            public byte rgbRed;
            [FieldOffset(3)]
            public byte rgbReserved;
        } // byte => 4 byte

        [StructLayout(LayoutKind.Explicit)]
        struct BITMAPINFO
        {
            [FieldOffset(0)]
            public BITMAPINFOHEADER bmiHeader;
            [FieldOffset(40)]
            public RGBQUAD bmiColors0;
            [FieldOffset(44)]
            public RGBQUAD bmiColors1;
            [FieldOffset(48)]
            public RGBQUAD bmiColors2;
            [FieldOffset(52)]
            public RGBQUAD bmiColors3;
            [FieldOffset(56)]
            public RGBQUAD bmiColors4;
            [FieldOffset(60)]
            public RGBQUAD bmiColors5;
            [FieldOffset(64)]
            public RGBQUAD bmiColors6;
            [FieldOffset(68)]
            public RGBQUAD bmiColors7;
            [FieldOffset(72)]
            public RGBQUAD bmiColors8;
            [FieldOffset(76)]
            public RGBQUAD bmiColors9;
            [FieldOffset(80)]
            public RGBQUAD bmiColors10;
            [FieldOffset(84)]
            public RGBQUAD bmiColors11;
            [FieldOffset(88)]
            public RGBQUAD bmiColors12;
            [FieldOffset(92)]
            public RGBQUAD bmiColors13;
            [FieldOffset(96)]
            public RGBQUAD bmiColors14;
            [FieldOffset(100)]
            public RGBQUAD bmiColors15;
        } // 40 Byte + 16 + 4 Byte = 104 Byte

        [StructLayout(LayoutKind.Explicit)]
        unsafe struct BITMAP
        {
            [FieldOffset(0)]
            public System.Int32 bmType;
            [FieldOffset(4)]
            public System.Int32 bmWidth;
            [FieldOffset(8)]
            public System.Int32 bmHeight;
            [FieldOffset(12)]
            public System.Int32 bmWidthBytes;
            [FieldOffset(16)]
            public ushort bmPlanes;
            [FieldOffset(18)]
            public ushort bmBitsPixel;
            [FieldOffset(20)]
            public fixed long bmBits[1];
        }

        [StructLayout(LayoutKind.Explicit)]
        struct GROUPICONDIR
        {
            [FieldOffset(0)]
            public ushort idReserved;
            [FieldOffset(2)]
            public ushort idType;
            [FieldOffset(4)]
            public ushort idCount;
            [FieldOffset(6)]
            public GROUPICONDIRENTRY idEntries;
        } // ushort -> 16 bit (2 byte) + 14 byte ==> 20 Byte

        [StructLayout(LayoutKind.Explicit)]
        struct GROUPICONDIRENTRY
        {
            [FieldOffset(0)]
            public byte bWidth;
            [FieldOffset(1)]
            public byte bHeight;
            [FieldOffset(2)]
            public byte bColorCount;
            [FieldOffset(3)]
            public byte bReserved;
            [FieldOffset(4)]
            public ushort wPlanes;
            [FieldOffset(6)]
            public ushort wBitCount;
            [FieldOffset(8)]
            public int dwBytesInRes;
            [FieldOffset(12)]
            public ushort nID;
        } // byte, int -> 32 bit (4 byte), ushort -> 16 bit (2 byte) ==> 14 byte

        struct ICONIMAGE
        {
            public BITMAPINFOHEADER icHeader;
            public RGBQUAD icColors; // Colortable
            public byte icXOR;
            public byte icAND;
        }
        #endregion

        #region private enums
        enum MachineType
        {
            Native = 0,
            AM33 = 0x01d3,
            AMD64 = 0x8664,
            ARM = 0x01c0,
            EBC = 0x0ebc,
            I386 = 0x014c,
            IA64 = 0x0200,
            MR32 = 0x9041,
            MIPS16 = 0x0266,
            MIPSFPU = 0x0366,
            MIPSFPU16 = 0x0466,
            POWERPC = 0x01f0,
            POWERPCFP = 0x01f1,
            R4000 = 0x0166,
            SH3 = 0x01a2,
            SH3DSP = 0x01a3,
            SH4 = 0x01a6,
            SH5 = 0x01a8,
            THUMB = 0x01c2,
            WCEMIPSV2 = 0x0169
        }

        enum ResourceType
        {
            RT_CURSOR = 1,
            RT_BITMAP = 2,
            RT_ICON = 3,
            RT_MENU = 4,
            RT_DIALOG = 5,
            RT_STRING = 6,
            RT_FONTDIR = 7,
            RT_FONT = 8,
            RT_ACCELERATOR = 9,
            RT_RCDATA = 10,
            RT_MESSAGETABLE = 11,
            RT_GROUP_CURSOR = 12,
            RT_GROUP_ICON = 14,
            RT_VERSION = 16,
            RT_DLGINCLUDE = 17,
            RT_PLUGPLAY = 19,
            RT_VXD = 20,
            RT_ANICURSOR = 21,
            RT_ANIICON = 22,
            RT_HTML = 23,
            RT_MANIFEST = 24
        }
        #endregion

        #region Properties

        public bool IsManagedFile
        {
            get { return m_IsManaged; }
        }

        public string BinImprint
        {
            get { return m_BinImprint; }
        }

		public Dictionary<string, string> VersionInfo
        {
            get { return m_VersionInfo; }
        }

        #endregion

        #region Membervariablen

        private bool m_IsManaged;
        private string m_BinImprint;
		private Dictionary<string, string> m_VersionInfo = new Dictionary<string, string>();

        #endregion



    }
}
