#!/usr/bin/env bash

# rmate
# Copyright (C) 2011-2014 by Harald Lapp <harald@octris.org>
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

#
# Thanks very much to all users and contributors! All bug-reports, 
# feature-requests, patches, etc. are greatly appreciated! :-)
#

# init
# 

# determine hostname
function hostname_command(){
    if command -v hostname >/dev/null 2>&1; then
        echo "hostname"
    else {
        HOSTNAME_DESCRIPTOR="/proc/sys/kernel/hostname"
        if test -r "$HOSTNAME_DESCRIPTOR"; then
            echo "cat $HOSTNAME_DESCRIPTOR"
        else
            echo "hostname"
        fi
        }
    fi
}

hostname=$($(hostname_command))

# default configuration
host=localhost
port=52698

function load_config {
    local rc_file=$1
    local row
    
    local host_pattern="^host(:[[:space:]]+|=)([^ ]+)"
    local port_pattern="^port(:[[:space:]]+|=)([0-9]+)"
    
    if [ -f "$rc_file" ]; then
        while read row; do
            if [[ "$row" =~ $host_pattern ]]; then
                host=${BASH_REMATCH[2]}
            elif [[ "$row" =~ $port_pattern ]]; then
                port=${BASH_REMATCH[2]}
            fi
        done < "$rc_file"
    fi
}

for i in "/etc/${0##*/}" ~/."${0##*/}.rc"; do
    load_config $i
done

host="${RMATE_HOST:-$host}"
port="${RMATE_PORT:-$port}"

if [[ "$host" = "auto" && "$SSH_CONNECTION" != "" ]]; then
    host=${SSH_CONNECTION%% *}
fi

# misc initialization
filepath=""
selection=""
displayname=""
filetype=""
verbose=false
nowait=true
force=false

# process command-line parameters
#
function showusage {
    echo "usage: $0 [-H host-name] [-p port-number] [-w] [-l line-number] [-m display-name] [-t file-type] [-f] [-v] file-path

-H  connect to host (default: $host)
-p  port number to use for connection (default: $port)
-w  wait for file to be closed by TextMate
-l  place caret on line number after loading file
-m  the display name shown in TextMate
-t  treat file as having specified type
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

function dirpath {
  (cd `dirname $1`; pwd -P)
}

function canonicalize {
    filepath="$1"
    dir=`dirpath "$filepath"`
    if [ -L "$filepath" ]; then
        relativepath=`cd "$dir"; readlink \`basename "$filepath"\``
        result=`dirpath "$relativepath"`/`basename "$relativepath"`
    else
        result=`basename "$filepath"`
        if [ "$dir" = '/' ]; then
            result="$dir$result"
        else
            result="$dir/$result"
        fi
    fi
    echo $result
}

while getopts H:p:wl:m:t:fvh OPTIONS; do
    case $OPTIONS in
        H)
            host=$OPTARG;;
        p)
            port=$OPTARG;;
        w) 
            nowait=false;;
        l)
            selection=$OPTARG;;
        m)
            displayname=$OPTARG;;
        t)
            filetype=$OPTARG;;
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

shift $((${OPTIND}-1))
filepath="$1"

if [ "$filepath" = "" ]; then
    showusage
    exit 1
fi

shift
if [ ! "${#@}" -eq 0 ]; then
    echo "There are more than one files specified. Opening only $filepath and ignoring other."
fi

realpath=`canonicalize "$filepath"`
echo $realpath

if [ -f "$realpath" ] && [ ! -w "$realpath" ]; then
    if [[ $force = false ]]; then
        echo "File $filepath is not writable! Use -f to open anyway."
        exit 1
    elif [[ $verbose = true ]]; then
        log "File $filepath is not writable! Opening anyway."
    fi
fi

if [ "$displayname" = "" ]; then
    displayname="$hostname:$filepath"
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
                
                    dd bs=1 count=$value <&3 >>"$tmp" 2>/dev/null
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
echo "display-name: $displayname" 1>&3
echo "real-path: $realpath" 1>&3
echo "data-on-save: yes" 1>&3
echo "re-activate: yes" 1>&3
echo "token: $filepath" 1>&3

if [ "$selection" != "" ]; then
    echo "selection: $selection" 1>&3
fi

if [ "$filetype" != "" ]; then
    echo "file-type: $filetype" 1>&3
fi

if [ -f "$filepath" ]; then
    filesize=`ls -lL "$realpath" | awk '{print $5}'`
    echo "data: $filesize" 1>&3
    cat "$realpath" 1>&3
else
    echo "data: 0" 1>&3
fi

echo 1>&3
echo "." 1>&3

if [[ $nowait = true ]]; then
    exec </dev/null >/dev/null 2>/dev/null
    ( (handle_connection &) &)
else
    handle_connection
fi

