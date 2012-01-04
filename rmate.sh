#!/usr/bin/env bash

# rmate.sh
# Copyright (C) 2011 by Harald Lapp <harald@octris.org>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#
# This script can be found at:
# https://github.com/aurora/rmate
#

#
# This script is a pure bash compatible shell script implementing remote
# textmate functionality
#

# init
# 
hostname=`hostname`
filepath=""

host="${RMATE_HOST:-localhost}"
port="${RMATE_PORT:-52698}"
verbose=false
nowait=true
force=false

# process command-line parameters
#
function showusage {
    echo "usage: $0 [-H host-name] [-p port-number] [-w] [-f] [-v] file-path

-H  connect to host (default: $host)
-p  port number to use for connection (default: $port)
-w  wait for file to be closed by TextMate
-f  open even if file is not writable
-v  verbose logging messages
-h  display this usage information
"
}

function log {
    if [[ $verbose = true ]]; then
        echo "$@" 1>&2
    fi
}

while getopts H:p:wfvh OPTIONS; do
    case $OPTIONS in
        H)
            host=$OPTARG;;
        p)
            port=$OPTARG;;
        w) 
            nowait=false;;
        f)
            force=true;;
        v)
            verbose=true;;
        h)
            showusage
            exit 1;;
        ?)
            showusage
            exit 1;;
        *)
            showusage
            exit 1;;
    esac
done

filepath="${@:$OPTIND}"

if [ "$filepath" = "" ]; then
    showusage
    exit 1
fi

realpath="`cd \`dirname $filepath\`; pwd -P`/$filepath"

if [ -f "$filepath" ] && [ ! -w "$filepath" ]; then
    if [[ $force = false ]]; then
        echo "File $filepath is not writable! Use -f to open anyway."
        exit 1
    elif [[ $verbose = true ]]; then
        log "File $filepath is not writable! Opening anyway."
    fi
fi

#------------------------------------------------------------
# main
#------------------------------------------------------------
function handle_connection {
    local cmd
    local name
    local value
    local token
    local tmp
    
    while read 0<&3; do
        REPLY="${REPLY#"${REPLY%%[![:space:]]*}"}"
        REPLY="${REPLY%"${REPLY##*[![:space:]]}"}"

        cmd=$REPLY

        token=""
        tmp=""

        while read 0<&3; do
            REPLY="${REPLY#"${REPLY%%[![:space:]]*}"}"
            REPLY="${REPLY%"${REPLY##*[![:space:]]}"}"

            if [ "$REPLY" = "" ]; then
                break
            fi
            
            name="${REPLY%%:*}"
            value="${REPLY##*:}"
            value="${value#"${value%%[![:space:]]*}"}"      # fix textmate syntax highlighting: "
                        
            case $name in
                "token")
                    token=$value
                    ;;
                "data")
                    if [ "$tmp" = "" ]; then
                        tmp="/tmp/rmate.$RANDOM.$$"
                        touch "$tmp"
                    fi
                
                    dd bs=$value count=1 <&3 >>"$tmp" 2>/dev/null
                    ;;
                *)
                    ;;
            esac
        done

        if [[ "$cmd" = "close" ]]; then
            log "Closing $token"
        elif [[ "$cmd" = "save" ]]; then
            log "Saving $token"

            cat "$tmp" >  "$token"
            rm "$tmp"		
        fi
    done
    
    log "Done"
}

# connect to textmate and send command
#
exec 3<> /dev/tcp/$host/$port

if [ $? -gt 0 ]; then
	echo "Unable to connect to TextMate on $host:$port"
	exit 1
fi

read server_info 0<&3

log $server_info

echo "open" 1>&3
echo "display-name: $hostname:$filepath" 1>&3
echo "real-path: $realpath" 1>&3
echo "data-on-save: yes" 1>&3
echo "re-activate: yes" 1>&3
echo "token: $filepath" 1>&3

if [ -f $filepath ]; then
    filesize=`ls -l $filepath | awk '{print $5}'`
    echo "data: $filesize" 1>&3
    cat $filepath 1>&3
else
    echo "data: 0" 1>&3
fi

echo 1>&3
echo "." 1>&3

if [[ $nowait = true ]]; then
    ( (handle_connection &) &)
else
    handle_connection
fi
