#Code to download repository on a Temp location.
function DownloadFilesFromRepo {
Param(
    [string]$Owner,
    [string]$Repository,
    [string]$Path,
    [string]$DestinationPath
    )

    $baseUri = "https://api.github.com/"
    $args = "repos/$Owner/$Repository/contents/$Path"
	#Write-Output "Invoking Web Request on $baseuri$args"
    $wr = Invoke-WebRequest -Uri $($baseuri+$args)
	#Write-Output "Web response"
	#Write-Output "============"
	#Write-Output "$wr"
	#Write-Output "============"
    $objects = $wr.Content | ConvertFrom-Json
    $files = $objects | where {$_.type -eq "file"} | Select -exp download_url
    $directories = $objects | where {$_.type -eq "dir"}
    #Write-Output "objects=$objects"
	#Write-Output "files=$files"
	#Write-Output "directories=$directories"
	#Write-Output "============"
    $directories | ForEach-Object { 
        DownloadFilesFromRepo -Owner $Owner -Repository $Repository -Path $_.path -DestinationPath $($DestinationPath+$_.name)
    }

    
    if (-not (Test-Path $DestinationPath)) {
        # Destination path does not exist, let's create it
        try {
            New-Item -Path $DestinationPath -ItemType Directory -ErrorAction Stop
        } catch {
            throw "Could not create path '$DestinationPath'!"
        }
    }

    foreach ($file in $files) {
        $fileDestination = Join-Path $DestinationPath (Split-Path $file -Leaf)
        try {
            Invoke-WebRequest -Uri $file -OutFile $fileDestination -ErrorAction Stop -Verbose
            "Grabbed '$($file)' to '$fileDestination'"
        } catch {
            "Unable to download '$($file.path)'"
        }
    }

}

 function Start-CLOC
 {
  param([string]
		$Owner,
		[string]
		$Repository,
        [string]
		[ValidatePattern('(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)')]
		$outputemail)
  Write-Output "Owner: $Owner"
  Write-Output "Repository: $Repository"
  Write-Output "Output Email: $outputemail"
  Write-Output "Installing CLOC"
  npm install -g cloc
  $folderPath = "C:\Temp\WorkspaceForCLOC\" 

  Write-Output "Creatung Temp location: $folderPath"
  Write-Output "DownloadFilesFromRepo -Owner $Owner -Repository $Repository -Path "" -DestinationPath $folderPath"
  DownloadFilesFromRepo -Owner "$Owner" -Repository "$Repository" -Path "" -DestinationPath "$folderPath"
  Write-Output "Running CLOC"
  $clocR = cloc "$folderPath"
  Write-Output "CLOC Results!"
  Write-Output $($clocR)
  sendEmail -To "$outputemail" -Body $($clocR)

  Write-Output "Deleting contents of $folderPath"
  Remove-Item -LiteralPath "$folderPath" -Force -Recurse

 }
function sendEmail
{
  param([string]
		$To,
		[string]
		$Body)
	$From = "monte.albert80@gmail.com"
	$Subject = "Here's the CLOC Report for your project"
	$SMTPServer = "smtp.gmail.com"
	$SMTPMessage = New-Object System.Net.Mail.MailMessage($From,$To,$Subject,$Body)
	$SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, 587) 
	$SMTPClient.UseDefaultCredentials = $false;
	$SMTPClient.EnableSsl = $true 
	$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("monte.albert80@gmail.com", ""); 
	$SMTPClient.Send($SMTPMessage)
}
