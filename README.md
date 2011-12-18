# rmate.sh

## Description

TextMate 2 adds a nice feature, where it is possible to edit files on a remote server
using a helper script. The original helper script provided with TM2 is implemented in
ruby. Here is my attempt to replace this ruby script with a shell script, because in 
some cases a ruby installation might just be to much overhead for just editing remote
files.

The shell script needs to be copied to the server, you want to remote edit files, first.
After that, just open a SSH connection specifying a remote tunnel in addition:

    ssh -R 52698:localhost:52698 user@example.com

Now you are logged in on the server and a tunnel was opened. You can now just execute

    ./rmate.sh test.txt

To open a new TextMate window and editing the file "test.txt" inside.

## Requirements

A bash with compiled support for "/dev/tcp" is required. This is not the case on some 
older linux distributions, like Ubuntu 9.x.

## Usage

    $ ./rmate.sh [-H host-name] [-p port-number] [-w] [-f] [-v] file-path

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
any Damage the software may cause to your system or files.

## License

rmate.sh

Copyright (C) 2011 by Harald Lapp <harald@octris.org>

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
