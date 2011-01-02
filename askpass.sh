#!/bin/bash

ACCT="${SSHVNC_DEST:-none}"
SERVNAME=SSH

[ -n "$SSHVNC_RESET" ] && force="-f"

get_keychain_pass () {
    servname="$1"
    acct="$2"
    /usr/bin/security find-generic-password -s "$servname" -a "$acct" -g 2>&1 >/dev/null | \
        perl -ne '/^password: "(.*)"$/ && print $1; /^password: 0x([0-9a-f]*) /i && print pack "H*",$1'
}

set_keychain_pass () {
    [ "$1" = "-f" ] && { upd="-U"; shift; }
    servname="$1"
    acct="$2"
    /usr/bin/security add-generic-password -s "$SERVNAME" -a "$ACCT" -w "$(cat)" $upd
}

ask_for_pass () {
    osascript <<-EOS
        tell application "System Events"
            activate
            display dialog "Password:" default answer "" with hidden answer
        end tell
        set mypassword to text returned of the result
EOS
}

[ -z "$force" ] && mypass=$(get_keychain_pass "$SERVNAME" "$ACCT")

if [ -z "$mypass" ]; then
    mypass=$(ask_for_pass)
    echo "$mypass" | set_keychain_pass $force "$SERVNAME" "$ACCT"
fi

echo "$mypass"
