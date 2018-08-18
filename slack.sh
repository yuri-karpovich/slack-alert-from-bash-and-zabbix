#!/usr/bin/env bash

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -w|--webhook)
    url="$2"
    shift # past argument
    shift # past value
    ;;
    -m|--message)
    message="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--severity)
    severity="$2"
    shift # past argument
    shift # past value
    ;;
    -t|--title)
    title="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--description)
    description="$2"
    shift # past argument
    shift # past value
    ;;
    -u|--username)
    username_from_params="$2"
    shift # past argument
    shift # past value
    ;;
    -c|--color)
    color_name="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done

if [ ${#POSITIONAL[@]} -eq 0 ]; then
    echo "WEB HOOK       = ${url}"
    echo "USER NAME      = ${username_from_params}"
    echo "SEVERITY       = ${severity}"
    echo "MESSAGE        = ${message}"
    echo "TITLE          = ${title}"
    echo "DESCRIPTION    = ${description}"
    echo "COLOR          = ${color_name}"
elif [[ " ${POSITIONAL[@]} " =~ "-h" ]]
then
    echo "
Please use following arguments:

--webhook (-w)      Web-hook URL
--message (-m)      Message text
--severity (-s)     Trigger severity (1-5)
--title (-t)        Message title
--description (-d)  Message description
--username (-u)     Username to be displayed
--color (-c)        Message color: blue, yellow, orange, light_red, red, green
"
    exit 1
else
    echo "Unknown argument: \"$POSITIONAL\""
    echo "
Please use following arguments:

--webhook (-w)      Web-hook URL
--message (-m)      Message text
--severity (-s)     Numerical trigger severity. Possible values: 0 - Not classified, 1 - Information, 2 - Warning, 3 - Average, 4 - High, 5 - Disaster.
--title (-t)        Message title
--description (-d)  Message description
--username (-u)     Username to be displayed
--color (-c)        Message color: blue, yellow, orange, light_red, red, green, purple
"
    exit 1
fi

# Username
default_username='Incoming WebHooks Script'
username=${username_from_params:-"${default_username}"}

# Colors
blue='#249DFF'
yellow='#E1EA95'
orange='#FFB568'
light_red='#D05C51'
red='#D00000'
green='#118919'
purple='#FF38C4'

[[ "$title" =~ ^Resolved.* ]]           && color=${green}
[[ "$title" =~ ^Information.* ]]        && color=${blue}
[[ "$title" =~ ^Warning.* ]]            && color=${yellow}
[[ "$title" =~ ^Average.* ]]            && color=${orange}
[[ "$title" =~ ^High.* ]]               && color=${light_red}
[[ "$title" =~ ^Disaster.* ]]           && color=${red}
[[ "$title" =~ ^Acknowledged.* ]]       && color=${purple}

[ "$severity" == '0' ] && color=''
[ "$severity" == '1' ] && color=${blue}
[ "$severity" == '2' ] && color=${yellow}
[ "$severity" == '3' ] && color=${orange}
[ "$severity" == '4' ] && color=${light_red}
[ "$severity" == '5' ] && color=${red}

[ "$color_name" == 'blue' ]         && color=${blue}
[ "$color_name" == 'yellow' ]       && color=${yellow}
[ "$color_name" == 'orange' ]       && color=${orange}
[ "$color_name" == 'light_red' ]    && color=${light_red}
[ "$color_name" == 'red' ]          && color=${red}
[ "$color_name" == 'green' ]        && color=${green}


payload="payload={
    \"username\":\"${username//\"/\\\"}\",
    \"attachments\":[{
        \"fallback\":\"${message//\"/\\\"}\",
        \"pretext\":\"${message//\"/\\\"}\",
        \"color\":\"${color//\"/\\\"}\",
        \"fields\":[{
            \"title\":\"${title//\"/\\\"}\",
            \"value\":\"${description//\"/\\\"}\",
            \"short\":false
}]}]}\"}"

curl -m 5 --data-urlencode "${payload}" ${url}