--
-- One Identity - Open Source License
--
-- Copyright 2018 One Identity LLC
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software. Any and all copies of the above
-- copyright and this permission notice contained in the Software shall not be
-- removed, obscured, or modified.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--



-- 28100
begin
	QBM_GSchema.PColumnAdd('Hardware', 'DisplayXResolution', 'number(14, 0) default 0');
	QBM_GSchema.PColumnAdd('Hardware', 'DisplayYResolution', 'number(14, 0) default 0');
	QBM_GSchema.PColumnAdd('Hardware', 'DisplayBitsPerPel', 'number(14, 0) default 0');
	QBM_GSchema.PColumnAdd('Hardware', 'UpdateUDF', 'number(1, 0) default 0');
	QBM_GSchema.PColumnAdd('Hardware', 'UpdateMac2Name', 'number(1, 0) default 0');
	QBM_GSchema.PColumnAdd('Hardware', 'DisplayVRefresh', 'number(14, 0) default 0');
end;
go



insert into DialogColumn( UID_DialogColumn
		, DataType, Template, IsOverwritingTemplate
		,Caption, PreProcessorCondition
	, HasLimitedValues, LimitedValues
	, XObjectKey
	, SchemaDataType , UID_DialogTable, Commentary,  ColumnName
	)
select x.UID_DialogColumn
		, x.DataType, x.Template, x.IsOverwritingTemplate
		,x.Caption, x.PreProcessorCondition
	, x.HasLimitedValues, x.LimitedValues
	, x.XObjectKey
	, x.SchemaDataType , x.UID_DialogTable, x.Commentary,  x.ColumnName
 from (select 'SDL-7C321119ADB9496691E55ACE98DC37CC' as UID_DialogColumn
				, 1 as DataType, 'If ($IsVIPC:bool$) Then
									 Dim strTmp As String = CStr($DisplayBitsPerPel:Int$)
									If strTmp = "" Or strTmp = "0" Then
										Value = 16 
									End If
								End If' as Template
				, 1 as IsOverwritingTemplate
				, 'Color depth [Bit]' as Caption
				, 'UAS' as PreProcessorCondition
				, 1 as HasLimitedValues
				, '0=0 Bit' || chr(7) || '8=8 Bit' || chr(7) || '16=16 Bit' || chr(7) || '24=24 Bit' || chr(7) || '32=32 Bit' as LimitedValues
				, '<Key><T>DialogColumn</T><P>SDL-7C321119ADB9496691E55ACE98DC37CC</P></Key>' as XObjectKey
				, 'NUMBER' as SchemaDataType
				, 'QER-T-Hardware' as UID_DialogTable
				, 'Graphical representation color depth in bits.' as Commentary
				, 'DisplayBitsPerPel' as ColumnName from dual
		union all
		select 'SDL-B6E30A244BDB41E4A5ABFC9CDD139532', 1, 'If ($IsVIPC:bool$) Then
     Dim strTmp As String = CStr($DisplayVRefresh:Int$)
    If strTmp = "" Or strTmp = "0" Then
        Value = 60
    End If
End If', 1, 'Refresh rate [Hz]', 'UAS', 1, '0=0 Hz' || chr(7) || '60=60 Hz' || chr(7) || '70=70 Hz' || chr(7) || '75=75 Hz' || chr(7) || '80=80 Hz' || chr(7) || '85=85 Hz', '<Key><T>DialogColumn</T><P>SDL-B6E30A244BDB41E4A5ABFC9CDD139532</P></Key>'
	, 'NUMBER', 'QER-T-Hardware', 'Monitor refresh rate in Hz.', 'DisplayVRefresh' from dual
		union all
		select 'SDL-56E515811A2B45C981106E6564E5A3ED', 1, 'If ($IsVIPC:bool$) Then
     Dim strTmp As String = CStr($DisplayXResolution:Int$)
    If strTmp = "" Or strTmp = "0" Then
        Value = 800
    End If
End If', 1, 'Screen resolution', 'UAS', 0, NULL, '<Key><T>DialogColumn</T><P>SDL-56E515811A2B45C981106E6564E5A3ED</P></Key>'
		, 'NUMBER', 'QER-T-Hardware', 'Horizontal resolution.', 'DisplayXResolution' from dual
		union all
		select 'SDL-2A745D37103E4CE79626733EC74F7ACC', 1, 'If ($IsVIPC:bool$) Then
     Dim strTmp As String = CStr($DisplayYResolution:Int$)
    If strTmp = "" Or strTmp = "0" Then
        Value = 600
    End If
End If', 1, 'Vertical screen resolution', 'UAS', 0, NULL, '<Key><T>DialogColumn</T><P>SDL-2A745D37103E4CE79626733EC74F7ACC</P></Key>', 
	'NUMBER', 'QER-T-Hardware', 'Vertical resolution.', 'DisplayYResolution' from dual
		union all
		select 'SDL-A388124B6169412582E0BBCF2ACA0F0D', 0, NULL, 0, 'Update Mac2Name', 'UAS', 0, NULL, '<Key><T>DialogColumn</T><P>SDL-A388124B6169412582E0BBCF2ACA0F0D</P></Key>'
			, 'NUMBER', 'QER-T-Hardware', 'Option set to 1 by the customizer if changes are made to Mac2Name.VII relevant properties.', 'UpdateMac2Name' from dual
		union all
		select 'SDL-3F24EC168D554590B2C4DD382A9857DE', 0, NULL, 0, 'Update UDF', 'UAS', 0, NULL, '<Key><T>DialogColumn</T><P>SDL-3F24EC168D554590B2C4DD382A9857DE</P></Key>'
		, 'NUMBER', 'QER-T-Hardware', 'Option set to 1 by the customizer if changes are made to <Maschinentyp>.UDF relevant properties.', 'UpdateUDF' from dual
	) x
	where not exists (select 1
						from DialogColumn c
						where c.UID_DialogColumn = x.UID_DialogColumn
					)
go

