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



exec QBM_PProcedureDrop 'SDL_PFillPAS'
go


-- Verwendung erfolgt ausschließlich innerhalb alter VI-App-Profil Handling, deshalb:
---<istoignore/>

create procedure SDL_PFillPAS @appserver varchar(38)
 -- beflle einen PAS mit allen Profilen, die sein bergeordneter Appsserver hat (apps, drv, Mactype)
 
-- with encryption 
AS
begin

declare @txt nvarchar(255)
declare @server  nvarchar(85)
declare @apps  nvarchar(85)
declare @drv  nvarchar(85)
declare @uid_mactype  varchar(38)
--declare @dommactype  identifier
declare @chg  int
--declare @IsInvalidDomain int
declare @where nvarchar(255)
declare @BasisObjectKey varchar(138)

 declare @GenProcID varchar(38)
 declare @AdditionalObjectKeysAffected_CSU QBM_YParameterList -- compiler shut up
BEGIN TRY

 declare @OperationLevel int 
 declare @XUser nvarchar(64)
	exec @OperationLevel = QBM_PGenprocidGetFromContext @GenProcID output, @XUser output , @CodeID = @@ProcID

--wenn die domne, fr die der PAS arbeiten soll nicht aktiv ist, dann machen wir nix
-- nderung wegen Buglist 7198:
-- nicht nur die Domne fr die der Applikationsserver arbeitet, 
-- sondern auch die Domne in der der ausfhrende Server sich befindet mssen aktiv sein
--if 1 = ( select top 1 isnull(d.IsInActive,0)
--			from d o m a i n  d join ApplicationServer s on d.Ident_Domain = s.Ident_Domain
--			where s.UID_ApplicationServer=@appserver
--		)

/*
 bei domainzerlegung ausgeklammert
select top 1  @IsInvalidDomain =  cast(isnull(d.IsInActive,0) as int)
			from SDLDomain d join ApplicationServer s on d.UID_SDLDomain = s.uid_sdldomain
			where s.UID_ApplicationServer=@appserver

select top 1 @IsInvalidDomain = @IsInvalidDomain + cast(isnull(d.IsInActive,0) as int)
			from applicationserver s join server sr on s.uid_server = sr.uid_server
								join domain d on sr.Ident_Domainserver = d.Ident_Domain
			where s.UID_ApplicationServer=@appserver

if @IsInvalidDomain > 0
	Begin
		-- dann wird der PAS spter mal befllt
		return
	end

*/
  
-- den Parent_AppsServer selektieren
select @server=UID_ParentApplicationServer from applicationserver where UID_ApplicationServer=@appserver

-- alle Applikationen dieses ParentServers selektieren
DECLARE schritt1 CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
select UID_Profile, chgnumber from appservergotappprofile where uid_applicationserver=@server
  
OPEN schritt1
FETCH NEXT from schritt1 INTO @apps, @chg

WHILE (@@fetch_status <> -1)
Begin

  if not exists (select top 1 1 from AppServerGotAppProfile where UID_ApplicationServer= rtrim(@appserver) and UID_Profile = rtrim(@apps))
  begin
  	insert into AppServerGotAppProfile (UID_ApplicationServer, UID_Profile, ChgNumber, ProfileStateProduction,
                                      XDateInserted, XDateUpdated, XUserInserted, XUserUpdated, XObjectKey)
				values (rtrim(@appserver), rtrim(@apps), @chg, 'EMPTY',
					GetUTCDate(), GetUTCDate(), 'sa', 'sa', dbo.QBM_FCVElementToObjectKey2('AppServerGotAppProfile', 'UID_ApplicationServer', rtrim(@appserver), 'UID_Profile', rtrim(@apps)))
	select @where = N'UID_ApplicationServer = ''' + rtrim(@appserver) + N''' and UID_Profile = ''' + rtrim(@apps) + N''' '
	select @BasisObjectKey = dbo.QBM_FCVElementToObjectKey2('AppServerGotAppProfile', 'UID_ApplicationServer', @appserver, 'UID_Profile', @apps)

	exec QBM_PJobCreate_HOFireEvent 'AppServerGotAppProfile', @where , 'Copy2PAS', @GenProcID
							, @ObjectKeysAffected = @AdditionalObjectKeysAffected_CSU
							, @checkForExisting = 1
							, @BasisObjectKey = @BasisObjectKey
  end
  FETCH NEXT from schritt1 INTO @apps, @chg
End

CLOSE schritt1
DEALLOCATE schritt1

-- alle Driver dieses ParentServers selektieren
DECLARE schritt2 CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
select UID_Profile, chgnumber from appservergotdriverprofile where uid_applicationserver=@server
  
OPEN schritt2
FETCH NEXT from schritt2 INTO @drv, @chg

WHILE (@@fetch_status <> -1)
Begin

  if not exists (select top 1 1 from AppServerGotDriverProfile where UID_ApplicationServer= rtrim(@appserver) and UID_Profile = rtrim(@drv))
  begin
  	insert into AppServerGotDriverProfile (UID_ApplicationServer, UID_Profile, ChgNumber, ProfileStateProduction,
                                      XDateInserted, XDateUpdated, XUserInserted, XUserUpdated, XObjectKey)
				values (rtrim(@appserver), rtrim(@drv), @chg, 'EMPTY',
					GetUTCDate(), GetUTCDate(), 'sa', 'sa', dbo.QBM_FCVElementToObjectKey2('AppServerGotDriverProfile', 'UID_ApplicationServer', rtrim(@appserver), 'UID_Profile', rtrim(@drv)))
	select @where = N'UID_ApplicationServer = ''' + rtrim(@appserver) + N''' and UID_Profile = ''' + rtrim(@drv) + N''' '
	select @BasisObjectKey = dbo.QBM_FCVElementToObjectKey2('AppServerGotDriverProfile', 'UID_ApplicationServer', @appserver, 'UID_Profile', @drv)

	exec QBM_PJobCreate_HOFireEvent 'AppServerGotDriverProfile', @where , 'Copy2PAS', @GenProcID
							, @ObjectKeysAffected = @AdditionalObjectKeysAffected_CSU
							, @checkForExisting = 1
							, @BasisObjectKey = @BasisObjectKey
  end
  FETCH NEXT from schritt2 INTO @drv, @chg
End

CLOSE schritt2
DEALLOCATE schritt2

-- alle Mactypes dieses ParentServers selektieren
DECLARE schritt3 CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
select uid_MachineType, chgnumber from appservergotmactypeinfo where uid_applicationserver=@server
  
OPEN schritt3
FETCH NEXT from schritt3 INTO @uid_mactype,  @chg

WHILE (@@fetch_status <> -1)
Begin

  if not exists (select top 1 1 from AppServerGotMacTypeInfo where UID_ApplicationServer= rtrim(@appserver) and UID_MachineType = rtrim(@uid_mactype))
  begin
  	insert into AppServerGotMacTypeInfo (UID_ApplicationServer, UID_MachineType, ChgNumber, ProfileStateProduction,
                                      XDateInserted, XDateUpdated, XUserInserted, XUserUpdated, XObjectKey)
				values (rtrim(@appserver), rtrim(@uid_mactype), (@chg * (-1)), 'EMPTY',       --@chg * (-1) für MakeFullCopy
					GetUTCDate(), GetUTCDate(), 'sa', 'sa', dbo.QBM_FCVElementToObjectKey2('AppServerGotMacTypeInfo', 'UID_ApplicationServer', rtrim(@appserver), 'UID_MachineType', rtrim(@uid_mactype)))
	select @where = N'UID_ApplicationServer = ''' + rtrim(@appserver) + N''' and UID_MachineType = ''' + rtrim(@uid_mactype) + N''' '
	select @BasisObjectKey = dbo.QBM_FCVElementToObjectKey2('AppServerGotMacTypeInfo', 'UID_ApplicationServer', @appserver, 'UID_MachineType', @uid_mactype)

	exec QBM_PJobCreate_HOFireEvent 'AppServerGotMacTypeInfo', @where , 'Copy2PAS', @GenProcID
							, @ObjectKeysAffected = @AdditionalObjectKeysAffected_CSU
							, @checkForExisting = 1
							, @BasisObjectKey = @BasisObjectKey
  end
  FETCH NEXT from schritt3 INTO @uid_mactype,  @chg
End

CLOSE schritt3
DEALLOCATE schritt3


END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'schritt1'
    exec QBM_PCursorDrop 'schritt2'
    exec QBM_PCursorDrop 'schritt3'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	

end

go
