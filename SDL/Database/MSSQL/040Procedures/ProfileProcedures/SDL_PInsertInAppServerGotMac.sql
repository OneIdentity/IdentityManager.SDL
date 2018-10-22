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



exec QBM_PProcedureDrop 'SDL_PInsertInAppServerGotMac'
go


-- Verwendung erfolgt ausschließlich innerhalb alter VI-App-Profil Handling, deshalb:
---<istoignore/>

create procedure SDL_PInsertInAppServerGotMac @uid_appserver varchar(38), @uid_machinetype varchar(38), @chgnumber int, 
--		@isready bit
		  @ProfileStateProduction nvarchar(16),
		  @ProfileStateShadow nvarchar(16)

 
-- with encryption 
AS
begin
  DECLARE @txt nvarchar(1024) 
  
BEGIN TRY

  if not exists (select top 1 1 from AppServerGotMactypeInfo where UID_ApplicationServer= @uid_appserver and uid_MachineType = @uid_machinetype )
  begin
  
	insert into AppServerGotMacTypeInfo (UID_ApplicationServer, UID_MachineType, ChgNumber, 
		ProfileStateProduction,  ProfileStateShadow,
		XDateInserted , XDateUpdated , XUserInserted , XUserUpdated  , XObjectKey)
	values (@uid_appserver, @uid_machinetype, @chgnumber, 
		@ProfileStateProduction,  @ProfileStateShadow,
		GetUTCDate(),  GetUTCDate(),     N'ProfileCopy', N'ProfileCopy', dbo.QBM_FCVElementToObjectKey2('AppServerGotMacTypeInfo', 'UID_ApplicationServer', @uid_appserver, 'UID_MachineType', @uid_machinetype) )
		
	  -- 16.03.2005 ersetzt durch insert damit kein Event generiert wird

  end
  else
  begin
  
		update AppServerGotMacTypeInfo set chgnumber=@chgnumber, 
				ProfileStateProduction = @ProfileStateProduction,  
				ProfileStateShadow = @ProfileStateShadow,
					xdateupdated = GetUTCDate(), XuserUpdated = N'ProfileCopy'
					where UID_ApplicationServer= @uid_appserver and UID_MachineType = @uid_machinetype 
					
	--  16.03.2005 ersetzt durch update damit kein Event generiert wird

  end

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
      
