#region Web Request / API
#Techniques: web requests, formatting, object exploration
# Step 1: Pulling information from GitHub using their API

#set up URI endpoint
#Browser/UI: https://github.com/PowerShell/PowerShell/releases
$uri = "https://api.github.com/repos/PowerShell/PowerShell/releases"
Invoke-WebRequest $uri

#Explore the object
$x = Invoke-WebRequest $uri
$x.tostring() | select-string download_count

#Not that helpful
#Two approaches
#1
$x | get-member
#2: Object Explorer: Community module from Lee Holmes, contains useful command, show-object
show-object $x
$x=((Invoke-WebRequest $uri).allelements[3].innertext | convertfrom-json)[0].assets
$x | sort download_count -Descending | format-table name,down*
"Total Downloads: $(($x | measure download_count -sum).sum)"

#Invoke web request is great when there isn't an API on the other end.
# Manual parsing of a website
# Rest Method: Converts JSON documents to powershell objects
$r = Invoke-RestMethod $uri
show-object $r
(Invoke-RestMethod $uri)[0].assets | sort -Descending download_count | format-table name,down*

#Two very different approaches, be open to scrapping your approach, taking suggestions to new methods.
# Many ways to accomplish the same task in powershell, some methods work better than others in different scenarios

#We have a few lines that go out and track the download count, now what?

#Functionalize it
#Any time you've solved an issue, and you've hacked around on the command line, pasted it into a script so it's repeatable
#Not done unless it's a function
#Powershell is built around the idea of running commands, functions are a type of command
# Commands that do one very tightly scoped thing, and emit their output to the pipeline, allowing you to connect multiple operations together
# Function is the first step to making it a reusable block of code you can share
#scripts are good, functions are better

function GetRepoDownloads {(Invoke-RestMethod $uri)[0].assets | sort -Descending download_count | format-table name,down*}
GetRepoDownloads

(Invoke-RestMethod https://api.github.com/repos/Powershell/PowerShell-RFC/issues/16/comments?per_page=300).user.login | group | sort -Descending count

function Get-GitIssueComment {
    Param(
        #Param1 help description
        [Parameter()]
        $Owner = "PowerShell",

        [Parameter()]
        $Repo = "PowerShell-RFC",

        [Parameter(Mandatory=1)]
        [Int]
        $Issue
    )
    $uri = "https://api.github.com/repos/$owner/$Repo/issues/$issue/comments?per_page=100"
    Write-Verbose "URI = $uri"
    Invoke-RestMethod $uri | Write-Output
}

#Using output variable allows me to fork the output to the console, as well as capturing in a variable (tee-object is another method)
Get-GitIssueComment -Issue 16 -OutVariable C

#OutVariable
#capture output for each step in a command
    gps -ov a | ? name -like *ss -ov b | group name -ov c
    $a
    $b
    $c

#Functions/command shoudl do the minimum number of things it can
#This function does not get the comments, group them, sort them, format them. That's 4 different things. This JUST gets the comments. Sometimes
#You might want them sorted and grouped, sometimes you might not. YOu might want it in an XML or CSV file.
#Minimum scoping, just get the data, without thinking about what you want to do with it. Get the data, and pipe it to another command.

(Get-GitIssueComment -Issue 16).user.login | group -NoElement | sort count -Descending
(Get-GitIssueComment -Issue 16) | ft @{Name="User";Expression={$_.user.login}},Body -wrap

#Running a long complex multi-part pipeline, end result isn't what you expect, somewhere along the line, something happened that you didn't expect
# Great way to examine each step
# a is what I expected, b was not, now you can back off and try to fix it

