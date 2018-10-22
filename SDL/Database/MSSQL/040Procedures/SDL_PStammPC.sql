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



--------------------------------------------------------------------------------------
-- Zuordnung Stamm-PC
--------------------------------------------------------------------------------------
exec QBM_PProcedureDrop 'SDL_PStammPC'
go


---<summary>Finds the accounts that have a WorkDesk given as default PC</summary>
---<param name="uid_WorkDesk" type="varchar(38)">UID of WorkDesk to check</param>
---<remarks>
---The property uid_Hardwaredefaultmachine is updated in ADSAccount 
--- Procedure is only required in connection with software distribution
---</remarks>
---<example>
---<code>
---exec SDL_PStammPC '123-456'
---</code></example>
---<seealso cref="QBM_PCursorDrop" type="Procedure">Procedure QBM_PCursorDrop</seealso>
---<seealso cref="QBM_PGenprocidGetFromContext" type="Procedure">Procedure QBM_PGenprocidGetFromContext</seealso>
---<seealso cref="QBM_FGIErrorMessage_Code" type="Function">Function QBM_FGIErrorMessage_Code</seealso>
---<seealso cref="QBM_PRollbackIfAllowed" type="Procedure">Procedure QBM_PRollbackIfAllowed</seealso>

create procedure  SDL_PStammPC( @uid_WorkDesk varchar(38) 
							)
 
-- with encryption 
as
begin
declare @uid_Hardware  varchar(38)
declare @uid_adsaccount varchar(38)

declare @SQLcmd nvarchar(max)
declare @whereclause nvarchar(2000)

 declare @GenProcID varchar(38)
 declare @AdditionalObjectKeysAffected_CSU QBM_YParameterList -- compiler shut up
BEGIN TRY

 declare @OperationLevel int 
 declare @XUser nvarchar(64)
	exec @OperationLevel = QBM_PGenprocidGetFromContext @GenProcID output, @XUser output , @CodeID = @@ProcID


-- den pc an diesem WorkDesk selektieren
-- Änderung wegen 11545, Hardware kann auch leer sein, und der PC muß nicht per UAS aufgestezt sein
select top 1 @uid_Hardware = uid_Hardware from Hardware where uid_WorkDesk = @uid_WorkDesk and ispc=1
if @uid_Hardware is null
 begin
      select @uid_Hardware = ''
 end
  

-- die ads-accounts der personen, die diesen WorkDesk zugeordnet haben selektieren
DECLARE accounts CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR  

select uid_ADSAccount  
from person a join ADSAccount b
on a.uid_WorkDesk = @uid_WorkDesk 
	and a.uid_person = b.uid_person 
--		and a.uid_WorkDesk is not null 
--		and a.uid_WorkDesk<>''
		and a.uid_WorkDesk > ' '
--16592
						join dialogColumn c on c.UID_DialogTable = 'ADS-T-ADSAccount'
											and c.columnname = 'uid_Hardwaredefaultmachine'
											and c.IsDeactivatedByPreProcessor = 0
--/ 16592

  
OPEN accounts
FETCH NEXT FROM accounts into @uid_adsaccount

WHILE (@@fetch_status <> -1)
BEGIN

	select @whereclause = N'uid_adsaccount= ''' + @uid_adsaccount + N''''

	exec QBM_PJobCreate_HOUpdate 'ADSAccount', @whereclause, @GenProcID
							, @ObjectKeysAffected = @AdditionalObjectKeysAffected_CSU
							, @p1 = 'uid_Hardwaredefaultmachine', @v1 = @uid_Hardware 
							, @isToFreezeOnError  = 1


  FETCH NEXT FROM accounts into @uid_adsaccount

end
close accounts
deallocate accounts



END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
-- kleine Reparatur, Problem von Steffen gemeldet 2008-12-11
    select @ErrorMessage = dbo.QBM_FGIErrorMessage_Code(@SQLCmd)

    exec QBM_PCursorDrop 'accounts'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	

end
go
