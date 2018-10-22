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



------------------------------------------------------------------------------------------
-- Prozedur SDL_PPersonHasAppCreate
------------------------------------------------------------------------------------------

exec QBM_PProcedureDrop 'SDL_PPersonHasAppCreate'
go


---<summary>maps PERSON objects to their APPLICATION objects according TO accountinGroup relations</summary>
---<remarks>
--- Functionality depends on the flag IsAppGroup in NT, ADS and LDAP
--- if an account is member in an applicationgroup the assigned person will get an assignment to the according application
---</remarks>
---<example>
---<code>
---exec SDL_PPersonHasAppCreate
---</code></example>
---<seealso cref="QBM_PCursorDrop" type="Procedure">Procedure QBM_PCursorDrop</seealso>
---<seealso cref="QBM_FCVElementToObjectKey2" type="Function">Function QBM_FCVElementToObjectKey2</seealso>
---<seealso cref="QBM_FGIErrorMessage" type="Function">Function QBM_FGIErrorMessage</seealso>
---<seealso cref="QBM_PRollbackIfAllowed" type="Procedure">Procedure QBM_PRollbackIfAllowed</seealso>

create procedure SDL_PPersonHasAppCreate 
 
-- with encryption 
AS
begin
-- exec QBM_PProcedureNestLevelCheck @@ProcID
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

declare @uid_ADSaccount varchar(38)
declare @uid_LDAPaccount varchar(38)

declare @uid_person varchar(38)
declare @uid_ADSgroup varchar(38)
declare @uid_LDAPgroup varchar(38)

declare @uid_application varchar(38)
declare @hstr nvarchar(1023)

BEGIN TRY


DECLARE accounts CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR  
	select a.uid_Adsaccount,  d.uid_person, c.uid_ADSgroup, e.uid_application 
	from adsaccountinADSGroup a, ADSAccount b, ADSGroup c, person d, application e 
	where d.uid_person = b.uid_person  
		and a.uid_ADSaccount= b.uid_ADSaccount 
		and a.uid_ADSgroup=c.uid_ADSgroup 
		and e.Ident_SectionName=c.cn  
		and c.IsApplicationGroup =1 
		and a.XOrigin > 0 and a.XIsInEffect = 1
  
OPEN accounts
	FETCH NEXT FROM accounts into @uid_ADSaccount,  @uid_person, @uid_ADSgroup, @uid_application 


WHILE (@@fetch_status <> -1)
BEGIN

	
	if not exists (select top 1 1 from personhasapp where uid_person=@uid_person and uid_application = @uid_application)
	begin 
		--select @hstr= N'select * from personhasapp t o t a l where uid_person= ''' + @uid_person + N''' and uid_application= N''' + @uid_application + N''''
		--print @hstr
		insert into personhasapp (uid_person, uid_application  , XObjectKey
			, XOrigin)
		 values (@uid_person, @uid_application, dbo.QBM_FCVElementToObjectKey2('personhasapp', 'uid_person', @uid_person, 'uid_application', @uid_application)
		 		, dbo.QBM_FGIBitPatternXOrigin('|Direct|', 0)
		  )
	end
	
	update
	--delete from 
		ADSAccountInADSGroup 
		set XOrigin = (uig.XOrigin & dbo.QBM_FGIBitPatternXOrigin('|direct|', 1)) | dbo.QBM_FGIBitPatternXOrigin('Inherit', 0)
		from ADSAccountInADSGroup uig 
		where uig.UID_ADSAccount = @uid_ADSaccount 
		 and uig.UID_ADSGroup = @uid_ADSgroup

	FETCH NEXT FROM accounts into @uid_ADSaccount,  @uid_person, @uid_ADSgroup, @uid_application 

end
close accounts
deallocate accounts

-- und noch mal für LDAP

DECLARE accounts CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR  
	select a.uid_LDAPaccount,  d.uid_person, c.uid_LDAPgroup, e.uid_application 
	from LDAPaccountinLDAPGroup a, LDAPAccount b, LDAPGroup c, person d, application e 
	where d.uid_person = b.uid_person  
		and a.uid_LDAPaccount= b.uid_LDAPaccount 
		and a.uid_LDAPgroup=c.uid_LDAPgroup 
		and e.Ident_SectionName=c.cn  
		and c.IsApplicationGroup =1 
		and a.XOrigin > 0 and a.XIsInEffect = 1
  
OPEN accounts
	FETCH NEXT FROM accounts into @uid_LDAPaccount,  @uid_person, @uid_LDAPgroup, @uid_application 


WHILE (@@fetch_status <> -1)
BEGIN

	
	if not exists (select top 1 1 from personhasapp where uid_person=@uid_person and uid_application = @uid_application)
	begin 
		--select @hstr= N'select * from personhasapp t o t a l where uid_person= ''' + @uid_person + N''' and uid_application= N''' + @uid_application + N''''
		--print @hstr
		insert into personhasapp (uid_person, uid_application , XObjectKey, XOrigin) 
			select @uid_person, @uid_application, dbo.QBM_FCVElementToObjectKey2('personhasapp', 'uid_person', @uid_person, 'uid_application', @uid_application)
					, dbo.QBM_FGIBitPatternXOrigin('|Direct|', 0)
	end
	
	update 
	--delete from 
		LDAPAccountInLDAPGroup 
		set XOrigin = (uig.XOrigin & dbo.QBM_FGIBitPatternXOrigin('|direct|', 1)) | dbo.QBM_FGIBitPatternXOrigin('Inherit', 0)
		from LDAPAccountInLDAPGroup uig
		where uig.UID_LDAPAccount = @uid_LDAPaccount 
		 and uig.UID_LDAPGroup = @uid_LDAPgroup

	FETCH NEXT FROM accounts into @uid_LDAPaccount,  @uid_person, @uid_LDAPgroup, @uid_application 

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
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'accounts'  
	exec QBM_PRollbackIfAllowed 

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	

end
go

