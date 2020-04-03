# Steam-Report-Profil
 Powershell script using API Steam to set info user in a file (collected the people you reported)

The script going to change the alias profil to the source URL profil :

Exemple : Alias profil : https://steamcommunity.com/id/TB7C/

become ==>

source URL profil : https://steamcommunity.com/profiles/76561198080727162

# EXAMPLE
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
                

<a href="https://imgbb.com/"><img src="https://i.ibb.co/p0Sb6vz/Main1.png" alt="Main1" border="0"></a>
<a href="https://imgbb.com/"><img src="https://i.ibb.co/0cNmB8s/Result2.png" alt="Result2" border="0"></a>
<a href="https://ibb.co/6mhrvVX"><img src="https://i.ibb.co/6mhrvVX/Result2.png" alt="Result2" border="0"></a>

* pre-requisites : You might need admin privilidges and set your ExecutionPolicy to "Remotesigned" or "Bypass" on the machine where you are executing

# How It works ?

1. Open the `ProfilReport.ps1` file with a text editor or Windows PowerShell ISE

2. Replace this values to yours

```powershell
        $FileProfilReport = "Path\Reported List.txt"
        # Steam Web API Key
                # Found your Steam Web API Key in this link : https://steamcommunity.com/dev/apikey (you need to be already login  in steamwebsite) 
        $APISteamKey = "Steam Web API Key"
```

3. Open the `Steam Report Profil.bat` file with a text editor and replace the path

```batch
@echo off
Powershell.exe -executionpolicy remotesigned -File  PathOfFile\ProfilReport.ps1
```

4. Run the bat file, put the Steam Profil and click on Add button
                
I working on : 

  ### Future optimization :
      - Found a way to display a PopUp with .bat file / or get a alternative to run script
      - Found a way to run the script and hide or close the cmd console
      - Found a way to replace "break" command (it return me a error when i want to get a PopUp
      - Found a way to detecte the element like steamID and appropriate informations to this SteamID
      
  ### Furture Function :
      - Incremente function : (Get +1 at the Reporte to $Reportcount)
         
                o	if($z -igt 0){ # if steamid already in the file
                        #	Go in file, Found SteamID
                        #	Recognize  $ReportCount Get +1
                        #	$Msg1 = "This Steam ID : $steamid is already reported, Reported count : $ReportCount"
                        #	Write-Host $Msg1
                        Break
      -	WhoisBan function : (Refresh the file to set the actualy info user and give you who is recently banned)
                        o	If WhoisBan button Get click :
                            #	Function WhoisBan
                                •	Go to file
                                •	Get Steamid
                                •	Foreach Steamid and info user
                                    o	Go API 
                                    o	Compare result to the content
                                    o	if $result different  so increment  value $bancount +1
                                    o	If different remplace  replace content with the result
                            #	PopUp  
                                •	If $bancount >= 1  display " $bancount new bans"
                                •	If  null so « No ban »
                            #	Ok button
        - More Info : (dialog box where the description of the profile you have reported)
                        o   If Add bouton get click
                            # Get text of dialog box
                            # Recognize "Description" line
                            # Put description
                            
May be for the future we can use a commun file to get a big data of people we report. (i know we have website like : https://extremereportbot.com/report/ , but we need some function like description, found your old report etc...)

If you can help me or giving some tricks, or if you think i use the wrong language, please let a comment.
