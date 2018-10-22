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


 
---------------------------------------------------------------------------------
-- SpezialProzedur zum automatischen Auffllen der Tabelle OSInsttype 
---------------------------------------------------------------------------------
exec QBM_PProcedureDrop 'SDL_PFILLOsInsttype'
go


---<istoignore/>

create procedure SDL_PFILLOsInsttype
-- with encryption
as
begin
BEGIN TRY

insert into osinsttype ( UID_InstallationType,UID_OS, XObjectKey
						, Ident_InstType, Ident_OS
						, UID_OsInstType)
select x.UID_InstallationType, x.UID_OS, dbo.QBM_FCVElementToObjectKey1('osinsttype', 'UID_OsInstType', x.UID_OsInstType)
			, x.Ident_InstType, x.Ident_OS
			, x.UID_OsInstType
 from
	(
		select o.UID_OS, o.Ident_OS, i.UID_InstallationType, i.Ident_InstType, NEWID() as UID_OsInstType
			from os o cross join  installationtype i
		where Not exists (select top 1 1 
							from OsInstType oi
							where oi.UID_InstallationType = i.UID_InstallationType
							 and oi.UID_OS = o.UID_OS
						)
	) as x


delete from osinsttype 
where UID_OS not in (select UID_OS from os)

-- CK 2004-04-21: ich glaube, es sollte so heissen:
--delete from installationtype 
delete from osinsttype
where UID_InstallationType not in (select UID_InstallationType from Installationtype)

END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

	exec QBM_PRollbackIfAllowed 

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	

end
go

