#SmokeAlarm

A small bash script to allow SmokePing to send alerts as webhooks.

Place this script in /etc/smokeping and modify the Alerts config to point to the file:
```
*** Alerts ***
to = |/etc/smokeping/smokealarm.sh
```
