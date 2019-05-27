Exercise 1 and 3 are delivered in pptx and txt files.

Exercise2 is on powershell script.
To run it, you need to:
1.	Make sure powershell scripts can run on your system. I run it by first setting set-executionpolicy remotesigned.
2.  You need to enter credentials for your gmail in line 86 and 93 in the script. Save it.
3.	Make sure to set your gmail to less secure settings by going to https://www.google.com/settings/security/lesssecureapps
4.  Run powershell, and run following commands changing the folder path
	."D:\Dev\PS\Exercise2.ps1"
	Start-CLOC "<Git Owner>" "<Git Repository>" "<send to email address>"
	
	
	Example: Start-CLOC "MonteAlbert80" "Jewelery" "mudabbas@gmail.com"

