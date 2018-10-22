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



exec QBM_PProcedureDrop 'SDL_PDeleteAppProfileFAllChild'
go

-- Verwendung erfolgt ausschließlich innerhalb alter VI-App-Profil Handling, deshalb:
---<istoignore/>

create procedure SDL_PDeleteAppProfileFAllChild @uid_appserver varchar(38), @Profile nvarchar(85)
 -- generiert Löschaufträge für alle untergeordneten AppServer für jobs in AppServerGotAppProfile 
 
-- with encryption 
AS
begin

 declare @GenProcID varchar(38)
declare @BasisObjectKey varchar(138)
declare @AdditionalObjectKeysAffected_CSU QBM_YParameterList -- compiler shut up
BEGIN TRY

 declare @OperationLevel int 
 declare @XUser nvarchar(64)
	exec @OperationLevel = QBM_PGenprocidGetFromContext @GenProcID output, @XUser output , @CodeID = @@ProcID


  DECLARE schrittweise CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR  
    select UID_ApplicationServer from ApplicationServer where UID_ParentApplicationServer=@uid_appserver 
  
  OPEN schrittweise 
  DECLARE @serv varchar(38) 
  DECLARE @txt nvarchar(1024) 
  FETCH NEXT FROM schrittweise into @serv 
  WHILE (@@fetch_status <> -1) 
  BEGIN 
    select @txt = N'UID_ApplicationServer= ''' + @serv + N''' and UID_Profile= ''' + @Profile + N'''' 
    select @BasisObjectKey = dbo.QBM_FCVElementToObjectKey2('AppServerGotAppProfile', 'UID_ApplicationServer', @serv, 'UID_Profile', @Profile)
-- keine Behandlung dieser Aktion in der Simulation	

	exec QBM_PJobCreate_HODelete 'AppServerGotAppProfile', @txt, @GenProcID
				, @ObjectKeysAffected = @AdditionalObjectKeysAffected_CSU
				, @BasisObjectKey = @BasisObjectKey

    FETCH NEXT FROM schrittweise INTO @serv 
  END 
  close schrittweise
  deallocate schrittweise

END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'schrittweise'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	
end

go
