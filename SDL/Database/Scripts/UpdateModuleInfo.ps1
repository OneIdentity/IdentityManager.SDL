Param(
  [Parameter(Mandatory)]
  [string]$connString,
  
  [Parameter(Mandatory)]
  [string]$moduleId,
  
  [Parameter(Mandatory)]
  [string]$moduleXmlPath
)

$ErrorActionPreference = 'Stop'

$moduleXmlPath = Resolve-Path -Path $moduleXmlPath
$doc = New-Object System.Xml.XmlDocument
$doc.Load($moduleXmlPath)
$moduleXml = $doc.DocumentElement.InnerXml

$conn = New-Object System.Data.SqlClient.SqlConnection
$cmd = $null
try {
    $conn.ConnectionString = $connString
    $conn.Open()

    $cmd = $conn.CreateCommand()
    $cmd.CommandTimeout = 60 * 60
    $cmd.CommandText = "Update QBMModuleDef Set ModuleInfoXML = @content where ModuleName = @moduleId"
    $cmd.Parameters.AddWithValue("@content", $moduleXml) > $null
    $cmd.Parameters.AddWithValue("@moduleId", $moduleId) > $null
    $cnt = $cmd.ExecuteNonQuery()

    if ( $cnt -gt 0 ){
        Write-Output "Updated ModuleInfoXml for module $moduleId."
        exit 0
    } else {
        Write-Warning "Entry for module $moduleId was not found -> no update."
        exit 1
    }
}
finally {
    if ($null -ne $cmd){
        $cmd.Dispose()
    }

    $conn.Dispose()
}