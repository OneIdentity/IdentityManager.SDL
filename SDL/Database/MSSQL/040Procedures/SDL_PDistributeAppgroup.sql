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





---------------------------------------------------------------------------------------------
-- Distribute_Appgroups
---------------------------------------------------------------------------------------------


exec QBM_PProcedureDrop 'SDL_PDistributeAppgroup'
go



---<summary>Adds target system groups as application groups in NT4, AD and LDAP</summary>
---<param name="Groupname" type="nvarchar(32)">Application group name</param>
---<param name="domain" type="nvarchar(32)">Name of domain in which to add the application group</param>
---<param name="descript" type="nvarchar(255)">Optional description for the group</param>
---<remarks>
--- Group name parameter is CN and is usually the application section name
--- The domain parameter is only relevant if the configparm 'Software\Application\Group\CreateEverywhere' is not set
---</remarks>
---<example>
---<code>
--- exec SDL_PDistributeAppgroup 'Office2010', 'Dom1', 'the whole suite'
---</code></example>
---<seealso cref="SDL_FCVADSCommonName" type="Function">Function SDL_FCVADSCommonName</seealso>
---<seealso cref="SDL_FCVADSDistinguishedName" type="Function">Function SDL_FCVADSDistinguishedName</seealso>
---<seealso cref="SDL_FCVDNToCanonical" type="Function">Function SDL_FCVDNToCanonical</seealso>
---<seealso cref="QBM_PCursorDrop" type="Procedure">Procedure QBM_PCursorDrop</seealso>
---<seealso cref="QBM_PGenprocidGetFromContext" type="Procedure">Procedure QBM_PGenprocidGetFromContext</seealso>
---<seealso cref="QBM_FCVElementToObjectKey1" type="Function">Function QBM_FCVElementToObjectKey1</seealso>
---<seealso cref="QBM_FGIConfigparmValue" type="Function">Function QBM_FGIConfigparmValue</seealso>
---<seealso cref="QBM_FGIErrorMessage" type="Function">Function QBM_FGIErrorMessage</seealso>
---<seealso cref="QBM_PRollbackIfAllowed" type="Procedure">Procedure QBM_PRollbackIfAllowed</seealso>

CREATE procedure SDL_PDistributeAppgroup ( @Groupname nvarchar(32), @domain nvarchar(32), @descript nvarchar(255)= N'' ) 

-- with encryption 
as

begin

-- diese Prozedur wird sowohl aus dem DBScheduler als auch aus Jobs gerufen, daher wird Genprocid aus Context genommen
declare @uidC varchar(38)
declare @UID_Domain varchar(38)
declare @displayname nvarchar(255)
--declare @configparm nvarchar(255)
declare @uid varchar(38)
declare @where nvarchar(255)
declare @SAMAccount nvarchar(255)
declare @tmp nvarchar(255)
declare @zaehl int
--declare @canonicalname nvarchar(255)
declare @DistinguishedName nvarchar(1000)
declare @BasisObjectKey varchar(138)

declare @Xdate datetime

declare @GenProcID varchar(38)
declare @AdditionalObjectKeysAffected_CSU QBM_YParameterList -- compiler shut up
BEGIN TRY

 declare @OperationLevel int 
 declare @XUser nvarchar(64)
	exec @OperationLevel = QBM_PGenprocidGetFromContext @GenProcID output, @XUser output , @CodeID = @@ProcID


select @Xdate = getutcDate()

-- sperre setzen wegen 13584
update Sectionname 
	set XTouched = ''
	where Ident_SectionName = @Groupname
begin transaction SDL_PDistributeAppgroup
update Sectionname 
	set XTouched = 'P'
	where Ident_SectionName = @Groupname
-- / sperre setzen wegen 13584




if '1' = dbo.QBM_FGIConfigparmValue('TargetSystem\ADS')
	begin
		-- create appsgroup in all domains? 
		if '1' = dbo.QBM_FGIConfigparmValue('Software\Application\Group\CreateEverywhere')
			begin
				-- distribute group to all application container in all domains
				DECLARE container CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR  
				--	  select uid_adscontainer from adscontainer where isappcontainer=1 and uid_adscontainer not in (select distinct(uid_adscontainer) from adsgroup where cn=@groupname)
					select c1.uid_adscontainer , c1.UID_ADSDomain 
						from adscontainer c1 
						where c1.isappcontainer=1 
						-- nicht auf Container, sondern auf Gruppe vergleichen:
						and not exists (select top 1 1 from adsgroup c2 
											where c2.uid_adscontainer = c1.uid_adsContainer 
											and  c2.cn=dbo.SDL_FCVADSCommonName(@groupname)
										)
				
			end
		else -- if '1' = dbo.QBM_FGIConfigparmValue('Software\Application\Group\CreateEverywhere')
			begin
			
			-- distribute group to all application container in this domain
			
			DECLARE container CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR  
				-- 2007-03-15 not in - Vermeidung
				select c.uid_adscontainer, d.UID_ADSDomain 
					from adscontainer c join ADSDomain d on c.UID_ADSDomain = d.UID_ADSDomain
					where isappcontainer=1 
					and d.Ident_Domain=@domain 
					and not exists (select top 1 1 from adsgroup g
									where g.cn=dbo.SDL_FCVADSCommonName(@groupname)
									and g.uid_adscontainer = c.uid_adscontainer
									)
			
		end -- else if '1' = dbo.QBM_FGIConfigparmValue('Software\Application\Group\CreateEverywhere')
		
		OPEN container
		FETCH NEXT FROM container into  @uidC, @UID_Domain
		WHILE (@@fetch_status <> -1)
			BEGIN
			-- get unique SAMAccountName in domain
			select @tmp = @groupname
			select @zaehl = 0
			while @tmp in (select SAMAccountName 
							from ADSGroup 
							where UID_ADSContainer in (select c.UID_ADSContainer 
														from ADSContainer c
														where UID_ADSDomain = (select UID_ADSDomain 
																				from ADSContainer 
																				where UID_ADSContainer=@uidC )
														)
							)
				BEGIN
					select @zaehl = @zaehl + 1
					select @tmp = @groupname + N'_' + CONVERT(nvarchar(4),@zaehl)
					CONTINUE
				END
				select @SAMAccount = @tmp
				select  @uid = newid()
				
				-- wegen Buglist 4341:
				select @DistinguishedName = N'CN='+@groupname+','+DistinguishedName from adscontainer where uid_adscontainer=@uidC
				insert into ADSGroup (canonicalname, UID_ADSGroup, UID_ADSContainer, cn, DistinguishedName, Description, SAMAccountName, IsGlobal, IsSecurity, IsApplicationGroup,
					-- wegen Bugmeldung AndreaS 2002-11-12
					/*IsExpansionAnyServer, */XObjectKey
									, xuserinserted, XUserupdated, Xdateinserted, xdateupdated
-- 14807
									, Displayname				
									, UID_ADSDomain
									, ObjectClass
									, StructuralObjectClass
									)
 				 select dbo.SDL_FCVDNToCanonical(@DistinguishedName), @uid, 	@uidC, dbo.SDL_FCVADSCommonName(@groupname), dbo.SDL_FCVADSDistinguishedName(@DistinguishedName), @descript, @SAMAccount, 1, 1, 1,
					/*1, */ dbo.QBM_FCVElementToObjectKey1('ADSGroup', 'UID_ADSGroup', @uid)
									, @XUser, @XUser, @Xdate, @Xdate
									, @Groupname
									, @UID_Domain
									, 'GROUP'
									, 'GROUP'

-- Buglist 13584 Vermeidung von doppelten bei Parallelaufruf
				 where Not exists (select top 1 1 
									from ADSGroup with (nolock)
									where UID_ADSContainer = @uidC
										and cn = dbo.SDL_FCVADSCommonName(@groupname)
										and DistinguishedName = dbo.SDL_FCVADSDistinguishedName(@DistinguishedName)
									)
				--	  select @uid, @uidC, @groupname, N'CN= N'+@groupname+', N'+DistinguishedName, @descript, @SAMAccount, 1, 1, 1 from adscontainer where uid_adscontainer=@uidC
				if @@rowcount > 0
				 begin				
					select @where = N'UID_ADSGroup= ''' + @uid + N''''
					select @BasisObjectKey = dbo.QBM_FCVElementToObjectKey1('ADSGROUP', 'UID_ADSGroup', @uid)
					-- keine Behandlung dieser Aktion in der Simulation, da das Insert schon erfolgt ist

					exec QBM_PJobCreate_HOFireEvent 'ADSGROUP', @where , 'INSERT', @GenProcID
							, @ObjectKeysAffected = @AdditionalObjectKeysAffected_CSU
							, @checkForExisting = 1
							, @BasisObjectKey = @BasisObjectKey
				 end -- if @@rowcount > 0
			FETCH NEXT FROM container into  @uidC, @UID_Domain
		end -- 		WHILE (@@fetch_status <> -1)
		close container
		deallocate container
	end --if N'1' = dbo.QBM_FGIConfigparmValue('TargetSystem\ADS')	
	

-- und das ganze auch noch für LDAP
if '1' = dbo.QBM_FGIConfigparmValue('TargetSystem\LDAP')
	begin
		-- create appsgroup in all domains? 
		if '1' = dbo.QBM_FGIConfigparmValue('Software\Application\Group\CreateEverywhere')
			begin
				-- distribute group to all application container in all domains
				DECLARE container CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR  
					select c1.uid_LDAPcontainer , c1.UID_LDPDomain
						from LDAPcontainer c1 
						where c1.isappcontainer=1 
					-- nicht auf Container, sondern auf Gruppe vergleichen:
							and not exists (select top 1 1 from LDAPgroup c2 
												where c2.uid_LDAPcontainer = c1.uid_LDAPContainer 
												and  c2.cn=dbo.SDL_FCVADSCommonName(@groupname)
											)
				
			end
		else -- if '1' = dbo.QBM_FGIConfigparmValue('Software\Application\Group\CreateEverywhere')
			begin
			
			-- distribute group to all application container in this domain
			DECLARE container CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR  
			--2007-03-15 not in -Vermeidung
				select c.uid_LDAPcontainer, d.UID_LDPDomain
					from LDAPcontainer c join LDPDomain d on c.UID_LDPDomain = d.UID_LDPDomain
					where isappcontainer=1 
					and d.Ident_Domain=@domain 
					and not exists (select top 1 1 from LDAPgroup g
										where g.cn=dbo.SDL_FCVADSCommonName(@groupname)
										and g.uid_LDAPcontainer = c.uid_LDAPcontainer
									)
				
			end -- -- if '1' = dbo.QBM_FGIConfigparmValue('Software\Application\Group\CreateEverywhere')
	
		OPEN container
		FETCH NEXT FROM container into  @uidC, @UID_Domain
		WHILE (@@fetch_status <> -1)
			BEGIN
				select  @uid = newid()
				select @DistinguishedName = N'CN='+@groupname+','+DistinguishedName from LDAPcontainer where uid_LDAPcontainer=@uidC
	
				insert into LDAPGroup (UID_LDAPGroup, UID_LDAPContainer, cn, DistinguishedName, Description, IsApplicationGroup,
					ObjectClass, XObjectKey
									, xuserinserted, XUserupdated, Xdateinserted, xdateupdated
-- 14807
									, DisplayName
									, UID_LDPDomain
									)

				 select @uid, 	@uidC, dbo.SDL_FCVADSCommonName(@groupname), dbo.SDL_FCVADSDistinguishedName(@DistinguishedName), @descript, 1,
					'GroupOfNames', dbo.QBM_FCVElementToObjectKey1('LDAPGroup', 'UID_LDAPGroup', @uid)
					, @XUser, @XUser, @Xdate, @Xdate
					, @Groupname
					, @UID_Domain
-- Buglist 13584 Vermeidung von doppelten bei Parallelaufruf
				 where Not exists (select top 1 1 
									from LDAPGroup with (nolock)
									where UID_LDAPContainer = @uidC
									 and cn = dbo.SDL_FCVADSCommonName(@groupname)
									 and DistinguishedName = dbo.SDL_FCVADSDistinguishedName(@DistinguishedName)
									)
				if @@rowcount > 0
				 begin
					select @where = N'UID_LDAPGroup= ''' + @uid + N''''
					select @BasisObjectKey = dbo.QBM_FCVElementToObjectKey1('LDAPGROUP', 'UID_LDAPGroup', @uid)
					-- keine Behandlung dieser Aktion in der Simulation, da das Insert schon erfolgt ist

					exec QBM_PJobCreate_HOFireEvent 'LDAPGROUP', @where , 'INSERT', @GenProcID
							, @ObjectKeysAffected = @AdditionalObjectKeysAffected_CSU
							, @checkForExisting = 1
							, @BasisObjectKey = @BasisObjectKey
				 end -- if @@rowcount > 0
				FETCH NEXT FROM container into  @uidC, @UID_Domain
			end -- WHILE (@@fetch_status <> -1)
		close container
		deallocate container
	
	end -- if N'1' = dbo.QBM_FGIConfigparmValue('TargetSystem\LDAP')

END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'container'
    exec QBM_PCursorDrop 'domain'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	
ende:
-- sperre setzen wegen 13584
commit transaction SDL_PDistributeAppgroup
-- / sperre setzen wegen 13584


end -- proc
go
