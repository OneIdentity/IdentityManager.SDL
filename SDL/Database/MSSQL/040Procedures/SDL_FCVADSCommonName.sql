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




exec QBM_PFunctionDrop 'SDL_FCVADSCommonName'
go


-- Aufrufbeispiel
-- select dbo.SDL_FCVADSCommonName(N'123123')
-- select dbo.SDL_FCVADSCommonName(N'\#123"123<>123a')
-- select dbo.SDL_FCVADSCommonName(N'a')
-- select dbo.SDL_FCVADSCommonName(N'')
-- select dbo.SDL_FCVADSCommonName(N'\\')
-- select dbo.SDL_FCVADSCommonName(',1=2')

---<summary>Examines and masks a CN according to AD rules</summary>
---<param name="inStr" type="nvarchar(1024)">String to examine and convert</param>
---<returns Type="nvarchar(1024)">Converted string</returns>
---<remarks>
---</remarks>
---<example>
---<code>
--- select dbo.SDL_FCVADSCommonName(N'123123')
--- select dbo.SDL_FCVADSCommonName(N'\#123"123123a')
--- select dbo.SDL_FCVADSCommonName(N'a')
--- select dbo.SDL_FCVADSCommonName(N'')
--- select dbo.SDL_FCVADSCommonName(N'\\')
--- select dbo.SDL_FCVADSCommonName(',1=2')
---</code></example>

create function dbo.SDL_FCVADSCommonName (@inStr nvarchar(1024))
		returns nvarchar(1024)
 as
begin
 declare @work nvarchar(1024)
 declare @in nvarchar(1024)
 declare @i int
 declare @z nvarchar(10)


 select @work = ''
 select @i = 1
 select @in = isnull(@instr,N'')
  
 while @i <=len(@in)
  begin
	select @z = substring(@in, @i, 1)
	if charindex(@z, N'<>\/+#;"=,') > 0
	  begin
		select @z = N'\' + @z
	  end
	select @work = @work + @z
	select @i = @i+1
  end


ende:
 return (@work)

end
go
