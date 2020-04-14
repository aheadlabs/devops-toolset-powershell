<#
    This script parses the project.xml file and creates environment variables with its content
#>

[CmdletBinding()]
Param(
    # DevOps platform code (see \.devops-platform-specific\README.md)
    [Parameter (Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String] $DevOpsPlatformCode
)

$ProjectFile = "project.xml"

# Find project root and project file
.".\Get-ProjectRoot.ps1"
$ProjectRoot = Get-ProjectRoot -File $ProjectFile

# Add tools
."$ProjectRoot\.tools\Convert-XmlToJson.ps1"

# Add platform specific logic
."$ProjectRoot\code\.devops-platform-specific\Add-EnvironmentVariables-$DevOpsPlatformCode.ps1"

# Read the project file
[XML]$Content = (Get-Content -Path "$ProjectRoot\$ProjectFile" -Raw)

# Convert to JSON key-value pairs
$EnvironmentVariables = (Convert-XmlToJsonKeyValuePairs -XmlDocument $Content) | ConvertFrom-Json

# Generate key-value pairs
CreateEnvironmentVariables $EnvironmentVariables
LogEnvironmentVariables $EnvironmentVariables