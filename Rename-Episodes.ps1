<#
.SYNOPSIS
Rename-Episodes will rename all TV show episodes in the specified location to Plex naming conventions.
.DESCRIPTION
Rename-Episodes will get all the files in either the current directory or user specified directory, and rename them according to the Plex naming convention; "TV Show - sXXeYY.ext". It will ignore any file that is not of the following video type; mkv, mp4, avi, m2ts, or wmv. The user also has the option to not include a season number if they are using the custom Plex metadata agent HAMA. 
.PARAMETER Path
Path to the directory that the TV show episodes are stored.
.PARAMETER Name
The name of the TV show.
.PARAMETER Season
The season which the episodes are from.
.EXAMPLE 
Renaming TV Show episodes where they are stored in another directory.
Rename-Episodes -Path "D:\TV Shows\Game of Thrones\Season 02" -Name "Game of Thrones" -Season 5
.EXAMPLE 
Renaming TV show episodes where the user in the same directory of the TV show episodes.
Rename-Episodes -Name "Rick and Morty" -Season 2
.EXAMPLE 
Renaming an anime series where the user is using HAMA.
Rename-Episodes -Path "..\Anime\Attack on Titan" -Name "Attack on Titan"
#>

[CmdletBinding()]
param (
	#Path to episodes
    [string]$Path,

    #Name of the show
    [Parameter(Mandatory=$true)]
    [string]$Name,

    #Season number
    [int]$Season
)

#If a file doesn't have one of the following file extentions, it will be ignored.
$videoFormats = ".mkv",".mp4",".avi",".m2ts",".wmv"       

#Grab the videos
if([string]::IsNullOrEmpty($Path)) {
    $episodes = Get-ChildItem
}
else
{
    #Check to make sure path exists
    if(-Not (Test-Path -Path "$Path")) {
        Write-Output "Path given does not exist."
        Exit 1
    }
    else {
        $episodes = Get-ChildItem -Path "$Path"
    }
}

#Make sure the season number is a double digit or if to include it
switch ($Season) {
  { $Season -lt 10 -and $Season -gt 0 } { $SeasonNumber = "0$Season"; break }
  { $Season -gt 10 } { $SeasonNumber = "$Season"; break }
  default { $SeasonNumber = "" }
}

#Keep track of episode count
$episodeCount = 1

ForEach ($episode in $episodes) {
    #Check if the file is a video file
    $exten = [IO.Path]::GetExtension($episode)
	
	#Make sure episode number is a double digit
    if(10 -gt $episodeCount) {
        $epCount = "0$episodeCount"
    }
	else {
		$epCount = $episodeCount
	}
	
	#Rename the file with the proper file name format
    if($videoFormats -contains $exten)
    {  
        if(!$SeasonNumber) {
            Rename-Item -LiteralPath $episode.FullName -NewName "$Name - e$epCount$exten"
        }
        else { 
            Rename-Item -LiteralPath $episode.FullName -NewName "$Name - s$SeasonNumber`e$epCount$exten"
        }

        $episodeCount++
    }        
}

Write-Output $(Get-ChildItem -Path $Path)
