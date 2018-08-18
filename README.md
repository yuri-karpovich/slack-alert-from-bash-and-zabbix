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
1. Install [Incoming Webhooks app](https://slack.com/apps/A0F7XDUAZ-incoming-webhooks) to your channel in Slack
    1. After installation you will get a webhook URL. You will need it later
2. Deploy `slack.sh` script to [AlertScripts](https://www.zabbix.com/documentation/3.4/manual/config/notifications/media/script) folder
    1. By default the folder path is `/usr/local/share/zabbix/alertscripts`
    2. Make sure that file is executable: `chmod +x slack.sh`
    3. Make sure that `curl` is installed in your system: `which curl`
3. Create new Media Type in Zabbix: **Administration** > **Media Types**
    - _Name_: `Slack`
    - _Type_: `Script`
    - _Script name_: `slack.sh `
    - _Script parameters_: 
        - `-w`
        - `{ALERT.SENDTO}`
        - `--title`
        - `{ALERT.SUBJECT}`
        - `--description`
        - `{ALERT.MESSAGE}`
        - `--username`
        - `Zabbix`
    - _Enabled_: `true`
    ![media_type_1](https://raw.githubusercontent.com/yuri-karpovich/slack-alert-from-bash-and-zabbix/master/images/media_type_1.png)
4. Create new User Group in Zabbix: **Administration** > **User groups**
    - User Group Tab:
        - _Group name_: `Read-Only Group`
        - _Enabled_: `true`
        ![user_group_1](https://raw.githubusercontent.com/yuri-karpovich/slack-alert-from-bash-and-zabbix/master/images/user_group_1.png)
    - Permissions Tab:
        - Select `Host Groups` and specify `Read` permission fot them.
        ![user_group_2](https://raw.githubusercontent.com/yuri-karpovich/slack-alert-from-bash-and-zabbix/master/images/user_group_2.png) 
5. Create new User in Zabbix: **Administration** > **Users**
    > I prefer to create 2 users: slack_critical - for important notifications from Zabbix (Average, High, Disaster), and slack_not_important - for others (Not classified, Information, Warning). 
    - User tab:
        - _Alias_: `slack_critical`
        - _Name_: `Slack Critical`
        - _Groups_: `Read-Only Group`
    - Media Tab > Add:
        - _Type_: `Slack`
        - _Send to_: `Your webhook url from Step 1`
        - _Enable_: `true`
        ![user_media](https://raw.githubusercontent.com/yuri-karpovich/slack-alert-from-bash-and-zabbix/master/images/user_media.png)
6. Create new Action in Zabbix: **Configuration** > **Actions**
    - Action tab:
        - _Name_: Report problems to Slack (Disaster, High, Average)
        - _Conditions_: 
            - Trigger severity = Disaster 
            - Trigger severity = High 
            - Trigger severity = Average
        - _Enabled_: `true`
        ![action_1](https://raw.githubusercontent.com/yuri-karpovich/slack-alert-from-bash-and-zabbix/master/images/action_1.png)

    - Operations Tab:
        - _Default subject_: `{TRIGGER.SEVERITY}: {HOSTNAME}: {TRIGGER.NAME}`
        - _Default message_: 
            > Problem started at {EVENT.TIME} on {EVENT.DATE}
              Problem name: {TRIGGER.NAME}
              Host: {HOST.NAME}  ({IPADDRESS})
              Severity: {TRIGGER.SEVERITY}
            > 
            > Original problem ID: {EVENT.ID} {TRIGGER.URL} 
        - _Operations_:
            - _Send to Users_: `slack_critical`
        ![action_2](https://raw.githubusercontent.com/yuri-karpovich/slack-alert-from-bash-and-zabbix/master/images/action_2.png)

    - Recovery Operations Tab:
        - _Default subject_: `Resolved:  {HOSTNAME}: {TRIGGER.NAME}`
        - _Default message_: 
            > Problem has been resolved at {EVENT.RECOVERY.TIME} on {EVENT.RECOVERY.DATE}
              Problem name: {TRIGGER.NAME}
              Host: {HOST.NAME} ({IPADDRESS})
              Severity: {TRIGGER.SEVERITY}
            >  
            > Original problem ID: {EVENT.ID} {TRIGGER.URL} 
        - _Operations_:
            - _Send to Users_: `slack_critical`
        ![action_3](https://raw.githubusercontent.com/yuri-karpovich/slack-alert-from-bash-and-zabbix/master/images/action_3.png)
    - Acknowledgement Operations Tab:
        - _Default subject_: `Acknowledged:  {HOSTNAME}: {TRIGGER.NAME}`
        - _Default message_: 
            > {USER.FULLNAME} acknowledged problem at {ACK.DATE} {ACK.TIME} with the following message:
              {ACK.MESSAGE}
            >  
            > Current problem status is {EVENT.STATUS} 
        - _Operations_:
            - _Send to Users_: `slack_critical`
        ![action_4](https://raw.githubusercontent.com/yuri-karpovich/slack-alert-from-bash-and-zabbix/master/images/action_4.png)
7. Done! You will receive notifications from Zabbix to Slack
