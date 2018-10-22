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



-- es kann optional die domäne noch hinten drangehängt werden und mit nchar(6) getrennt werden
--		das braucht man bei einfachen Fullnames in NDO 

exec QBM_PFunctionDrop 'SDL_FCVDNToCanonical'
go


---<summary>:DE:Bilden eines canonicalName aus einem Distinguishedname</summary>
---<param name="DistinguishedNameIn" type="nvarchar(1000)">Der zu konvertierende DistinguishedName</param>
---<returns Type="nvarchar(1000)">Der konvertierte CanonicalName</returns>
---<remarks>Es kann optional die domain noch angehängt werden und mit nchar(6) getrennt werden
---		Diese Option wird für einfache Fullnames in NDO 
---</remarks>
---<example>
---<code>
--- select left(distinguishedname,100), dbo.SDL_FCVDNToCanonical(distinguishedname) from adsaccount
--- select left(distinguishedname,100), left(dbo.SDL_FCVDNToCanonical(distinguishedname), 100),  canonicalName from adsaccount where dbo.SDL_FCVDNToCanonical(distinguishedname) not like Canonicalname
---</code></example>

create function  dbo.SDL_FCVDNToCanonical(@DistinguishedNameIn nvarchar(1000)) returns nvarchar(1000)  as
 begin

declare @curr_Elem nvarchar(1000) -- momentan verarbeitetes Element aus Tabelle

declare @curr_ElemPlain nvarchar(1000) -- momentan verarbeitetes Element aus Tabelle ohne führendes DC= o.ä.

declare @_pos int
declare @CanonicalName nvarchar(1000) -- das Ergebnis

declare @_dndetails table (sort int identity,
							element nvarchar(1000) collate database_default
							)

declare @posi int
declare @len int
declare @Anteil nvarchar(1000) -- für die Zerlegung in die Tabelle, hängende Leerezichen müssen dranbleiben

declare @_addon nvarchar(1000)

declare @i int -- Durchlaufzähler Tabelle
declare @UpperBound int -- CountItems Elemente in tabelle

declare @DistinguishedName nvarchar(1000)
declare @DomainPart nvarchar(64) -- Domainanteil bei NDO

------
-- um den Streß mit den hängenden Leerzeichen zu vermeiden:
select @DistinguishedName = replace(@DistinguishedNameIn, ' ' , nchar(7))

-- und hier die Sonderlocke für NDO
if patindex(N'%/ou=%', @DistinguishedName) > 0
 or patindex(N'%/o=%', @DistinguishedName) > 0
 or patindex(N'%/c=%', @DistinguishedName) > 0
begin
	-- dann haben wir einen Fullname von NDO an der Backe
	select @DistinguishedName = replace(@DistinguishedName, N'/ou=', ',ou=')
	select @DistinguishedName = replace(@DistinguishedName, N'/o=', ',o=')
	select @DistinguishedName = replace(@DistinguishedName, N'/c=', ',c=')
end


-- nochmal Sonderlocke NDO
if charindex(nchar(6), @DistinguishedName) > 0 -- dann hat jemand die domäne mitgegeben
  begin
	select @DomainPart = substring(@DistinguishedName, charindex(nchar(6), @DistinguishedName) +1, 64)
	select @DistinguishedName = substring(@DistinguishedName, 1, charindex(nchar(6), @DistinguishedName) -1)
  end
else
  begin
	select @DomainPart = N''
  end



select @curr_Elem = N''
select @_pos = 0
          
select @CanonicalName = N''

--          string[] _dndetails = _dn.Split(',');


select @len = len(@DistinguishedName)
select @posi = 1
select @Anteil = N''
while @posi <= @len
 begin
	if substring(@DistinguishedName, @posi, 1) = ','
	 begin
		insert into @_dndetails (element)
				select rtrim(ltrim(@anteil))
		select @anteil = N''
	 end
	else
	 begin
		select @Anteil = @Anteil + substring(@DistinguishedName, @posi, 1)
	 end

	select @posi = @posi+1
 end -- while @posi <= @len

-- wenn sich noch was angesammelt hat
if len(@anteil) > 0
 begin
		insert into @_dndetails (element)
				select rtrim(ltrim(@anteil))
 end





select @_addon = N''

select @UpperBound = max(sort) from @_dndetails

-- nochmal Sonderlocke NDO
if @upperbound = 1 and @Domainpart > ' '
 begin
	select @canonicalName = ltrim(rtrim(@Domainpart)) + N'/' + ltrim(rtrim(@anteil)) 
	goto ende
 end


                        -- von hinten nach vorn
--          for (int i = _dndetails.GetUpperBound(0); i >= 0; i--)
select @i = @UpperBound
while @i >= 1
 begin
          
          select @curr_Elem = element from @_dndetails where sort = @i

--              _pos = curr_Elem.IndexOf("=");
			select @_pos = charindex(N'=', @curr_Elem)
              if (@_pos > 1)
               begin
--                  if (_dndetails[i][_pos - 1] == N'\\') { _pos = 0; }  // Maskiertes Gleichheitszeichen 
				  if substring (@curr_Elem, @_pos-1, 1) = N'\' 
					begin
						select @_pos = 0
					end
               end

			-- Elemnt bereinigen, um Sonderzeichenhack machen zu können
			 if @_pos > 0
			  begin
				select @curr_ElemPlain = rtrim(ltrim(substring(@curr_Elem, @_pos +1, 1000)))
			  end
			 else
			  begin
				select @curr_ElemPlain  = rtrim(ltrim(@curr_Elem))
			  end	

              if (@_pos > 0)
               begin
--                  if (curr_Elem.StartsWith("DC="))
				    if (left(@curr_Elem, 3) = N'DC=')
					 begin
                      -- Domänenanteil 
						select @curr_ElemPlain = upper(@curr_ElemPlain)
--                      _cn = curr_Elem.Substring(_pos + 1).Trim() + (_cn.Length > 0 ? "." + _cn : _cn);
						if len(@CanonicalName) > 0
						 begin
							select @CanonicalName = @curr_ElemPlain + N'.' + @CanonicalName
						 end
						else
						 begin
							select @CanonicalName = @curr_ElemPlain + @CanonicalName
						 end
					  end
                  else -- if (left(@curr_Elem, 3) = N'DC=')
                   begin
--                      _cn += (_cn.Length > 0 ? "/" : "") + _dndetails[i].Substring(_pos + 1).Trim() + @_addon; // Bestandteil hinzufügen incl. evtl. gemerktes Zeug
					 if len(@CanonicalName) > 0
						begin
							select @CanonicalName = @CanonicalName + N'/'
						end
					select @CanonicalName = @CanonicalName + @curr_ElemPlain + @_addon
	 
                      select @_addon = N''
                   end -- else if (left(@curr_Elem, 3) = N'DC=')
               end
              else  --if (_pos > 0)
			   begin
--				{ @_addon = ',' + _dndetails[i].Trim() + @_addon; } // Zeug merken, kommt noch mehr  
					-- jedoch nur wenn überhaupt mehrere Elemente da waren
					if @UpperBound > 1
					 begin
						select  @_addon = ',' + @curr_ElemPlain + @_addon
					 end
					else
					 begin
						select  @_addon = @curr_ElemPlain + @_addon
					 end
				end -- else if (_pos > 0)
  select @i = @i-1
 end --while @i >= 1          }
 

if (len(@_addon) > 0)
 begin
    select @CanonicalName = @CanonicalName + @_addon -- Der Rest vom Gemerkten 
 end
          


-- hier wäre jetzt die Möglichkeit noch Sonderzeichen und Maskierungen zu flöhen 
	select @CanonicalName = replace(@CanonicalName, N'\<', N'<')
	select @CanonicalName = replace(@CanonicalName, N'\>', N'>')
	select @CanonicalName = replace(@CanonicalName, N'\+', N'+')
	select @CanonicalName = replace(@CanonicalName, N'\,', ',')
	select @CanonicalName = replace(@CanonicalName, N'\=', N'=')
	select @CanonicalName = replace(@CanonicalName, N'\#', N'#')
	select @CanonicalName = replace(@CanonicalName, N'\"', N'"')
	select @CanonicalName = replace(@CanonicalName, N'\;', N';')

	select @CanonicalName = replace(@CanonicalName, N'\\', N'\')

ende:

-- / hier wäre jetzt die Möglichkeit noch Sonderzeichen und Maskierungen zu flöhen 
select @CanonicalName = replace (@CanonicalName, nchar(7), ' ')

return (@CanonicalName)

end
go
