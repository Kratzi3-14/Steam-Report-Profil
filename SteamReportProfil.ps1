<#
.Synopsis
   cript pour obtenir URL Steam et le stock
.DESCRIPTION
   Change a alias profil to the source URL profil and save in file with important information user.
   Version : 1.2
   Created by Kratzi 
   Email: none
   Web: none
.EXAMPLE
   Get-steamid 
#>
<#
  All in SteamReported :
         - Banned : (if is ban)
                - Reported Name
                - Actualy Name
                - URL : http://steamcommunity.com/profiles/$result
                - Ban time : 
                - Report Date : 
         - Waiting Ban : (if is not ban)
                - Reported Name
                - Actualy Name
                - URL : http://steamcommunity.com/profiles/$result
                - Report Date :
#>



Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing


function Get-steamID {


[CmdletBinding()]
    Param
    (
        # Enter the URL of the profil you want to get information about
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateNotNullorEmpty()]
        [string]$url
    )
 
    Process
    {
        # Fichier dans lequel sera répertorier toute les URL signalé
        $FileProfilReport = "Path\Reported List.txt"
        # Clé API Steam permettant d'avoir accès au information
        $APISteamKey = "Your API Steam KEY" #Found your API Key in this link : https://steamcommunity.com/dev/apikey (you need to be already login  in steamwebsite)
        # Remplace 
        $searchURL = $url.Replace(' ','%20')
        # Récupère le code source de la page
        $page = Invoke-WebRequest -UseBasicParsing  $searchURL

        # Partern de recherche
        $pattern_steamdid = '","steamid":"(.*?)","personaname":"'
        $pattern_lvlprofil = '"><span class="friendPlayerLevelNum">(.*?)</span>'
        

        # Récupération des informations sur la page
        $steamid = [regex]::match($page, $pattern_steamdid).Groups[1].Value
        $lvlprofil = [regex]::match($page, $pattern_lvlprofil).Groups[1].Value

        # Condition si la récupération ne conclu pas
        if(!($steamid)){
            
            $urlwrong = "Url invalide"
            Write-Warning $urlwrong
            break
        }
        if(!($lvlprofil)){
            
            $lvlprofil = $nolvlprofil = "L'utilisateur ne possède pas de LvL profil"
        }

        
        # Compte combien de fois le SteamID est présent sur le fichier (pour éviter les doublons)
        $z= (Get-Content -path $FileProfilReport | Where-Object { $_.Contains($steamid) }).Count


        # Condition si le steamid est déjà présent au moins une fois
        if($z -igt 0){

        #$ReportCount +1

        $Msg1 = "This Steam ID : $steamid is already reported"

        Write-Host $Msg1
        
        break
        
        }

        # Condition si le steamid n'est pas présent
        if($z -eq 0){


        $ReportCount = 1

        $DateReport = (get-date).ToString('d-M-y hh:mm')
        
        # Mise en place du steam id sur l'URL pour posséder l'URL d'origine
        $SourceURL = "https://steamcommunity.com/profiles/$steamid"
        
        # Utilisation des API pour récupérer les données web
        $InfoPlayer = (Invoke-RestMethod -Method Get -URI ("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=$APISteamKey&steamids="+$steamid)).response.players | Select-Object steamid,personaname
        $BanPlayer = (Invoke-RestMethod -Method Get -URI ("https://api.steampowered.com/ISteamUser/GetPlayerBans/v1/?key=$APISteamKey&steamids="+$steamid)).players | Select-Object communitybanned,vacbanned,numberofvacbans,dayssincelastban,numberofgamebans,economyban

        # Sortie en texte sur le fichier
        add-Content -path $FileProfilReport -value ""
        add-Content -path $FileProfilReport -value ('-'*70)
        add-Content -path $FileProfilReport -value "Date Report : $DateReport`nProfil : $SourceURL`nLevel : $lvlprofil`nNombre de Report : $ReportCount"
        (($BanPlayer,$InfoPlayer) | Out-String) | Out-File -FilePath $FileProfilReport -Append

        Write-Host "This Steam ID : $steamid is added in the file"


        }
    }
}

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '400,400'
$Form.text                       = "Steam Report Profil"
$Form.TopMost                    = $True

$URL                             = New-Object system.Windows.Forms.TextBox
$URL.multiline                   = $false
$URL.width                       = 358
$URL.height                      = 20
$URL.location                    = New-Object System.Drawing.Point(20,34)
$URL.Font                        = 'Microsoft Sans Serif,10'

$AddButtom                             = New-Object system.Windows.Forms.Button
$AddButtom.text                        = "Add"
$AddButtom.width                       = 85
$AddButtom.height                      = 30
$AddButtom.Anchor                      = 'bottom,left'
$AddButtom.location                    = New-Object System.Drawing.Point(20,350)
$AddButtom.Font                        = 'Microsoft Sans Serif,10'



$WhoisBan                      = New-Object system.Windows.Forms.Button
$WhoisBan.text                 = "Whois Ban"
$WhoisBan.width                = 85
$WhoisBan.height               = 30
$WhoisBan.location             = New-Object System.Drawing.Point(160,350)
$WhoisBan.Font                 = 'Microsoft Sans Serif,10'



$Cancel                          = New-Object system.Windows.Forms.Button
$Cancel.text                     = "Cancel"
$Cancel.width                    = 85
$Cancel.height                   = 30
$Cancel.Anchor                   = 'right,bottom'
$Cancel.location                 = New-Object System.Drawing.Point(292,350)
$Cancel.Font                     = 'Microsoft Sans Serif,10'
$Cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel


$SteamURL                        = New-Object system.Windows.Forms.Label
$SteamURL.text                   = "Enter the Steam adresse Profil :"
$SteamURL.AutoSize               = $true
$SteamURL.width                  = 25
$SteamURL.height                 = 10
$SteamURL.location               = New-Object System.Drawing.Point(20,15)
$SteamURL.Font                   = 'Microsoft Sans Serif,10'


# Future box More Info, need to get info and drop in file text witch function

$infobox                         = New-Object system.Windows.Forms.Label
$infobox.text                    = "More info : "
$infobox.AutoSize                = $true
$infobox.width                   = 25
$infobox.height                  = 10
$infobox.location                = New-Object System.Drawing.Point(20,65)
$infobox.Font                    = 'Microsoft Sans Serif,10'

$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $false
$TextBox1.width                  = 357
$TextBox1.height                 = 20
$TextBox1.location               = New-Object System.Drawing.Point(20,85)
$TextBox1.Font                   = 'Microsoft Sans Serif,160'

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '400,400'
$Form.text                       = "Form"
$Form.TopMost                    = $false

$CpyRgt                          = New-Object system.Windows.Forms.Label
$CpyRgt.text                     = "Copyright ©  2020 Kratzi"
$CpyRgt.AutoSize                 = $true
$CpyRgt.width                    = 25
$CpyRgt.height                   = 10
$CpyRgt.location                 = New-Object System.Drawing.Point(282,384)
$CpyRgt.Font                     = 'Microsoft Sans Serif,7'



$Form.controls.AddRange(@($URL,$AddButtom,$Cancel,$SteamURL,$CpyRgt,$infobox,$TextBox1,$WhoisBan))
$form.AcceptButton = $AddButtom

$AddButtom.add_Click({


if ((Get-steamID $URL.Text) -eq $null) {
$ButtonType = [System.Windows.MessageBoxButton]::Ok
$MessageBody = "$Steamid added"
$MessageTitle = "Added Reported Profil"
$MessageIcon = [System.Windows.MessageBoxImage]::Warning
[System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
}
else{
$ButtonType = [System.Windows.MessageBoxButton]::Ok
$MessageBody = "$Steamid added"
$MessageTitle = "Added Reported Profil"
$MessageIcon = [System.Windows.MessageBoxImage]::Information
[System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
}})


$Form.ShowDialog()
