<#
    .Synopsis
       Script for put steam profil reported in a file
    .DESCRIPTION
       - Change the alias of URL to source URL profil
       - Get info user
       - Put in a file
    .EXAMPLE
       - Get-steamid https://steamcommunity.com/id/TB7C/

       - Return :
                ----------------------------------------------------------------------
                Report Date : 3-4-20 08:02
                Profil : https://steamcommunity.com/profiles/76561198080727162
                Level : 17
                Your report number : 1


                CommunityBanned  : False
                VACBanned        : False
                NumberOfVACBans  : 0
                DaysSinceLastBan : 0
                NumberOfGameBans : 0
                EconomyBan       : none

                steamid     : 76561198080727162
                personaname : Kratzi ✔

    .LINK
       https://github.com/Kratzi3-14/Steam-Report-Profil
    .NOTES
      Version:        1.0
      Author:         Kratzi
      Creation Date:  04/03/2020 "April 3 2020"
#>
    <#
  # Future project :

      -	Found a way to display the write-host of the function in PopUp with .bat file / or get a alternative to run script
      - Found a way to run the script and hide or close the cmd console
      - Found a way to replace "break" command (it return me a error when i want to get a PopUp
      - Found a way to detecte the element like steamID and appropriate informations to this SteamID
      

  # Furture Function :

      - Incremente function : (Get +1 at the Reporte to $Reportcount)
         

                o	if($z -igt 0){ # if steamid already in the file
                        	Go in file, Found SteamID
                        	Recognize  $ReportCount Get +1
                        	$Msg1 = "This Steam ID : $steamid is already reported, Reported count : $ReportCount"
                        	Write-Host $Msg1
                            
                            break
                                  } 

      -	WhoisBan function : (Refresh the file to set the actualy info user and give you who is recently banned)
                        o	If WhoisBan button Get click :
                            	Function WhoisBan
                                •	Go to file
                                •	Get Steamid
                                •	Foreach Steamid and info user
                                    o	Go API 
                                    o	Compare result to the content
                                    o	if $result different  so increment  value $bancount +1
                                    o	If different remplace  replace content with the result
                            	PopUp  
                                •	If $bancount >= 1  display " $bancount new bans"
                                •	If  null so « No ban »
                            	Ok button
        - More Info : (dialog box where the description of the profile you have reported)
                        o   If Add bouton get click
                             Get text of dialog box
                             Recognize "Description" line
                             Put description

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
        # File to output the info user profil you reported
        $FileProfilReport = "C:\Users\SierraLima\OneDrive\# Perso\# Principal\VIRTUAL\Reported List.txt"
        # API KEY Steam
                # Found your API Key in this link : https://steamcommunity.com/dev/apikey (you need to be already login  in steamwebsite) 
        $APISteamKey = "941840D78A3B400C3198386DAC150823"
        # Replace 
        $searchURL = $url.Replace(' ','%20')
        # Get the source code of the website
        $page = Invoke-WebRequest -UseBasicParsing  $searchURL

        # Search Pattern
        $pattern_steamdid = '","steamid":"(.*?)","personaname":"'
        $pattern_lvlprofil = '"><span class="friendPlayerLevelNum">(.*?)</span>'
        

        # Get info
        $steamid = [regex]::match($page, $pattern_steamdid).Groups[1].Value
        $lvlprofil = [regex]::match($page, $pattern_lvlprofil).Groups[1].Value

        # If you not get info
        if(!($steamid)){
            
            $urlwrong = "WRONG URL"
            Write-Warning $urlwrong
            break
        }
        if(!($lvlprofil)){
            
            $lvlprofil = $nolvlprofil = "The user dont have a profil Level"
        }

        
        # Count the steamid in the file (to make sur you havnt duplicates) 
        $z= (Get-Content -path $FileProfilReport | Where-Object { $_.Contains($steamid) }).Count


        # If the steam id is present
        if($z -igt 0){

        #$ReportCount +1

        $Msg1 = "This Steam ID : $steamid is already reported"

        Write-Host $Msg1
        
        break
        
        }

        # If the steam id is not
        if($z -eq 0){


        $ReportCount = 1

        # Careful date is "Day Month Year"
        $DateReport = (get-date).ToString('d-M-y hh:mm')
        
        # Set up the steamid in this URL for get the real link profile
        $SourceURL = "https://steamcommunity.com/profiles/$steamid"
        
        # Use the API to get info user
        $InfoPlayer = (Invoke-RestMethod -Method Get -URI ("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=$APISteamKey&steamids="+$steamid)).response.players | Select-Object steamid,personaname
        $BanPlayer = (Invoke-RestMethod -Method Get -URI ("https://api.steampowered.com/ISteamUser/GetPlayerBans/v1/?key=$APISteamKey&steamids="+$steamid)).players | Select-Object communitybanned,vacbanned,numberofvacbans,dayssincelastban,numberofgamebans,economyban

        # Output in your file text
        add-Content -path $FileProfilReport -value ""
        add-Content -path $FileProfilReport -value ('-'*70)
        add-Content -path $FileProfilReport -value "Report Date : $DateReport`nProfil : $SourceURL`nLevel : $lvlprofil`nYour report number : $ReportCount"
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

$AddButtom                       = New-Object system.Windows.Forms.Button
$AddButtom.text                  = "Add"
$AddButtom.width                 = 85
$AddButtom.height                = 30
$AddButtom.Anchor                = 'bottom,left'
$AddButtom.location              = New-Object System.Drawing.Point(20,350)
$AddButtom.Font                  = 'Microsoft Sans Serif,10'


<#

$WhoisBan                        = New-Object system.Windows.Forms.Button
$WhoisBan.text                   = "Whois Ban"
$WhoisBan.width                  = 85
$WhoisBan.height                 = 30
$WhoisBan.location               = New-Object System.Drawing.Point(160,350)
$WhoisBan.Font                   = 'Microsoft Sans Serif,10'

#>

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

<#
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
#>


$CpyRgt                          = New-Object system.Windows.Forms.Label
$CpyRgt.text                     = "Copyright ©  2020 Kratzi"
$CpyRgt.AutoSize                 = $true
$CpyRgt.width                    = 25
$CpyRgt.height                   = 10
$CpyRgt.location                 = New-Object System.Drawing.Point(282,384)
$CpyRgt.Font                     = 'Microsoft Sans Serif,7'


# ,$TextBox1,$WhoisBan # The variable ready to put bellow

$Form.controls.AddRange(@($URL,$AddButtom,$Cancel,$SteamURL,$CpyRgt,$infobox))
$form.AcceptButton = $AddButtom

$AddButtom.add_Click({Get-steamID $URL.Text})

<# 

    # PopUp ready to use but 
            - not with .bat
            - when the function use break i get error (not my error)


if (() -eq $null) {
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
})


#>

$Form.ShowDialog()
