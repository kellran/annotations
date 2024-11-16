<#
.SYNOPSIS
    This script creates a new map annotation based of a setpos from cs2.
.DESCRIPTION
    Takes an input of a setpos and creates a 'spot' and 'position' map annotation
#>
param(
    [Parameter(Mandatory)]
    [string]$name,

    [Parameter(Mandatory)]
    [string]$setpos,

    [Parameter(Mandatory)]
    [string]$mapName,

    [Parameter()]
    [ValidateSet("jump-throw", "throw", "walk-throw", "crouch-throw", "crouch-walk-throw", "step-throw", "run-throw")]
    [string]$movement = "jump-throw",

    [Parameter()]
    [ValidateSet("left-click", "middle-click", "right-click")]
    [string]$distance = "left-click"
)

$RootPath = "$PSScriptRoot/../../"

# Sample position - jumpthrow
# setpos 916.032471 1123.968750 64.906296;setang -57.785061 77.579124 0.000000

# Validate input
if ($setpos -notmatch "^setpos (?<StandingX>-?\d+\.\d+) (?<StandingY>-?\d+\.\d+) (?<StandingZ>-?\d+\.\d+);setang (?<AngleX>-?\d+\.\d+) (?<AngleY>-?\d+\.\d+) (?<AngleZ>-?\d+\.\d+)$") {
    throw "Invalid setpos: $setpos"
}

# Generate variables based of match
$angle = "[ $($Matches['AngleX']) $($Matches['AngleY']) $($Matches['AngleZ']) ]"
$position = "[ $($Matches['StandingX']) $($Matches['StandingY']) $($Matches['StandingZ']) ]"

# Find the map, create it if it doesn't exist
$MapFileInfo = Get-Item -Path "$mapName.txt" -ErrorAction "SilentlyContinue"
if ($null -eq $MapFileInfo) {
    $MapFileInfo = New-Item -Path "$mapName.txt" -ItemType "file"
    $FileHeader = @"
<!-- kv3 encoding:text:version{e21c7f3c-8a33-41c5-9977-a76d3a32aa0d} format:generic:version{7412167c-06e9-4698-aff2-e63eb59037e7} -->
{
  MapName = "$mapName"
  ScreenText =
  {
  }
}
"@
    Set-Content -Path $MapFileInfo -Value $FileHeader
}

$FileContent = Get-Content -Path $MapFileInfo

# Generate the new annotation

# Remove variable to avoid confusion with previous match, in case we do not match.
# No match in the below indicates a file without any annotations.
Remove-Variable matches

# Since the annotation numbers start at 0, the return of 'Count' would be the next annotation number.
$PositionGuid = (New-Guid).Guid
$SpotGuid = (New-Guid).Guid
$AnnotationNumber = ($FileContent -match "MapAnnotationNode\d+").Count
$PositionAnnotation = @"
  MapAnnotationNode$AnnotationNumber
  {
    Enabled = true
    Type = "position"
    Id = "$PositionGuid"
    SubType = "main"
    Position = $position
    Angles = $angle
    VisiblePfx = true
    Color = [ 255, 255, 255 ]
    TextPositionOffset = [ 0.0, 0.0, 60.0 ]
    TextFacePlayer = true
    TextHorizontalAlign = "center"
    RevealOnSuccess = false
    Title =
    {
      Text = "$name"
      FontSize = 125
      FadeInDist = 600.0
      FadeOutDist = 40.0
    }
    Desc =
    {
      Text = ""
      FontSize = 75
      FadeInDist = 300.0
      FadeOutDist = 40.0
    }
  }
"@
$SpotAnnotation = @"
  MapAnnotationNode$($AnnotationNumber + 1)
  {
    Enabled = true
    Type = "spot"
    Id = "$SpotGuid"
    SubType = "main"
    Position = $position
    Angles = $angle
    VisiblePfx = false
    Color = [ 255, 255, 255 ]
    TextPositionOffset = [ 0.0, 0.0, 60.0 ]
    TextFacePlayer = false
    TextHorizontalAlign = "center"
    RevealOnSuccess = false
    Title =
    {
      Text = ""
      FontSize = 125
      FadeInDist = 50.0
      FadeOutDist = -1.0
    }
    Desc =
    {
      Text = ""
      FontSize = 75
      FadeInDist = 50.0
      FadeOutDist = -1.0
    }
  }
"@

# Add the new annotation to the file

# Find the last closing curly bracket
for ($i = $FileContent.Length - 1; $i -ge 0; $i--) {
    if ($FileContent[$i] -eq "}") {
        $lastClosingBraceIndex = $i
        break
    }
}

# Split the content into two parts: before and after the last closing brace
$beforeLastBrace = $fileContent[0..$($lastClosingBraceIndex-1)]

# Insert the new annotation before the last closing brace
$modifiedContent = $beforeLastBrace + $PositionAnnotation + $SpotAnnotation + "}"

# Save the modified content back to the file
Set-Content -Path $MapFileInfo -Value $modifiedContent
