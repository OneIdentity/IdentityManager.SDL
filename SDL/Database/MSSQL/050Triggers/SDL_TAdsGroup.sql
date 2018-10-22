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
   --  Tabelle AdsGroup  neu 2001-08-28
   --------------------------------------------------------------------------------  

exec QBM_PTriggerDrop 'SDL_TDAdsGroup' 
go





create trigger SDL_TDAdsGroup on AdsGroup  
-- with encryption 
	for Delete 
	not for Replication    
  as
 begin
-- exec QBM_PProcedureNestLevelCheck @@ProcID
declare @UID_ADSOtherSID varchar(38)
		, @ObjectSID  nvarchar(256)
		, @Ident_ADSOtherSID  nvarchar(256)
		, @XDateInserted  datetime
		, @XDateUpdated datetime
		, @XUserInserted  nvarchar(64)
		, @XUserUpdated nvarchar(64)

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
  declare @alt_uid_AdsGroup varchar(38)
  declare @alt_cn nvarchar(64)
  declare @uid_application varchar(38)
  declare @alt_IsApplicationGroup bit
  declare @alt_uid_adscontainer varchar(38)

   --  allgemeine Variablen 

  DECLARE SDL_TDAdsGroupSchritt CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
    -- interessierende Werte selektieren 
	  select rtrim(isnull(deleted.UID_AdsGroup,'')), rtrim(isnull(cn,N'')), isnull(IsApplicationGroup,0), rtrim(isnull(uid_adscontainer,''))
	      from deleted

  
  OPEN SDL_TDAdsGroupSchritt
  FETCH NEXT FROM SDL_TDAdsGroupSchritt into @alt_uid_AdsGroup, @alt_cn, @alt_IsApplicationGroup, @alt_uid_adscontainer

  WHILE (@@fetch_status <> -1)
  BEGIN
           -- wenn es sich um eine Applikationsgruppe handelte, dann ..
          if @alt_IsApplicationGroup = 1
             begin  
	           --  Bestimmen der Applikation, die zu dieser Gruppe gehört 
	           -- keine null-Werte einstellen
			  select @uid_application = null
	          select  top 1  @uid_application = a.UID_Application 
				from application a join SectionName s on a.UID_SectionName = s.UID_SectionName
				where s.Ident_SectionName = @alt_cn             
	
		  -- Jobs für alle betroffenen Accounts einstellen 
		      if @uid_application is not  null
				begin
					exec     QBM_PDBQueueInsert_Single 'SDL-K-AllADSAccountsForApplication',  @uid_application , @alt_uid_adscontainer, @GenProcID
				end

					delete  @DBQueueElements 
	
					insert into @DBQueueElements (object, subobject, genprocid)
					select x.uid, null, @GenProcID
				    from ( select distinct a.uid_person as uid
								from adsaccountinadsgroup aig join adsaccount a on aig.uid_adsaccount = a.uid_adsaccount 
															and aig.XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
								where aig.uid_adsGroup = @alt_uid_AdsGroup
								 and a.uid_person > ' '
						) as x 

					 exec QBM_PDBQueueInsert_Bulk 'ADS-K-PersonHasObject', @DBQueueElements


             end  --if @alt_IsApplicationGroup = 1


       FETCH NEXT FROM SDL_TDAdsGroupSchritt into @alt_uid_AdsGroup, @alt_cn, @alt_IsApplicationGroup, @alt_uid_adscontainer
  END
	close SDL_TDAdsGroupSchritt
	deallocate SDL_TDAdsGroupSchritt



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



exec QBM_PTriggerDrop 'SDL_TIAdsGroup' 
go





create trigger SDL_TIAdsGroup on AdsGroup  
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

  declare @neu_uid_AdsGroup varchar(38)
  declare @uid_application varchar(38)
  declare @neu_IsApplicationGroup bit
  declare @neu_cn nvarchar(64)
  declare @neu_uid_adscontainer varchar(38)


   -- Schrittbetrieb aufmachen  

  DECLARE SDL_TIAdsGroupSchritt CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 

    -- interessierende Werte selektieren 
  select isnull(AdsGroup.IsApplicationGroup,0), rtrim(isnull(AdsGroup.uid_AdsGroup,'')), rtrim(isnull(AdsGroup.cn,N'')), rtrim(isnull(adsgroup.uid_adscontainer,''))
     from AdsGroup, inserted
     where AdsGroup.UID_AdsGroup = inserted.UID_AdsGroup 

  
  OPEN SDL_TIAdsGroupSchritt
  FETCH NEXT FROM SDL_TIAdsGroupSchritt into @neu_IsApplicationGroup , @neu_uid_AdsGroup , @neu_cn, @neu_uid_adscontainer

  WHILE (@@fetch_status <> -1)
  BEGIN
          -- wenn die neue Gruppe eine Applikationsgruppe sein soll ..  

          if @neu_IsApplicationGroup = 1
             begin  

                  -- prüfen der Sektion zu dieser Gruppe 
                  if not exists (select top 1 1 
									from sectionname 
									where Ident_SectionName = @neu_cn
								)
                    begin
-- 11587 User - Relevanz gesetzt
		                raiserror('#LDS#Cannot insert Active Directory group, because SectionName does not exist.|', 18, 1) with nowait
                    end
	          -- prüfen, ob es die Applikation dazu gibt 
                  select @uid_application = null

                    --  Bestimmen der Applikation, die zu dieser Gruppe gehört 
	          select @uid_application = a.UID_Application 
						from application a join SectionName s on a.UID_SectionName = s.UID_SectionName
						where s.Ident_SectionName = @neu_cn             
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
			     exec     QBM_PDBQueueInsert_Single 'SDL-K-AllADSAccountsForApplication',  @uid_application, @neu_uid_adscontainer, @GenProcID
                   end
             end 

       FETCH NEXT FROM SDL_TIAdsGroupSchritt INTO @neu_IsApplicationGroup , @neu_uid_AdsGroup , @neu_cn,  @neu_uid_adscontainer
  END
  close SDL_TIAdsGroupSchritt
  deallocate SDL_TIAdsGroupSchritt


END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'SDL_TIAdsGroupSchritt'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	

  -- Standard-Abschlussbehandlung 
ende:
	return
end
go




exec QBM_PTriggerDrop 'SDL_TUAdsGroup' 
go





create trigger SDL_TUAdsGroup on AdsGroup  
-- with encryption 
	for Update  
	not for Replication    
  as
begin
-- exec QBM_PProcedureNestLevelCheck @@ProcID
declare @UID_ADSOtherSID varchar(38)
		, @ObjectSID  nvarchar(256)
		, @Ident_ADSOtherSID  nvarchar(256)
		, @XDateInserted  datetime
		, @XDateUpdated datetime
		, @XUserInserted  nvarchar(64)
		, @XUserUpdated nvarchar(64)


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

  declare @alt_uid_AdsGroup varchar(38)
  declare @neu_uid_AdsGroup varchar(38)

  declare @uid_application varchar(38)

  declare @neu_cn nvarchar(64)
  declare @alt_cn nvarchar(64)

  declare @neu_IsApplicationGroup bit
  declare @alt_IsApplicationGroup bit

  declare @alt_uid_adscontainer varchar(38)
  declare @neu_uid_adscontainer varchar(38)

declare @errno int



if dbo.QBM_FGIColumnUpdatedThis('ADSGroup', 'IsApplicationGroup', columns_updated()) = 1
	or dbo.QBM_FGIColumnUpdatedThis('ADSGroup', 'cn', columns_updated()) = 1
	or dbo.QBM_FGIColumnUpdatedThis('ADSGroup', 'uid_AdsGroup', columns_updated()) = 1
	or dbo.QBM_FGIColumnUpdatedThis('ADSGroup', 'uid_Adscontainer', columns_updated()) = 1
 begin 
   -- Schrittbetrieb aufmachen  

  DECLARE SDL_TUAdsGroupSchritt CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 

    -- interessierende Werte selektieren 
  select isnull(deleted.IsApplicationGroup,0),  isnull(AdsGroup.IsApplicationGroup,0) , 
             rtrim(isnull(deleted.cn,N'')), rtrim(isnull(AdsGroup.cn,N'')),
             rtrim(isnull(deleted.uid_AdsGroup,'')), rtrim(isnull(AdsGroup.uid_AdsGroup,'')),
             rtrim(isnull(deleted.uid_Adscontainer,'')), rtrim(isnull(AdsGroup.uid_Adscontainer,''))
     from AdsGroup, deleted
     where AdsGroup.UID_AdsGroup = deleted.UID_AdsGroup 

  
  OPEN SDL_TUAdsGroupSchritt
  FETCH NEXT FROM SDL_TUAdsGroupSchritt into @alt_IsApplicationGroup,@neu_IsApplicationGroup,@alt_cn,@neu_cn,
                          @alt_uid_AdsGroup , @neu_uid_AdsGroup , @alt_uid_adscontainer, @neu_uid_adscontainer

  WHILE (@@fetch_status <> -1)
  BEGIN

     -- update des ident verbieten 
     if @alt_cn <> @neu_cn
      begin 
         select @uid_application = null
         -- Bestimmen der Applikation, die zu dieser Gruppe gehört 
	 select top 1 @uid_application = a.uid_application 
			from application a join SectionName s on a.UID_SectionName = s.UID_SectionName
			where s.Ident_SectionName = @neu_cn             
         if not @uid_application is null
           begin
-- 11587 User - Relevanz gesetzt
	               raiserror( '#LDS#Cannot save Acitve Directory Group, because CN has changed.|', 18, 3) with nowait
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
	          select top 1 @uid_application = uid_application 
				from application a join SectionName s on a.UID_SectionName = s.UID_SectionName
				where s.Ident_SectionName = @neu_cn           
                  if @uid_application is null
                   begin
-- 11587 User - Relevanz gesetzt
		                raiserror( '#LDS#Cannot modify Active Directory group, because the associated application does not exist.|', 18, 2) with nowait
                   end

		  -- wenn OK, Jobs für alle betroffenen Accounts einstellen 
		     exec     QBM_PDBQueueInsert_Single 'SDL-K-AllADSAccountsForApplication',  @uid_application, N'%', @GenProcID
              end

           -- zweiter Fall : Gruppe war Applikationsgruppe 
          if @alt_IsApplicationGroup = 1
             begin  
	          -- prüfen, ob es die Applikation dazu gibt 
                  select @uid_application = null
                   -- Bestimmen der Applikation, die zu dieser Gruppe gehört 
	          select top 1 @uid_application = a.UID_Application 
					from application a join SectionName s on a.UID_SectionName = s.UID_SectionName
					where s.Ident_SectionName = @neu_cn      
					       
                  if not @uid_application is null
                   begin
-- 11587 User - Relevanz gesetzt
		                raiserror('#LDS#Cannot save Active Directory group, because there is still an associated application.|', 18, 2) with nowait
                   end  
              end

       end 
           --       if @neu_IsApplicationGroup <> @alt_IsApplicationGroup   



          -- prüfen, ob es die Applikation dazu gibt 
           select @uid_application = null
          -- Bestimmen der Applikation, die zu dieser Gruppe gehört 
          select top 1 @uid_application = a.UID_Application 
          from application  a join SectionName s on a.UID_SectionName = s.UID_SectionName
          where s.Ident_SectionName = @neu_cn             
           if @uid_application is null
            begin
                  -- Fehlerbehandlung rausgenommen, kann ja sein, App wird erst angelegt
             select @errno = 33334 -- nur als fake, um die if-Konstruktion nicht ändern zu müssen
            end
		   else
			begin
				-- wenn OK, Jobs für alle betroffenen Accounts einstellen 
				if @alt_uid_adscontainer = @neu_uid_adscontainer
				begin
					exec     QBM_PDBQueueInsert_Single 'SDL-K-AllADSAccountsForApplication',  @uid_application, @alt_uid_adscontainer,  @GenProcID
					end
						else
				begin
					exec     QBM_PDBQueueInsert_Single 'SDL-K-AllADSAccountsForApplication',  @uid_application, @alt_uid_adscontainer, @GenProcID
					exec     QBM_PDBQueueInsert_Single 'SDL-K-AllADSAccountsForApplication',  @uid_application, @neu_uid_adscontainer, @GenProcID
				end
			end


       end 
             --       if @neu_IsApplicationGroup <> @alt_IsApplicationGroup   



       FETCH NEXT FROM SDL_TUAdsGroupSchritt into @alt_IsApplicationGroup,@neu_IsApplicationGroup,@alt_cn,@neu_cn,
                @alt_uid_AdsGroup , @neu_uid_AdsGroup  , @alt_uid_adscontainer, @neu_uid_adscontainer
  END
  close SDL_TUAdsGroupSchritt
  deallocate SDL_TUAdsGroupSchritt
  
 end -- if dbo.QBM_FGIColumnUpdatedThis('ADSGroup', 'IsApplicationGroup', columns_updated()) = 1




END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'SDL_TUAdsGroupSchritt'
    exec QBM_PCursorDrop 'schritt_update_accproduct_ADSGroup'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	

  -- Standard-Abschlussbehandlung 
ende:
	return

end
go


