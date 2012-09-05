# rmate

## Description

TextMate 2 adds a nice feature, where it is possible to edit files on a remote server
using a helper script. The original helper script provided with TM2 is implemented in
ruby. Here is my attempt to replace this ruby script with a shell script, because in 
some cases a ruby installation might just be to much overhead for just editing remote
files.

The shell script needs to be copied to the server, you want to remote edit files, on.
After that, open your TM2 preferences and enable "Allow rmate connections" setting in
the "Terminal" settings and adjust the setting "Access for" according to your needs:

### Local clients

It's a good idea to allow access only for local clients. In this case you need to open
a SSH connection to the system you want to edit a file on and specify a remote tunnel in
addition:

	ssh -R 52698:localhost:52698 user@example.com

If you are logged in on the remote system, you can now just execute

	rmate test.txt
	

### Remote clients

On some machines, where port forwarding is not possible, for example due to a missing ssh
daemon, you can allow access for "remote clients". Just ssh or telnet to the remote machine
and execute:

    rmate -H textmate-host test.txt

### Example

Example session: Editing html file located on an SGI o2: <https://github.com/aurora/rmate/wiki/Screens>

## Requirements

A bash with compiled support for "/dev/tcp" is required. This is not the case on some 
older linux distributions, like Ubuntu 9.x.

## Usage

    $ ./rmate [-H host-name] [-p port-number] [-w] [-f] [-v] file-path

### Required parameters

rmate.sh takes a file as last argument. This argument is always required.

### Optional parameters

    -H  connect to host (default: localhost)
    -p  port number to use for connection (default: 52698)
    -w  wait for file to be closed by TextMate
    -f  open even if file is not writable
    -v  verbose logging messages
    -h  display this usage information

## Disclaimer

Use with caution. This software may contain serious bugs. I can not be made responsible for
any damage the software may cause to your system or files.

## License

rmate

Copyright (C) 2011 by Harald Lapp <harald@octris.org>

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
