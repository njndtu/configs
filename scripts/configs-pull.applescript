-- configs-pull: fetch this repo from GitHub, show what's incoming, pull on confirm.
--
-- Run:      osascript scripts/configs-pull.applescript [--repo <path>]
-- Daily:    ./scripts/configs-pull-schedule.sh  (runs it with --scheduled, which
--           stays silent when there's nothing new or GitHub can't be reached)
--
-- --repo is the clone to pull; it defaults to the repo this script is in.
--
-- Pulls are fast-forward only: if this machine has commits GitHub doesn't, or
-- uncommitted edits to a file the pull touches, git refuses and nothing changes.

property repoPath : ""
property dialogTitle : "configs"

on sh(cmd)
	return do shell script "export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin; cd " & quoted form of repoPath & " && " & cmd
end sh

on fail(what, errMsg)
	display dialog what & return & return & errMsg buttons {"OK"} default button 1 with icon stop with title dialogTitle
end fail

on run argv
	set scheduled to false
	set repoPath to ""
	repeat with i from 1 to count of argv
		set arg to item i of argv
		if arg is "--scheduled" then set scheduled to true
		if arg is "--repo" and i < (count of argv) then set repoPath to item (i + 1) of argv
	end repeat
	if repoPath is "" then
		set scriptDir to do shell script "dirname " & quoted form of POSIX path of (path to me)
		set repoPath to do shell script "cd " & quoted form of scriptDir & "/.. && pwd"
	end if

	try
		sh("git fetch --quiet 2>&1")
	on error errMsg
		-- On a schedule, a failed fetch is usually just no network yet after wake.
		if not scheduled then fail("git fetch failed. Nothing was changed.", errMsg)
		return
	end try

	set dirty to sh("git status --porcelain")
	set incoming to (sh("git rev-list --count HEAD..@{u}")) as integer

	if incoming is 0 and scheduled then return
	if incoming is 0 then
		set msg to "Already up to date with GitHub."
		if dirty is not "" then set msg to msg & return & return & "Local changes not committed yet:" & return & dirty
		display dialog msg buttons {"OK"} default button 1 with title dialogTitle
		return
	end if

	set summary to sh("git log --format='- %h %s (%an, %ar)' HEAD..@{u} | head -15") & return & return & sh("git diff --stat HEAD...@{u}")
	if dirty is not "" then set summary to summary & return & return & "Warning - uncommitted local changes:" & return & dirty

	repeat
		set choice to button returned of (display dialog (incoming as text) & " incoming commit(s):" & return & return & summary buttons {"Cancel", "View Diff", "Pull"} default button "Pull" cancel button "Cancel" with title dialogTitle)
		if choice is "View Diff" then
			set f to sh("f=\"${TMPDIR:-/tmp}/configs-incoming.diff\"; git diff HEAD...@{u} > \"$f\"; echo \"$f\"")
			sh("open -a TextEdit " & quoted form of f)
		else
			exit repeat
		end if
	end repeat

	set oldHead to sh("git rev-parse HEAD")
	try
		sh("git pull --ff-only 2>&1")
	on error errMsg
		fail("git pull failed. Nothing was changed.", errMsg)
		return
	end try
	set changed to sh("git diff --name-only " & oldHead & " HEAD")

	set msg to "Pulled " & incoming & " commit(s)." & return & return & changed
	if changed contains "iterm2/" then set msg to msg & return & return & "iTerm2 settings changed: restart iTerm2 to load them."

	if changed contains "obsidian/" and application id "md.obsidian" is running then
		set msg to msg & return & return & "Obsidian settings changed. Restart Obsidian now so it loads them (and doesn't overwrite them from memory)?"
		set choice to button returned of (display dialog msg buttons {"Later", "Restart Obsidian"} default button 2 with title dialogTitle)
		if choice is "Restart Obsidian" then
			tell application id "md.obsidian" to quit
			repeat 40 times
				if application id "md.obsidian" is not running then exit repeat
				delay 0.25
			end repeat
			do shell script "open -b md.obsidian"
		end if
	else
		if changed contains "obsidian/" then set msg to msg & return & return & "Obsidian settings changed. They'll load next time you open it."
		display dialog msg buttons {"OK"} default button 1 with title dialogTitle
	end if
end run
