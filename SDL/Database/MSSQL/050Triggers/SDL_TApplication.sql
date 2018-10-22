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
   --  Tabelle Application
   --------------------------------------------------------------------------------  


exec QBM_PTriggerDrop 'SDL_TUApplication' 
go





create trigger SDL_TUApplication on Application  
-- with encryption 
for Update  
	not for Replication    
as
begin
-- exec QBM_PProcedureNestLevelCheck @@ProcID

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

  -- spezielle Variablen 

  declare @uid_Application varchar(38)

  declare @alt_Ident_Sectionname nvarchar(64)
  declare @neu_Ident_Sectionname nvarchar(64)




if dbo.QBM_FGIColumnUpdatedThis('Application', 'IsPersonOnly', columns_updated()) = 1
	or dbo.QBM_FGIColumnUpdatedThis('Application', 'IsWorkDeskOnly', columns_updated()) = 1
	or dbo.QBM_FGIColumnUpdatedThis('Application', 'Ident_SectionName', columns_updated()) = 1
 begin
-- Differenzieren: Variante mit 2 Parametern
		delete @DBQueueElements 

		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, x.Subobject, @GenProcID
	    from (    select t.uid_application as uid, N'%' as subobject
			from Application t join deleted d on t.uid_application = d.uid_application
						and (rtrim(isnull(t.Ident_SectionName,N''))<> rtrim(isnull(d.Ident_SectionName,N''))
							or isnull(t.IsWorkDeskOnly,0) <> isnull(d.IsWorkDeskOnly,0)
							or isnull(t.IsPersonOnly,0) <> isnull(d.IsPersonOnly,0)
							)

		) as x 
 
	 exec QBM_PDBQueueInsert_Bulk 	'SDL-K-AllADSAccountsForApplication', @DBQueueElements
	 exec QBM_PDBQueueInsert_Bulk 	'SDL-K-AllLDAPAccountsForApplication', @DBQueueElements


-- Variante mit 1 Parameter
		delete  @DBQueueElements 
	
		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
	    from (    select t.uid_application as uid
			from Application t join deleted d on t.uid_application = d.uid_application
						and (rtrim(isnull(t.Ident_SectionName,N''))<> rtrim(isnull(d.Ident_SectionName,N''))
							or isnull(t.IsWorkDeskOnly,0) <> isnull(d.IsWorkDeskOnly,0)
							or isnull(t.IsPersonOnly,0) <> isnull(d.IsPersonOnly,0)
							)

		) as x 

		exec QBM_PDBQueueInsert_Bulk 'SDL-K-AllMachinesForApplication', @DBQueueElements
									
end


END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'schritt_update_accproduct_Application'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	

ende:
  return
end
go


exec QBM_PTriggerDrop 'SDL_TDApplication' 
go





create trigger SDL_TDApplication on Application  
-- with encryption 
	for DELETE 
	not for Replication    
 as
 begin
-- exec QBM_PProcedureNestLevelCheck @@ProcID
declare @DBQueueElements QBM_YDBQueueRaw 

BEGIN TRY

      if exists (select top 1 1 from deleted) goto start
            return
start:
 
 declare @GenProcID varchar(38)
 declare @OperationLevel int 
 declare @XUser nvarchar(64)
	exec @OperationLevel = QBM_PGenprocidGetFromContext @GenProcID output, @XUser output , @CodeID = @@ProcID

   --  allgemeine Variablen 
  declare  @errno   int
  declare  @errmsg  nvarchar(255)


  exec     QBM_PDBQueueInsert_Single 'SDL-K-SoftwareDependsPhysical', '', '', @GenProcID
  exec     QBM_PDBQueueInsert_Single 'SDL-K-ApplicationMakeSortOrder', '', '', @GenProcID



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
	                                	        	

ende:

  return
end
go

-- wegen 13437 gleich beim Insert Wert berechnen, so daß keine 0 ensteht

exec QBM_PTriggerDrop 'SDL_TIApplication' 
go





create trigger SDL_TIApplication on Application  
-- with encryption 
	for Insert 
	not for Replication    
 as
 begin
-- exec QBM_PProcedureNestLevelCheck @@ProcID

declare @DBQueueElements QBM_YDBQueueRaw 

BEGIN TRY


      if exists (select top 1 1 from inserted) goto start
            return
start:
 
 declare @GenProcID varchar(38)
 declare @OperationLevel int 
 declare @XUser nvarchar(64)
	exec @OperationLevel = QBM_PGenprocidGetFromContext @GenProcID output, @XUser output , @CodeID = @@ProcID

  exec     QBM_PDBQueueInsert_Single 'SDL-K-ApplicationMakeSortOrder', '', '', @GenProcID

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
	                                	        	

ende:

  return
end
go
