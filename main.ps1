function Show-Menu {
    param (
        [string[]]$Options
    )

    $selectedOption = 0

    while ($true) {
        # Clear the console
        Clear-Host

        # Display the menu options
        for ($i = 0; $i -lt $Options.Count; $i++) {
            if ($i -eq $selectedOption) {
                Write-Host " > $($Options[$i])" -ForegroundColor Green
            } else {
                Write-Host "   $($Options[$i])"
            }
        }

        # Capture key input
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode

        # Process arrow key input
        switch ($key) {
            38 { # Up arrow
                $selectedOption = ($selectedOption - 1) % $Options.Count
                if ($selectedOption -lt 0) {
                    $selectedOption += $Options.Count
                }
            }
            40 { # Down arrow
                $selectedOption = ($selectedOption + 1) % $Options.Count
            }
            13 { # Enter key
                return $Options[$selectedOption]
            }
        }
    }
}


# Define the ASCII art for each letter


# Display the ASCII art in red
# Write-Host $asciiArt -ForegroundColor Red

# Example usage
$options = @("Full", "Lite", "Exit")
$selectedOption = Show-Menu -Options $options

if ($selectedOption -eq "Exit") {
    exit
}

try {
	winget --version
	Write-host "Winget present"
} catch {
	Write-Host "Checking prerequisites and updating winget..."
	
## Test if Microsoft.UI.Xaml.2.7 is present, if not then install
try {
	$package = Get-AppxPackage -Name "Microsoft.UI.Xaml.2.7"
	if ($package) {
		Write-Host "Microsoft.UI.Xaml.2.7 is installed."
	} else {
		Write-Host "Installing Microsoft.UI.Xaml.2.7..."
		Invoke-WebRequest `
			-URI https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.3 `
			-OutFile xaml.zip -UseBasicParsing
		New-Item -ItemType Directory -Path xaml
		Expand-Archive -Path xaml.zip -DestinationPath xaml
		Add-AppxPackage -Path "xaml\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.7.appx"
		Remove-Item xaml.zip
		Remove-Item xaml -Recurse
	}
} catch {
	Write-Host "An error occurred: $($_.Exception.Message)"
}

## Update Microsoft.VCLibs.140.00.UWPDesktop
		Write-Host "Updating Microsoft.VCLibs.140.00.UWPDesktop..."
		Invoke-WebRequest `
			-URI https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx `
			-OutFile UWPDesktop.appx -UseBasicParsing
		Add-AppxPackage UWPDesktop.appx
		Remove-Item UWPDesktop.appx

## Install latest version of Winget
$API_URL = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
$DOWNLOAD_URL = $(Invoke-RestMethod $API_URL).assets.browser_download_url |
	Where-Object {$_.EndsWith(".msixbundle")}
	Invoke-WebRequest -URI $DOWNLOAD_URL -OutFile winget.msixbundle -UseBasicParsing
	Add-AppxPackage winget.msixbundle
	Remove-Item winget.msixbundle
}

Write-Host "Installing $selectedOption"

if ($selectedOption -eq "Lite" -or "Full") {
    winget install -e --id Google.Chrome -h
    winget install -e --id Valve.Steam -h
    winget install -e --id 7zip.7zip -h
    winget install -e --id Microsoft.WindowsTerminal -h
}

if ($selectedOption -eq "Full") {
    winget install -e --id Discord.Discord -h
    winget install -e --id Parsec.Parsec -h
    winget install -e --id OBSProject.OBSStudio -h
    winget install -e --id dotPDNLLC.paintdotnet -h
    winget install -e --id EclipseAdoptium.Temurin.17.JRE -h
    winget install -e --id Microsoft.VCRedist.2015+.x64 -h
}
    