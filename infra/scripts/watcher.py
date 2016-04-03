#!/usr/bin/python
#
#
import sys
import json
import socket

indata = sys.stdin.readline()
hostname = socket.gethostname()
event = json.loads(indata)

print "got event"
print event
check = None
for node in event:
    if node['Node'] == hostname and node["Status"] == "warning":
        #The event is for the mysql service check on this server
        check = node
        print "Service is in warning, releasing locks (this should stop the services for security reasons)"
        open('/tmp/UNLOCK_MASTER', 'a').close()
