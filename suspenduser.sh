#!/bin/bash

# suspenduser --Suspends a user account for the indefinite future.

homedir="/home"          # Home directory for users.
secs=10                  # Seconds before user is logged out.

if [-z $1 ] ; then
    echo "Usage: $0 account" >&2
    exit 1
elif [ "$(id -un)" != "root" ] ; then
    echo "Error. You must be 'root' to run this command." >&2
    exit 1
fi

echo "Please change the password for account $1 to something new."
passwd $1


if who | grep "$1" > /dev/null ; then        # Checks if suspended user is logged in

    for tty in $(who | grep $1 | awk '{print $2}') ; do

        cat << "EOF" > /dev/$tty

****************************************************************************************************
URGENT NOTICE FROM THE SYSTEM ADMINISTRATOR

This account is being suspended, you are going to be logged out
in $secs seconds. Please inmediatly shut down any processes you have running and log out.

****************************************************************************************************
EOF
    done
    
    echo "(Warned $1, now sleeping $secs seconds)"

    sleep $secs

    jobs=$(ps -u $1 | cut -d\ -f1)

    kill -s HUP $jobs                       # Sends kill signal to the user's processes.
    sleep 1                                 # Give it a second.
    kill -s KILL $jobs > /dev/null 2>1      # Kills anything left.

    echo "$1 was logged in. Logged them out. "
fi

chmod 000 $homedir/$1                       # Close off home directory.

echo "Account $1 has been suspended. "

exit 0


