set vnc_port to 5900
set dbname to "Secure VNC destinations.dat"
set dbloc to POSIX path of (path to application support from user domain) & dbname

display dialog "Host:" default answer ""
set target_host to the text returned of the result

-- although I think the rest of this is safe against malicious entry, we
-- might as well be sure. can't think of a good reason for a hostname to
-- need to have any other characters in it.
do shell script "echo " & quoted form of target_host & Â
	" | grep -ivq '[^-a-z0-9_.]'"

-- store all the hostnames we've connected to, and the forward-ports we
-- ended up using for them. using the same forward-port each time allows
-- Screen Sharing still to store and remember passwords in the Keychain
-- (they're all keyed by hostname:port, not just hostname).
do shell script "export H=" & quoted form of target_host & Â
	"; DB=" & quoted form of dbloc & Â
	"; touch \"$DB\" && mv \"$DB\" \"${DB}.bak\" && \\
		awk 'BEGIN {high=35011; hname=ENVIRON[\"H\"]}
		     $1==hname {fport=$2}
		     $2>high {high=$2}
		     {print}
		     END {
		         if(!fport) {fport=high+1; print hname,fport}
		         print fport >\"/dev/stderr\"
		     }' \"${DB}.bak\" 2>&1 > \"$DB\" && \\
		rm \"${DB}.bak\""
set forward_port to the result

-- create the forwarding. ssh will try to forward from our port on this
-- machine's localhost interface to the VNC port on the remote host's
-- localhost interface. Note that the shell's stdout and stderr pipes back
-- to the applescript must /both/ be closed before "do shell script" will
-- think the subprocess is done. To be able to report errors, we output them
-- to a tempfile. The child ssh process will exit after 15 seconds if no
-- tunneled connections are made, or if they are made, after all tunneled
-- connections finish.
set reset to ""
repeat 3 times
	try
		set sshout to quoted form of (POSIX path of (path to temporary items) & Â
			"sshout")
		set askpass to POSIX path of (path to resource "askpass.sh")
		do shell script "SSHVNC_DEST=" & quoted form of target_host & Â
			" SSHVNC_RESET=" & quoted form of reset & Â
			" SSH_ASKPASS=" & quoted form of askpass & Â
			" /usr/bin/ssh -L localhost:" & quoted form of forward_port & Â
			":localhost:" & vnc_port & Â
			" -o ExitOnForwardFailure=yes -n -f " & quoted form of target_host & Â
			" 'sleep 15' > /dev/null 2>" & sshout
		exit repeat
	on error errormsg number errornum
		do shell script "cat " & sshout
		set errorout to result
		set isauthfail to offset of Â
			"Too many authentication failures for" in errorout
		if errornum ­ 255 or isauthfail < 1 then
			do shell script "rm -f " & sshout
			display dialog ("SSH failure [" & errornum as text) & "] " & errorout
			error errornum
		end if
	end try
	set reset to "YES"
end repeat

do shell script "rm -f " & sshout
open location "vnc://localhost:" & forward_port & "/"
