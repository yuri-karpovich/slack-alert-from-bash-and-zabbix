# slack-alert-from-bash-and-zabbix
Bash script which allows to send messages to [Slack](https://slack.com/) via [Incoming Webhooks app](https://slack.com/apps/A0F7XDUAZ-incoming-webhooks). 
You can use it to send messages **directly from console** or from **[Zabbix](https://www.zabbix.com/)**.

## Preconditions

1. make sure the script is executable: `chmod +x /path/to/slack.sh`
2. make sure that `curl` is installed in your system: `which curl`

## How to use
```bash
./slack.sh --webhook https://hooks.slack.com/services/XXX/YYYY/ZZZZ --message "Message" --severity 3 --title 'Title' --description 'Some Description' --username 'James Bond'
```    
![MessagePreview1](https://raw.githubusercontent.com/yuri-karpovich/slack-alert-from-bash-and-zabbix/master/images/MessagePreview1.png)

Parameters list:
--webhook (-w)      Web-hook URL
--message (-m)      Message text (optional)
--severity (-s)     Numerical trigger severity. Possible values: 0 - Not classified, 1 - Information, 2 - Warning, 3 - Average, 4 - High, 5 - Disaster (optional)
--title (-t)        Message title (optional)
--description (-d)  Message description (optional)
--username (-u)     Username to be displayed (optional)
--color (-c)        Message color: blue, yellow, orange, light_red, red, green (optional)

## How to configure Zabbix
1. Install [Incoming Webhooks app](https://slack.com/apps/A0F7XDUAZ-incoming-webhooks) to your channel. After installation you will get a webhook URL. You will need it later.
2. Goto Zabbix. Administration > Media Types

 
