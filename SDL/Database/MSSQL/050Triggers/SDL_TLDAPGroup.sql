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
   --  Tabelle LDAPGroup
   --------------------------------------------------------------------------------  

exec QBM_PTriggerDrop 'SDL_TDLDAPGroup' 
go





create trigger SDL_TDLDAPGroup on LDAPGroup  
-- with encryption 
	for Delete 
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

   -- spezielle Variablen 
  declare @alt_uid_LDAPGroup varchar(38)
  declare @alt_cn nvarchar(64)
  declare @uid_application varchar(38)
  declare @alt_IsApplicationGroup bit
  declare @alt_uid_LDAPContainer varchar(38)


   -- Schrittbetrieb aufmachen  

  DECLARE SDL_TDLDAPGroupSchritt CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
    -- interessierende Werte selektieren 
	  select rtrim(isnull(deleted.UID_LDAPGroup,'')), rtrim(isnull(cn,N'')), isnull(IsApplicationGroup,0), rtrim(isnull(uid_LDAPContainer,''))
	      from deleted

  
  OPEN SDL_TDLDAPGroupSchritt
  FETCH NEXT FROM SDL_TDLDAPGroupSchritt into @alt_uid_LDAPGroup, @alt_cn, @alt_IsApplicationGroup, @alt_uid_LDAPContainer

  WHILE (@@fetch_status <> -1)
  BEGIN
           -- wenn es sich um eine Applikationsgruppe handelte, dann ..
          if @alt_IsApplicationGroup = 1
             begin  
	           --  Bestimmen der Applikation, die zu dieser Gruppe gehört 
	           -- keine null-Werte einstellen
			  select @uid_application = null
	          select  top 1  @uid_application = uid_application from application where Ident_SectionName = @alt_cn             
	
		  -- Jobs für alle betroffenen Accounts einstellen 
		      if @uid_application is not  null
				begin
					exec     QBM_PDBQueueInsert_Single 'SDL-K-AllLDAPAccountsForApplication',  @uid_application , @alt_uid_LDAPContainer, @GenProcID
				end


             end 


       FETCH NEXT FROM SDL_TDLDAPGroupSchritt into @alt_uid_LDAPGroup, @alt_cn, @alt_IsApplicationGroup, @alt_uid_LDAPContainer
  END
  close SDL_TDLDAPGroupSchritt
  deallocate SDL_TDLDAPGroupSchritt

  -- Standard-Abschlussbehandlung 


END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'SDL_TDLDAPGroupSchritt'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	
ende:
	return

end
go



exec QBM_PTriggerDrop 'SDL_TILDAPGroup' 
go





create trigger SDL_TILDAPGroup on LDAPGroup  
-- with encryption 
	for Insert 
	not for Replication    
  as
 begin
-- exec QBM_PProcedureNestLevelCheck @@ProcID

declare @DBQueueElements QBM_YDBQueueRaw 
declare @errno int
BEGIN TRY


      if exists (select top 1 1 from inserted) goto start
            return
start:
 
 declare @GenProcID varchar(38)
 declare @OperationLevel int 
 declare @XUser nvarchar(64)
	exec @OperationLevel = QBM_PGenprocidGetFromContext @GenProcID output, @XUser output , @CodeID = @@ProcID

   -- spezielle Variablen 

  declare @neu_uid_LDAPGroup varchar(38)
  declare @uid_application varchar(38)
  declare @neu_IsApplicationGroup bit
  declare @neu_cn nvarchar(64)
  declare @neu_uid_LDAPContainer varchar(38)


   -- Schrittbetrieb aufmachen  
if dbo.QBM_FGIColumnUpdatedThis('LDAPGroup', 'IsApplicationGroup', columns_updated()) = 1
 begin
  DECLARE SDL_TILDAPGroupSchritt CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 

    -- interessierende Werte selektieren 
  select isnull(LDAPGroup.IsApplicationGroup,0), rtrim(isnull(LDAPGroup.uid_LDAPGroup,'')), rtrim(isnull(LDAPGroup.cn,N'')), rtrim(isnull(LDAPGroup.uid_LDAPContainer,''))
     from LDAPGroup, inserted
     where LDAPGroup.UID_LDAPGroup = inserted.UID_LDAPGroup 

  
  OPEN SDL_TILDAPGroupSchritt
  FETCH NEXT FROM SDL_TILDAPGroupSchritt into @neu_IsApplicationGroup , @neu_uid_LDAPGroup , @neu_cn, @neu_uid_LDAPContainer

  WHILE (@@fetch_status <> -1)
  BEGIN
          -- wenn die neue Gruppe eine Applikationsgruppe sein soll ..  

          if @neu_IsApplicationGroup = 1
             begin  

                  -- prüfen der Sektion zu dieser Gruppe 
                  if not exists (select top 1 1 from sectionname where Ident_SectionName = @neu_cn)
                    begin
-- 11587 User - Relevanz gesetzt
		                raiserror( '#LDS#Cannot insert {0}, because SectionName does not exist.|LDAPGroup|', 18, 1) with nowait
                    end
	          -- prüfen, ob es die Applikation dazu gibt 
                  select @uid_application = null

                    --  Bestimmen der Applikation, die zu dieser Gruppe gehört 
	          select @uid_application = uid_application from application where Ident_SectionName = @neu_cn             
                  if @uid_application is null
                   begin
		         -- die fehlerbehandlung erst mal rausgenommen, da die Applikation u.U. noch nicht angelegt
                         -- dann können eigentlich auch noch keine Nutzer drin sein
                         select @errno = 33334 -- nur als fake, um die if-Konstruktion nicht ändern zu müssen
                         -- select @errno  = 33333,
		         -- 
                   end
                  else
	           begin
			  -- Jobs für alle betroffenen Accounts einstellen 
			     exec     QBM_PDBQueueInsert_Single 'SDL-K-AllLDAPAccountsForApplication',  @uid_application, @neu_uid_LDAPContainer, @GenProcID
                   end
             end 

       FETCH NEXT FROM SDL_TILDAPGroupSchritt INTO @neu_IsApplicationGroup , @neu_uid_LDAPGroup , @neu_cn,  @neu_uid_LDAPContainer
  END
  close SDL_TILDAPGroupSchritt
  deallocate SDL_TILDAPGroupSchritt
 end -- if dbo.QBM_FGIColumnUpdatedThis('LDAPGroup', 'IsApplicationGroup', columns_updated()) = 1


END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'SDL_TILDAPGroupSchritt'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	
ende:
	return

end
go




exec QBM_PTriggerDrop 'SDL_TULDAPGroup' 
go





create trigger SDL_TULDAPGroup on LDAPGroup  
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

   -- spezielle Variablen 

  declare @alt_uid_LDAPGroup varchar(38)
  declare @neu_uid_LDAPGroup varchar(38)

  declare @uid_application varchar(38)

  declare @neu_cn nvarchar(64)
  declare @alt_cn nvarchar(64)

  declare @neu_IsApplicationGroup bit
  declare @alt_IsApplicationGroup bit

  declare @alt_uid_LDAPContainer varchar(38)
  declare @neu_uid_LDAPContainer varchar(38)



declare @errno int


   -- Schrittbetrieb aufmachen  

if dbo.QBM_FGIColumnUpdatedThis('LDAPGroup', 'IsApplicationGroup', columns_updated()) = 1
	or dbo.QBM_FGIColumnUpdatedThis('LDAPGroup', 'cn', columns_updated()) = 1
	or dbo.QBM_FGIColumnUpdatedThis('LDAPGroup', 'uid_LDAPContainer', columns_updated()) = 1
 begin
  DECLARE SDL_TULDAPGroupSchritt CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 

    -- interessierende Werte selektieren 
  select isnull(deleted.IsApplicationGroup,0),  isnull(LDAPGroup.IsApplicationGroup,0) , 
             rtrim(isnull(deleted.cn,N'')), rtrim(isnull(LDAPGroup.cn,N'')),
             rtrim(isnull(deleted.uid_LDAPGroup,'')), rtrim(isnull(LDAPGroup.uid_LDAPGroup,'')),
             rtrim(isnull(deleted.uid_LDAPContainer,'')), rtrim(isnull(LDAPGroup.uid_LDAPContainer,''))
     from LDAPGroup, deleted
     where LDAPGroup.UID_LDAPGroup = deleted.UID_LDAPGroup 

  
  OPEN SDL_TULDAPGroupSchritt
  FETCH NEXT FROM SDL_TULDAPGroupSchritt into @alt_IsApplicationGroup,@neu_IsApplicationGroup,@alt_cn,@neu_cn,
                          @alt_uid_LDAPGroup , @neu_uid_LDAPGroup , @alt_uid_LDAPContainer, @neu_uid_LDAPContainer

  WHILE (@@fetch_status <> -1)
  BEGIN

     -- update des ident verbieten 
     if @alt_cn <> @neu_cn
      begin 
         select @uid_application = null
         -- Bestimmen der Applikation, die zu dieser Gruppe gehört 
	 select @uid_application = uid_application from application where Ident_SectionName = @neu_cn             
         if not @uid_application is null
           begin
-- 11587 User - Relevanz gesetzt
	               raiserror( '#LDS#Cannot save LDAPGroup because cn has been changed.|', 18, 1) with nowait
           end
       end


      --  wenn die Kennung als Applikationsgruppe wechselt 
      if @neu_IsApplicationGroup <> @alt_IsApplicationGroup 
       begin
           -- erster Fall : Gruppe soll Applikationsgruppe werden 
      --  wenn die Kennung als Applikationsgruppe wechselt 
      if @neu_IsApplicationGroup <> @alt_IsApplicationGroup 
       begin
           -- erster Fall : Gruppe soll Applikationsgruppe werden 
          if @neu_IsApplicationGroup = 1
             begin  
	          -- prüfen, ob es die Applikation dazu gibt 
                  select @uid_application = null
                   -- Bestimmen der Applikation, die zu dieser Gruppe gehört 
	          select @uid_application = uid_application from application where Ident_SectionName = @neu_cn           
                  if @uid_application is null
                   begin
-- 11587 User - Relevanz gesetzt
		                raiserror( '#LDS#Cannot change LDAPGroup, because the associated application does not exist.|', 18, 1) with nowait
                   end

		  -- wenn OK, Jobs für alle betroffenen Accounts einstellen 
		     exec     QBM_PDBQueueInsert_Single 'SDL-K-AllLDAPAccountsForApplication',  @uid_application, N'%', @GenProcID
              end

           -- zweiter Fall : Gruppe war Applikationsgruppe 
          if @alt_IsApplicationGroup = 1
             begin  
	          -- prüfen, ob es die Applikation dazu gibt 
                  select @uid_application = null
                   -- Bestimmen der Applikation, die zu dieser Gruppe gehört 
	          select @uid_application = uid_application from application where Ident_SectionName = @neu_cn             
                  if not @uid_application is null
                   begin
-- 11587 User - Relevanz gesetzt 
		                raiserror( '#LDS#Cannot save LDAPGroup, because assigned application already exists.|', 18, 1) with nowait
                   end  
              end

       end 
           --       if @neu_IsApplicationGroup <> @alt_IsApplicationGroup   



          -- prüfen, ob es die Applikation dazu gibt 
           select @uid_application = null
          -- Bestimmen der Applikation, die zu dieser Gruppe gehört 
          select @uid_application = uid_application from application where Ident_SectionName = @neu_cn             
           if @uid_application is null
            begin
                  -- Fehlerbehandlung rausgenommen, kann ja sein, App wird erst angelegt
             select @errno = 33334 -- nur als fake, um die if-Konstruktion nicht ändern zu müssen
		         --select @errno  = 33333,
		         --
            end
		   else
			begin
				-- wenn OK, Jobs für alle betroffenen Accounts einstellen 
				if @alt_uid_LDAPContainer = @neu_uid_LDAPContainer
				begin
					exec     QBM_PDBQueueInsert_Single 'SDL-K-AllLDAPAccountsForApplication',  @uid_application, @alt_uid_LDAPContainer,  @GenProcID
					end
						else
				begin
					exec     QBM_PDBQueueInsert_Single 'SDL-K-AllLDAPAccountsForApplication',  @uid_application, @alt_uid_LDAPContainer, @GenProcID
					exec     QBM_PDBQueueInsert_Single 'SDL-K-AllLDAPAccountsForApplication',  @uid_application, @neu_uid_LDAPContainer, @GenProcID
				end
			end


       end 
             --       if @neu_IsApplicationGroup <> @alt_IsApplicationGroup   



       FETCH NEXT FROM SDL_TULDAPGroupSchritt into @alt_IsApplicationGroup,@neu_IsApplicationGroup,@alt_cn,@neu_cn,
                @alt_uid_LDAPGroup , @neu_uid_LDAPGroup  , @alt_uid_LDAPContainer, @neu_uid_LDAPContainer
  END
  close SDL_TULDAPGroupSchritt
  deallocate SDL_TULDAPGroupSchritt
 end --if dbo.QBM_FGIColumnUpdatedThis('LDAPGroup', 'IsApplicationGroup', columns_updated()) = 1
	--	or dbo.QBM_FGIColumnUpdatedThis('LDAPGroup', 'cn', columns_updated()) = 1
	--	or dbo.QBM_FGIColumnUpdatedThis('LDAPGroup', 'uid_LDAPContainer', columns_updated()) = 1


END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'SDL_TULDAPGroupSchritt'
    exec QBM_PCursorDrop 'schritt_update_accproduct_LDAPGroup'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	
ende:
	exec QBM_PCursorDrop 'SDL_TULDAPGroupSchritt'
	return

end
go


