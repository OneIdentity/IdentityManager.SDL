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




--------------------------------------------------------------------------------
--  Tabelle Driver  
--------------------------------------------------------------------------------  


-- Filename SDL_TRMSDriver
--	Module SDL

exec QBM_PTriggerDrop 'SDL_TRMSUDriver' 
go





create trigger SDL_TRMSUDriver on Driver  
-- with encryption 
	for Update  
	not for Replication    
  as
begin
-- exec QBM_PProcedureNestLevelCheck @@ProcID

declare @Parameter nvarchar(256)

declare @DBQueueElements QBM_YDBQueueRaw 

BEGIN TRY


      if exists (select top 1 1 from inserted) goto start
      if exists (select top 1 1 from deleted) goto start
            return
start:
 
 declare @GenProcID varchar(38)
 declare @OperationLevel int 
 declare @XUser nvarchar(64)
	exec @OperationLevel = QBM_PGenprocidGetFromContext @GenProcID output, @XUser output , @CodeID = @@ProcID

---------------------------------------------------------------------------
-- Tests bei Veränderung der ITShopFlags (IsForITShop, IsITShopOnly)
---------------------------------------------------------------------------
if dbo.QBM_FGIColumnUpdatedThis('Driver', 'isForITShop', columns_updated()) = 1
 or dbo.QBM_FGIColumnUpdatedThis('Driver', 'isITShopOnly', columns_updated()) = 1
 begin 


-- test 1/1
	if exists (select top 1 1 from inserted i
				where i.IsForITShop = 1 and i.IsITShopOnly = 1
			)
	begin
-- nur dann machen wir uns die Mühe, weiter zu suchen

-- unzulässig bei EsetHasEntitlement als Entitlement auftretend und die UID_Eset hat Kombination 0 0
-- unzulässig bei EsetHasEntitlement als Entitlement auftretend und die UID_Eset hat Kombination 1 0
		if exists (select top 1 1 
					from inserted i join ESetHasEntitlement ehe on i.XObjectKey = ehe.Entitlement
															and ehe.XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
									join ESet e on ehe.uid_ESet = e.uid_Eset
	--											and (e.IsForITShop = 1	or e.IsForITShop = 0) 
												and e.IsITShopOnly = 0
					 where i.IsForITShop = 1
					  and i.IsITShopOnly = 1
					)
			begin
-- 11587 User - Relevanz gesetzt
				raiserror( '#LDS#Changes cannot take place, because assignments to system roles still exist that may not be used exclusively in IT Shop.|', 18, 2) with nowait
			end

	end -- if exists (select top 1 1 from inserted  where i.IsForITShop = 1 and i.IsITShopOnly = 1

 end -- if dbo.QBM_FGIColumnUpdatedThis('Driver', 'isForITShop', columns_updated()) = 1
---------------------------------------------------------------------------
-- / Tests bei Veränderung der ITShopFlags (IsForITShop, IsITShopOnly)
---------------------------------------------------------------------------

END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	

  -- Standard-Abschlussbehandlung 
ende:
	return

end
go


