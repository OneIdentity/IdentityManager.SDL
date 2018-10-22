Param(
  [Parameter(Mandatory)]
  [string]$connString,
  
  [Parameter(Mandatory)]
  [string]$statement
)

$ErrorActionPreference = 'Stop'

$conn = New-Object System.Data.SqlClient.SqlConnection
$cmd = $null
try {
    $conn.ConnectionString = $connString
    $conn.Open()

    $cmd = $conn.CreateCommand()
    $cmd.CommandTimeout = 60 * 60
    $cmd.CommandText = $statement
    $cnt = $cmd.ExecuteNonQuery()

    Write-Output "Changed $cnt rows."
}
finally {
    if ($null -ne $cmd){
        $cmd.Dispose()
    }

    $conn.Dispose()
}