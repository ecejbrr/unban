# unban
Unban ip addresses added to /etc/hosts.deny by denyhosts daemon

This program might be useful when safe ip adresses stick in /etc/hosts.deny, preventing to log into the server

## Usage

unban_denyhosts.sh <ip_address to unban>


## TODO
- Filter by service. Now all services would be removed from /etc/hosts.deny
- Check binaries (awk, sed, diff,...). They are normally install in Linux distros, but just in case.
- Narrow REGEX por IPv4 address to ban. 
