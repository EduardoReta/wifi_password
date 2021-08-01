# Autor: Eduardo Reta
# Fecha: 07/26/2021

'''

PASOS PARA EJECUTARLO:
    1. En Powershell (Modo Administrador) ejecuta "Set-ExecutionPolicy RemoteSigned"
    2. Ubicate en la ubicacion del archivo .ps1
    3. Ejecuta el script ".\main.ps1"

'''

$value = Invoke-Command -ScriptBlock { netsh wlan show profiles }

$rawString = $value | Select-String -Pattern 'All User Profile'

$re = New-Object regex("All User Profile     : (.+)\s+All User Profile     : (.+)")

$networkNames = @()

$filteredNames = $re.Match("$rawString") 

if ($filteredNames)
{   
    $counter = 1
    while ($true)
    {
        if ($filteredNames.Groups[$counter].Value){
            $networkNames += $filteredNames.Groups[$counter].Value
            $counter++
        }
        else {
            break
        }       
    }
}

Write-Host "Redes Disponibles" -ForegroundColor Red
$networkNames | ForEach-Object { Write-Host $_ -ForegroundColor Green}
$selectedNetwork = Read-Host "Escoja la red: "

function GetPassword
{
    param
    (
        [
            Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true
            )
        ]
        [String]
        $selectedNetwork
        
    )
    $command = Invoke-Command -ScriptBlock { netsh wlan show profile name=$selectedNetwork key=clear }

    $rawCommandResponse = $command | Select-String -Pattern 'Key Content'

    $regex = New-Object regex("Key Content            : (.+)")

    $filteredPassword = $regex.Match("$rawCommandResponse")

    $networkPassword = $filteredPassword.Groups[1].Value

    return $networkPassword

}

GetPassword $selectedNetwork


