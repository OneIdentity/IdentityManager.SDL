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
   --  ZusatzProzedur SDL_ZBaseTreeHasObject
   --------------------------------------------------------------------------------  

exec QBM_PProcedureDrop 'SDL_ZBaseTreeHasObject' 
go


---<summary>Fills and corrects the table BaseTreeHasObject</summary>
---<remarks>Employee UIDs are passed in the auxiliary table QBMDBQueueCurrent</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

---<seealso cref="QBM_FGIIsSimulationSDLe" type="Function">Function QBM_FGIIsSimulationSDLe</seealso>
---<seealso cref="QBM_FGIErrorMessage" type="Function">Function QBM_FGIErrorMessage</seealso>
---<seealso cref="QBM_PRollbackIfAllowed" type="Procedure">Procedure QBM_PRollbackIfAllowed</seealso>
/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-BaseTreeHasObject'  -- (730748)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-BaseTreeHasObject'
		, @Operation = 'SDL-K-BaseTreeHasObject'
		, @ProcedureName = 'SDL_ZBaseTreeHasObject'
		, @IsBulkEnabled = 1
		, @CountParameter = 1
		, @MaxInstance = 1000
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate =  null 
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = 'APC-K-BaseTreeHasObject'
		
*/

create procedure SDL_ZBaseTreeHasObject (@SlotNumber int)
-- with encryption 
AS
begin

declare @Sourcedata QBM_YDataForDelta
		, @CountDeltaQantity int 
		, @CountDeltaOrigin int 

declare @DBQueueElements QBM_YDBQueueRaw 

BEGIN TRY

	exec QBM_PSlotResetOnMissingItem  @SlotNumber, 'BaseTree', 'UID_Org'


-- alle bisherigen Zuordnungen der Org merken
insert into @SourceData(
						IsUpcommingContent, XOriginAfter
						, Element, AssignedElement, XOriginBefore
						)

		select 0, 0
			, uid_Org, ObjectKey, InheritInfo
	from BaseTreeHasObject bho join QBMDBQueueCurrent x on uid_Org = x.uid_parameter
												and x.SlotNumber = @SlotNumber
	where bho.ObjectKey like '<Key><T>Driver</T>%'



-------------------------------------------------------------------------------
-- die Zuordnungen ermitteln, die tatsächlich da sein müssen
-------------------------------------------------------------------------------
	insert into @SourceData(
						IsUpcommingContent, XOriginBefore
						, Element, AssignedElement, XOriginAfter
						)

	select 1, 0
			, y.UID_Org, z.XObjectKey, dbo.QER_FCVXOriginToInheritInfo(y.XOrigin)
        from BaseTreeHasDriver y  join QBMDBQueueCurrent x on y.UID_Org= x.uid_parameter
																and x.SlotNumber = @SlotNumber
																and y.XOrigin > 0
								join Driver z on z.uid_Driver = y.uid_Driver





berechnen:

exec QBM_PDBQueueCalculateDelta @SourceData,
								 @DeltaQuantity = 0,
							@DeltaDelete = 1,
							@DeltaInsert = 1,
							@DeltaOrigin = 1, @CountDeltaQantity = @CountDeltaQantity output , @CountDeltaOrigin = @CountDeltaOrigin output
							, @UseIsInEffect = 0
							, @SlotNumber = @SlotNumber 

 exec QER_PBasetreeHasObjectPostProc @CountDeltaOrigin, @CountDeltaQantity

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
	                                	        	

ende:

end
go
