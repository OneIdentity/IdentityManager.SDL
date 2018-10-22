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





--------------------------------------------------------------------------------------------------------
-- auffllen der AppserverGot xx  - Tabellen, mit allen Zuordnungen, die der FDS hat, 
--		die in den darunterliegenden Servern jedoch nicht vorhanden sind
--------------------------------------------------------------------------------------------------------

exec QBM_PProcedureDrop 'SDL_PRepairAppServerGotXX'
go

-- Aufrufbeispiel: exec SDL_PRepairAppServerGotXX					-- alles fr alle Domnen
--			exec SDL_PRepairAppServerGotXX N'DHERMES01'		-- alles fr die Domne DHERMES01
--			exec SDL_PRepairAppServerGotXX N'DHERMES01', N'MAC'		-- Maschinentypen fr Domne DHERMES01

--			exec SDL_PRepairAppServerGotXX N'', N'APP'			-- Applikationsprofile fr alle Domnen
--			exec SDL_PRepairAppServerGotXX N'DHERMES01', N'APP DRV'	-- Applikations- und Treiberprofile fr Domne DHERMES01

-- This procedure is exclusively used in the DBScheduler
---<istoignore/>

create procedure SDL_PRepairAppServerGotXX (@Ident_Domain nvarchar(64) = N'',	-- wenn angegeben, wird nur fr diese Domne Reparatur ausgefhrt
						@type nvarchar(64) = N'' 		-- wenn angegeben, wird nur fr den Type die Reparatur ausgefhrt
										-- zulssig sind APP, DRV und MAC
					)
						
--
-- with encryption 
as
begin
-- exec QBM_PProcedureNestLevelCheck @@ProcID

declare @intern_domain nvarchar(64)
declare @uid_applicationserver varchar(38)
declare @childserver table(uid_childserver varchar(38)collate database_default)
declare @vorher int
declare @nachher int
declare @intern_type nvarchar(64)



BEGIN TRY

 if @Ident_Domain = ''
  begin
	select @intern_domain = N'%'
  end
 else
  begin
	select @intern_domain = @Ident_Domain
  end


 if @type = ''
  begin
	select @intern_type = N'APP DRV MAC'
  end
 else
  begin
	select @intern_type = @type
  end

-- bestimme alle fds

-- Aufrumen von Profilinformationen, zu denen es die Profile nicht (mehr) gibt
 if @intern_type like N'%app%'
  begin
	 delete appservergotappprofile where uid_profile not in (select uid_profile from applicationprofile)
				and uid_profile in (select uid_profile from applicationprofile where Ident_DomainRD like @intern_domain )
  end

 if @intern_type like N'%drv%'
  begin
	 delete appservergotdriverprofile where uid_profile not in (select uid_profile from driverprofile)
				and uid_profile in (select uid_profile from driverprofile where Ident_DomainRD like @intern_domain )
  end

 if @intern_type like N'%mac%'
  begin
	 delete appservergotmactypeinfo where UID_MachineType not in (select UID_MachineType from machinetype)
				and UID_MachineType in (select UID_MachineType from machinetype where Ident_DomainMachineType like @intern_domain )
  end


-- Aufrumen von Profilinformationen, zu denen es die Applikationsserver nicht (mehr) gibt
 if @intern_type like N'%app%'
  begin
	 delete appservergotappprofile where UID_ApplicationServer not in (select UID_ApplicationServer from Applicationserver)
				and uid_profile in (select uid_profile from applicationprofile where Ident_DomainRD like @intern_domain )
  end

 if @intern_type like N'%drv%'
  begin
	 delete appservergotdriverprofile where UID_ApplicationServer not in (select UID_ApplicationServer from Applicationserver)
				and uid_profile in (select uid_profile from driverprofile where Ident_DomainRD like @intern_domain )
  end

 if @intern_type like N'%mac%'
  begin
	 delete appservergotmactypeinfo where UID_ApplicationServer not in (select UID_ApplicationServer from Applicationserver)
				and UID_MachineType in (select UID_MachineType from machinetype where Ident_DomainMachineType like @intern_domain )
  end



 DECLARE schrittRepairAppServerGotXX CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
	-- alle FDS bestimmen und einzeln verarbeiten
	select uid_applicationserver from applicationserver where isnull(uid_parentapplicationserver, '') = ''
						and Ident_Domain like @intern_domain

  
 OPEN schrittRepairAppServerGotXX
 FETCH NEXT FROM schrittRepairAppServerGotXX into @uid_applicationserver
 WHILE (@@fetch_status <> -1)
 BEGIN
	delete @childserver
-- Testausgabe
--     print N'neuer FDS'
--	select ident_server, Ident_Domainserver from server where uid_server in (select uid_server from applicationserver where uid_applicationserver = @uid_applicationserver)


	-- je FDS alle darunter hngenden Applikationsserver einsammeln
	insert into @childserver (uid_childserver)
		values (@uid_applicationserver)
	select @nachher = 1
	marke:
	select @vorher = @nachher
	insert into @childserver (uid_childserver)
		select a.uid_applicationserver from applicationserver a
			where a.uid_parentapplicationserver in (select uid_childserver from @childserver)
			and not exists (select top 1 1 from @childserver b where b.uid_childserver = a.uid_applicationserver)
	select @nachher = count(*) from @childserver
	if @nachher <> @vorher goto marke
	-- alle darunterhngenden Applikationsserver sollten eingesammelt sein

-- Kontrollausgaben
--	select * from applicationserver where uid_applicationserver = @uid_applicationserver
--	select * from applicationserver where uid_applicationserver in (select uid_childserver from @childserver)
--	select * from appservergotappprofile WHERE UID_APPLICATIONSERVER not in (select uid_applicationserver from applicationserver where isnull(uid_parentapplicationserver, N'') = N'')


	 if @intern_type like N'%app%'
	  begin
-- print ' die aufzufllenden Applikationen'
		insert into appservergotappprofile (UID_ApplicationServer , UID_Profile, XDateInserted, XDateUpdated , XUserInserted , XUserUpdated , 
				ChgNumber, /* IsReady */   ProfileStateProduction,   ProfileStateShadow , XObjectKey)
			select 	c.uid_childserver, g.uid_profile, GetUTCDate(), GetUTCDate(), N'RepairAppServer', N'RepairAppServer', 
				0, /* 1 */ 		N'READY', N'EMPTY', dbo.QBM_FCVElementToObjectKey2('appservergotappprofile', 'UID_ApplicationServer', 	c.uid_childserver, 'UID_Profile', g.uid_profile)
				from @childserver c, appservergotappprofile g
				where g.uid_applicationserver = @uid_applicationserver
					and not exists (select top 1 1 from appservergotappprofile a 
									where c.uid_childserver = a.uid_applicationserver
									 and g.uid_profile = a.uid_profile
							)
				and exists (select top 1 1 from applicationprofile z where z.uid_profile =g.uid_profile and isnull(chgnumber,0) > 0)
	  end

	 if @intern_type like N'%drv%'
	  begin
-- print ' die aufzufllenden Treiber'
		insert into appservergotdriverprofile (UID_ApplicationServer , UID_Profile, XDateInserted, XDateUpdated , XUserInserted , XUserUpdated , ChgNumber, 
			/* IsReady */ ProfileStateProduction,   ProfileStateShadow, XObjectKey)
			select c.uid_childserver, g.uid_profile, GetUTCDate(), GetUTCDate(), N'RepairAppServer', N'RepairAppServer', 0,--1
					N'READY', N'EMPTY', dbo.QBM_FCVElementToObjectKey2('appservergotdriverprofile', 'UID_ApplicationServer', c.uid_childserver, 'UID_Profile', g.uid_profile)
				from @childserver c, appservergotdriverprofile g
				where g.uid_applicationserver = @uid_applicationserver
					and not exists (select top 1 1 from appservergotdriverprofile a 
									where c.uid_childserver = a.uid_applicationserver
									 and g.uid_profile = a.uid_profile
							)
				and exists (select top 1 1 from driverprofile z where z.uid_profile =g.uid_profile and isnull(chgnumber,0) > 0)
	  end

	 if @intern_type like N'%mac%'
	  begin
-- print ' die aufzufllenden Maschinentypen'
		insert into appservergotmactypeinfo (UID_ApplicationServer , UID_MachineType, XDateInserted, XDateUpdated , XUserInserted , XUserUpdated , ChgNumber, 
			/* IsReady */ ProfileStateProduction,   ProfileStateShadow, XObjectKey)
			select c.uid_childserver, g.UID_MachineType, GetUTCDate(), GetUTCDate(), N'RepairAppServer', N'RepairAppServer', 0, -- 1
					N'READY', N'EMPTY', dbo.QBM_FCVElementToObjectKey2('appservergotmactypeinfo', 'UID_ApplicationServer',  c.uid_childserver, 'UID_MachineType', g.UID_MachineType)
				from @childserver c, appservergotmactypeinfo g
				where g.uid_applicationserver = @uid_applicationserver
					and not exists (select top 1 1 from appservergotmactypeinfo a 
									where c.uid_childserver = a.uid_applicationserver
									 and g.UID_MachineType = a.UID_MachineType
							)

				and exists (select top 1 1 from machinetype z where z.uid_machinetype =g.uid_machinetype and isnull(chgnumber,0) > 0)
	  end

     FETCH NEXT FROM schrittRepairAppServerGotXX INTO @uid_applicationserver
 END
 close schrittRepairAppServerGotXX
 deallocate schrittRepairAppServerGotXX


END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'schrittRepairAppServerGotXX'
	exec QBM_PRollbackIfAllowed 

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	
end
go









