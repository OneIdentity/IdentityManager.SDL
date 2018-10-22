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
--
   --------------------------------------------------------------------------------
   --  Tabelle Hardware
   --------------------------------------------------------------------------------  



exec QBM_PTriggerDrop 'SDL_TIHardware' 
go





create trigger SDL_TIHardware on Hardware  
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

-- wegen IsInactive-Filterung auf UID_MachineType
-- zu überwachen:  Relationid = R/368
	if exists (select top 1 1 from inserted i join Machinetype p on i.UID_Machinetype = p.UID_Machinetype
										and p.isInactive = 1
			)
	 begin
-- 11587 User - Relevanz gesetzt
		      raiserror( '#LDS#Assignment cannot take place, because the machine type is disabled.|', 18, 2) with nowait
		      
	 end


if '1' = dbo.QBM_FGIConfigparmValue('Software\Driver')
  begin
	delete  @DBQueueElements 
	
	insert into @DBQueueElements (object, subobject, genprocid)
	select x.uid, null, @GenProcID
    from (    select inserted.uid_Hardware as uid
			from inserted
		) as x 
		
	exec QBM_PDBQueueInsert_Bulk  'SDL-K-MACHInEHasDriver', @DBQueueElements, null, 1
/* 16140 Optimierung
*/
   end


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




exec QBM_PTriggerDrop 'SDL_TUHardware' 
go





create trigger SDL_TUHardware on Hardware  
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

  declare @alt_uid_WorkDesk varchar(38)
  declare @neu_uid_WorkDesk varchar(38)


  declare @uid_Hardware varchar(38)

  -- 2000-08-30

  declare @alt_isPC bit
  declare @neu_isPC bit

  declare @alt_ident_os nvarchar(32)
  declare @neu_ident_os nvarchar(32)

  declare @alt_UID_MachineType varchar(38)
  declare @neu_UID_MachineType nvarchar(64)

  declare @alt_UID_Hardwaretype varchar(38)
  declare @neu_UID_Hardwaretype varchar(38)


-- wegen IsInactive-Filterung auf UID_MachineType
-- zu überwachen:  Relationid = R/368
 if dbo.QBM_FGIColumnUpdatedThis('Hardware', 'UID_Machinetype', columns_updated()) = 1
  begin
	if exists (select top 1 1 from Hardware i join deleted d on i.uid_Hardware = d.uid_Hardware
													and isnull(i.UID_Machinetype,'') <> isnull(d.UID_Machinetype,'')
										join Machinetype p on i.UID_Machinetype = p.UID_Machinetype
										and p.isInactive = 1
			)
	 begin
-- 11587 User - Relevanz gesetzt
		      raiserror( '#LDS#Assignment cannot take place, because the machine type is disabled.|', 18, 2) with nowait
		      
	 end
  end -- if dbo.QBM_FGIColumnUpdatedThis('Hardware', 'UID_Machinetype', columns_updated()) = 1

   -- Schrittbetrieb aufmachen  

if dbo.QBM_FGIColumnUpdatedThis('Hardware', 'uid_WorkDesk', columns_updated()) = 1
	or dbo.QBM_FGIColumnUpdatedThis('Hardware', 'IsPC', columns_updated()) = 1
	or dbo.QBM_FGIColumnUpdatedThis('Hardware', 'UID_OS', columns_updated()) = 1
	or dbo.QBM_FGIColumnUpdatedThis('Hardware', 'UID_MachineType', columns_updated()) = 1
	or dbo.QBM_FGIColumnUpdatedThis('Hardware', 'UID_HardwareType', columns_updated()) = 1
 begin 
  DECLARE QER_TUHardwareSchritt2 CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 

    -- interessierende Werte selektieren 
  select rtrim(isnull(deleted.uid_WorkDesk,'')),  rtrim(isnull(Hardware.uid_WorkDesk,'')) , rtrim(isnull(Hardware.uid_Hardware,'')),
           deleted.IsPC, Hardware.IsPC, rtrim(isnull(deleted.UID_OS,'')), rtrim(isnull(Hardware.UID_OS,'')), 
           rtrim(isnull(deleted.UID_MachineType,'')), rtrim(isnull(Hardware.UID_MachineType,'')),
           rtrim(isnull(deleted.UID_HardwareType,'')), rtrim(isnull(Hardware.UID_HardwareType,''))

           
     from Hardware, deleted
     where Hardware.UID_Hardware = deleted.UID_Hardware --and Hardware.isPC =1  -- nur wenn er jetzt neu ein PC ist
-- wegen Buglist 7351
--			and isnull(Hardware.v i _ c o n s i s t e n t ,'') <> 'D'
-- IR 2005-03-31 sollte jetzt dadurch geklärt sein, daß die Hardware bei v i _ c o n s i s t e n t  = D komplett enterbt wird

  
  OPEN QER_TUHardwareSchritt2
  FETCH NEXT FROM QER_TUHardwareSchritt2 into @alt_uid_WorkDesk , @neu_uid_WorkDesk ,@uid_Hardware, @alt_ISPC, @neu_IsPC, @alt_ident_os, @neu_ident_os, 
                    @alt_UID_MachineType, @neu_UID_MachineType, 
			 @alt_UID_HardwareType, @neu_UID_HardwareType
  WHILE (@@fetch_status <> -1)
  BEGIN

          -- wenn os-Wechsel und noch direkte Treiber, dann abschmettern 
	  if @alt_ident_os <> @neu_ident_os
	  begin
              if exists (select top 1 1 
							from machinehasdriver 
							where uid_Hardware = @uid_Hardware
							and XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
							)
                begin
-- 11587 User - Relevanz gesetzt
		             raiserror( '#LDS#Cannot change operating system of device, because assignments of drivers already exist.|', 18, 2) with nowait
                end
	  end


	  -- Vergleichsoperationen und Einfgen in DianlogDBQueue 

       FETCH NEXT FROM QER_TUHardwareSchritt2 into @alt_uid_WorkDesk , @neu_uid_WorkDesk ,@uid_Hardware, @alt_ISPC, @neu_IsPC, @alt_ident_os, @neu_ident_os,
	                    @alt_UID_MachineType, @neu_UID_MachineType, 
			 @alt_UID_HardwareType, @neu_UID_HardwareType
  END
  close QER_TUHardwareSchritt2
  deallocate QER_TUHardwareSchritt2
 end --if dbo.QBM_FGIColumnUpdatedThis('Hardware', 'uid_WorkDesk', columns_updated()) = 1
	-- und div. andere

  -- 2000-08-30 neu
   -- Schrittbetrieb aufmachen  

if dbo.QBM_FGIColumnUpdatedThis('Hardware', 'uid_WorkDesk', columns_updated()) = 1
	or dbo.QBM_FGIColumnUpdatedThis('Hardware', 'IsPC', columns_updated()) = 1
	or dbo.QBM_FGIColumnUpdatedThis('Hardware', 'UID_OS', columns_updated()) = 1
	or dbo.QBM_FGIColumnUpdatedThis('Hardware', 'UID_MachineType', columns_updated()) = 1
	or dbo.QBM_FGIColumnUpdatedThis('Hardware', 'UID_HardwareType', columns_updated()) = 1
 begin 
  DECLARE SDL_TUHardwareSchritt2 CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 

    -- interessierende Werte selektieren 
  select rtrim(isnull(deleted.uid_WorkDesk,'')),  rtrim(isnull(Hardware.uid_WorkDesk,'')) , rtrim(isnull(Hardware.uid_Hardware,'')),
           deleted.IsPC, Hardware.IsPC, rtrim(isnull(deleted.UID_OS,'')), rtrim(isnull(Hardware.UID_OS,'')), 
           rtrim(isnull(deleted.UID_MachineType,'')), rtrim(isnull(Hardware.UID_MachineType,'')),
            rtrim(isnull(deleted.UID_HardwareType,'')), rtrim(isnull(Hardware.UID_HardwareType,''))

           
     from Hardware, deleted
     where Hardware.UID_Hardware = deleted.UID_Hardware --and Hardware.isPC =1  -- nur wenn er jetzt neu ein PC ist
-- wegen Buglist 7351
--			and isnull(Hardware.v i _ c o n s i s t e n t ,'') <> 'D'
-- IR 2005-03-31 sollte jetzt dadurch geklärt sein, daß die Hardware bei v i _ c o n s i s t e n t  = D komplett enterbt wird

  
  OPEN SDL_TUHardwareSchritt2
  FETCH NEXT FROM SDL_TUHardwareSchritt2 into @alt_uid_WorkDesk , @neu_uid_WorkDesk ,@uid_Hardware, @alt_ISPC, @neu_IsPC, @alt_ident_os, @neu_ident_os, 
                    @alt_UID_MachineType, @neu_UID_MachineType, 
			 @alt_UID_HardwareType, @neu_UID_HardwareType
  WHILE (@@fetch_status <> -1)
  BEGIN

	  if  @neu_IsPC = 1 and 
              (@alt_uid_WorkDesk <> @neu_uid_WorkDesk 
              or @alt_isPC <> @neu_isPC  
              or @alt_ident_os <> @neu_ident_os  --  and @neu_IsPC = 1   -- kann weg, weil oben schon abgefragt 
              or @alt_UID_MachineType <> @neu_UID_MachineType
-- Buglist 10084
			  or @alt_UID_HardwareType <> @neu_UID_HardwareType
              )
           or @neu_IsPC <> @alt_IsPC
	  begin
	     if '1' = dbo.QBM_FGIConfigparmValue('Software\Driver')
			begin
				exec     QBM_PDBQueueInsert_Single 'SDL-K-MACHInEHasDriver',  @uid_Hardware, '', @GenProcID
			end
			
	  end


       FETCH NEXT FROM SDL_TUHardwareSchritt2 into @alt_uid_WorkDesk , @neu_uid_WorkDesk ,@uid_Hardware, @alt_ISPC, @neu_IsPC, @alt_ident_os, @neu_ident_os,
	                    @alt_UID_MachineType, @neu_UID_MachineType, 
			 @alt_UID_HardwareType, @neu_UID_HardwareType
  END
  close SDL_TUHardwareSchritt2
  deallocate SDL_TUHardwareSchritt2
 end --if dbo.QBM_FGIColumnUpdatedThis('Hardware', 'uid_WorkDesk', columns_updated()) = 1
	-- und div. andere


  -- Standard-Abschlussbehandlung 

END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'SDL_TUHardwareSchritt2'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	
ende:
  return

end
go
