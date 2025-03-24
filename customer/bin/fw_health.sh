#!/usr/bin/env bash

# v1.1 | initial version | Robert N.
# v1.2 | add documentation | fdiaz@paloaltonetworks.com
# v1.3 | add logging | fdiaz@paloaltonetworks.com

# --- Some config Variables ----------------------------------------
IS_CHECKPOINT_FW=false
MY_DATE=$(date '+%Y-%m-%d-%H')
RAW_OUTPUT="stage_release_output_${MY_DATE}.txt" # log file name
ERRORCODE=0
TEMPINTFS="/home/admin/Palo/fws/test.$$"
DAILY="/tmp/daily-push"
THREAT="/tmp/threat-push"
COLLECTOR="/tmp/collector-group"

function check_environment() {
  # There is a BASH shell version 3.1.17(1) on checkpoint firewalls
  BASH_VERSION=$(bash --version | grep "GNU bash, version" | cut -f4 -d" ")
  if $verbose; then echo -e "${LGREEN}Found BASH version: ${NC}${BASH_VERSION}" | tee -a "${RAW_OUTPUT}"; fi
  if [ -d "/opt/CPshared" ]; then
    . /opt/CPshared/5.0/tmp/.CPprofile.sh
    echo -e "\n${YELLOW}Running on a Checkpoint FW${NC}" | tee -a "${RAW_OUTPUT}"
    IS_CHECKPOINT_FW=true
    CURL_COMMAND="curl_cli"
    ALL_FW=""
  else
    echo -e "${LGREEN}NOT Running on a Checkpoint FW${NC}" | tee -a "${RAW_OUTPUT}"
    declare -A ALL_FW # cannot declare an associative array in older BASH
  fi
}

function logging() {
  if [ -d "../logs" ]; then
    RAW_OUTPUT="../logs/${RAW_OUTPUT}"
  fi
  echo -e "\n${LCYAN}-------------------- Starting Tool --------------------${NC}" | tee -a "${RAW_OUTPUT}"
  echo -e "${LGREEN}Found log dir, log path is: ${NC}${RAW_OUTPUT}"
}

function GET-INSTALL-TIME() {
  ITIME=$(
    curl_cli -s -k -d key=$KEY --data-urlencode "cmd=<show><system><last-commit-info></last-commit-info></system></show>" \
      -d 'type=op' -d 'action=all' -d "target=$i"https://$PA_api_ &
    d=DwIGAg &
    c=V9IgWpI5PvzTw83UyHGVSoW3Uc1MFWe5J8PTfkrzVSo &
    r=d_SIK3IecoP71XVjpi3BcPZoxsUHqt7sJzKUz6ty7Sk &
    m=W77N28e3ZJalPbZYLQx6JjUAgieML5e_F2Oj2gea2h2FTj6cX8plAOCeBMFbsoS3 &
    s=4tyM835rSwE1WkNSPgWWTbuaSkXjs8dKZWYgGhGSlts &
    e= |
      grep "finish>" | tail -1 | awk -F'[<>]' '{print $3}'
  )

  # we got out to the FW instead of cat this file
  # echo "cat /response/result/last-commited-info/finish" | xmllint --nocdata --shell commit.last | awk -F'[<>]' '{print $3}'
  # add error checking here
}

function GET_INTERFACE_NAME() {
  LINE=$(grep -vf $FW_INTFS $TEMPINTFS)
  if [ $? -eq 0 ]; then
    INTERFACENUM=$(echo $LINE | awk -F"[. ]" '{print $2}')
    snmpwalk -v 3 -l authPriv -u xxxxx -a SHA! -Ovq $hostip IF-MIB::ifName.$INTERFACENUM
  else
    echo "unkown interface"
  fi
}

function GET_MGMT_PERMITTED() {
  if [ "$connected" == "yes" ]; then
    curl_cli -s -k -d key=$KEY -d 'type=config' -d 'action=get' -d "xpath=/config/devices/entry[@name='localhost.localdomain']/deviceconfig/system/permitted-ip" -d "target=$i" https://urldefense.proofpoint.com/v2/url?u=https-3A__-24PA_api_ &
    d=DwIGAg &
    c=V9IgWpI5PvzTw83UyHGVSoW3Uc1MFWe5J8PTfkrzVSo &
    r=d_SIK3IecoP71XVjpi3BcPZoxsUHqt7sJzKUz6ty7Sk &
    m=W77N28e3ZJalPbZYLQx6JjUAgieML5e_F2Oj2gea2h2FTj6cX8plAOCeBMFbsoS3 &
    s=4tyM835rSwE1WkNSPgWWTbuaSkXjs8dKZWYgGhGSlts &
    e= | grep -q 'code="7"'
    if [ $? -eq 0 ]; then
      MESSAGE=$(echo "$MESSAGE : FIREWALL missing MGMT ACL")
      ERRORCODE=$(($ERRORCODE + 1))
    fi

  fi
}

function PERFORM-SCHEDULE-THREAT-CHECK() {
  # only test connected devices for schedule
  if [ "$connected" == "yes" ]; then
    grep -q $i $THREAT
    if [ $? -eq 1 ]; then
      MESSAGE=$(echo "$MESSAGE : FIREWALL missing from update threat schedule")
      ERRORCODE=$(($ERRORCODE + 1))
    fi
  # we could add and "else" to list out what we skipped
  fi

}

function PERFORM-SCHEDULE-PUSH-CHECK() {
  # only test connected devices for schedule
  if [ "$connected" == "yes" ]; then
    grep -q $i $DAILY
    if [ $? -eq 1 ]; then
      MESSAGE=$(echo "$MESSAGE : FIREWALL missing from Daily schedule config push")
      ERRORCODE=$(($ERRORCODE + 1))
    fi
  fi
}

function PERFORM-COLLECTOR-GROUP() {
  #only test connected devices for collector group
  if [ "$connected" == "yes" ]; then
    grep -q $i $COLLECTOR
    if [ $? -eq 1 ]; then
      MESSAGE=$(echo "$MESSAGE : FIREWALL missing from collector-group")
      ERRORCODE=$(($ERRORCODE + 1))
    fi
  fi

}

function PROCESS_FWS() {
  #check for valid key, as it expires
  grep "Invalid Credential" test.xml >>push.out.$$

  serialnums="$(echo "cat /response/result/devices/entry/serial/text()" | xmllint --nocdata --shell test.xml | sed '1d;$d' | sed -e 's/-------//g')"

  for i in $serialnums; do

    hostname="$(echo "cat /response/result/devices/entry[@name='$i']/hostname/text()" | xmllint --nocdata --shell test.xml | sed '1d;$d' | tr [:lower:] [:upper:])"
    hostip="$(echo "cat /response/result/devices/entry[@name='$i']/ip-address/text()" | xmllint --nocdata --shell test.xml | sed '1d;$d')"

    connected="$(echo "cat /response/result/devices/entry[@name='$i']/connected/text()" | xmllint --nocdata --shell test.xml | sed '1d;$d')"

    swver="$(echo "cat /response/result/devices/entry[@name='$i']/sw-version/text()" | xmllint --nocdata --shell test.xml | sed '1d;$d')"

    hardware="$(echo "cat /response/result/devices/entry[@name='$i']/model/text()" | xmllint --nocdata --shell test.xml | sed '1d;$d')"
    hastate="$(echo "cat /response/result/devices/entry[@name='$i']/ha/state/text()" | xmllint --nocdata --shell test.xml | sed '1d;$d')"

    if [ -z "$hastate" ]; then
      false
    else
      if [[ $(echo $hostname | grep 2) ]] && [[ $hastate == "active" ]]; then
        hastate=", HA state $hastate WARNING SECONDARY HA IS PRIMARY"
        ERRORCODE=$(($ERRORCODE + 1))
      else
        if [ $hastate == "non-func" ]; then
          ERRORCODE=$(($ERRORCODE + 1))
          hastate=", HA state $hastate ERROR DEVICE IS DOWN "
        else
          hastate=", HA state $hastate "
        fi
      fi
    fi

    # check if device is connected, if not skip status as no ip addr exist
    if [ "$connected" == "yes" ]; then
      # get the interface status and error code
      answer=$(GET_INTFS_STATUS $ERRORCODE)
      #ERRORCODE=$(($ERRORCODE+`echo $answer | cut -d"," -f1`))
      ERRORCODE=$(echo $answer | cut -d"," -f1)
      MESSAGE=$(echo $answer | cut -d"," -f2)
    else
      hostname=unknown
      MESSAGE=""
    fi

    PERFORM-COLLECTOR-GROUP
    PERFORM-SCHEDULE-PUSH-CHECK
    PERFORM-SCHEDULE-THREAT-CHECK # enable after license issue is resolved
    GET_MGMT_PERMITTED
    GET-INSTALL-TIME

    echo "$hostname $hardware $hostip $i $swver, Connected status $connected $hastate, $MESSAGE $ITIME" >>push.out.$$
  done
}

function GET_INTFS_STATUS() {
  FW_INTFS=/home/admin/Palo/fws/$hostname.fw
  local ERR=$1

  snmpwalk -v 3 -l! -Oq $hostip IF-MIB::ifOperStatus >$TEMPINTFS

  if [ $? -eq 0 ]; then
    # test for valid snmp response
    sed -i -n -r '/IF-MIB::ifOperStatus.[0-9]{1,2} up/p' $TEMPINTFS
    # clean file (remove loopback and vlan interfaces
    if [ -f $FW_INTFS ]; then
      diff $FW_INTFS $TEMPINTFS >>/dev/null
      # compare with a known good result

      if [ $? -eq 0 ]; then
        echo "$ERR," #return error count and messages
      else
        ERR=$(($ERR + 1))
        echo "$ERR,**************** Check Interface $(GET_INTERFACE_NAME) "
      fi

    else
      cp $TEMPINTFS $FW_INTFS
      echo "$ERR," #return error count and messages
    fi

  else
    ERR=$(($ERR + 1))
    echo "$ERR,***************** Bad or no response from SNMP request"
  fi
  rm $TEMPINTFS
}

function elastic_check() {
  #XML_RESPONSE=$(${CURL_COMMAND} -X POST "https://${PANORAMA_IP}/api?type=op&cmd=<show><log-collector-es-cluster><health></health></log-collector-es-cluster></show>&key=${XML_API_KEY}")
  echo ""
}

function main() {

  cd /tmp/palo

  # check daemon status and start
  if ! (/opt/postfix/usr/sbin/postfix status 2>>/dev/null); then
    /opt/postfix/usr/sbin/postfix start 2>>/dev/null
  fi

  #process panorama-production
  PA="PA"

  KEY="=="
  curl_cli -k -d key=$KEY --output test.xml --data-urlencode "cmd=<show><devices><all></all></devices></show>" -d 'type=op' -d 'action=all' https://urldefense.proofpoint.com/v2/url?u=https-3A__-24PA_api_ &
  d=DwIGAg &
  c=V9IgWpI5PvzTw83UyHGVSoW3Uc1MFWe5J8PTfkrzVSo &
  r=d_SIK3IecoP71XVjpi3BcPZoxsUHqt7sJzKUz6ty7Sk &
  m=W77N28e3ZJalPbZYLQx6JjUAgieML5e_F2Oj2gea2h2FTj6cX8plAOCeBMFbsoS3 &
  s=4tyM835rSwE1WkNSPgWWTbuaSkXjs8dKZWYgGhGSlts &
  e= 2>/dev/null

  # get the schedule push and append pyros
  curl_cli -k -d key=$KEY -d 'type=config' -d 'action=get' -d "xpath=/config/devices/entry[@name='localhost.localdomain']/deviceconfig/system/push-schedule/entry[@name='Daily-push']" https://urldefense.proofpoint.com/v2/url?u=https-3A__-24PA_api_ &
  d=DwIGAg &
  c=V9IgWpI5PvzTw83UyHGVSoW3Uc1MFWe5J8PTfkrzVSo &
  r=d_SIK3IecoP71XVjpi3BcPZoxsUHqt7sJzKUz6ty7Sk &
  m=W77N28e3ZJalPbZYLQx6JjUAgieML5e_F2Oj2gea2h2FTj6cX8plAOCeBMFbsoS3 &
  s=4tyM835rSwE1WkNSPgWWTbuaSkXjs8dKZWYgGhGSlts &
  e= 2>/dev/null >$DAILY
  echo "010108010498 010108010493" >>$DAILY

  curl_cli -k -d key=$KEY -d 'type=config' -d 'action=get' -d "xpath=/config/devices/entry[@name='localhost.localdomain']/deviceconfig/system/deployment-update-schedule/entry[@name='Apps and Threat']" https://urldefense.proofpoint.com/v2/url?u=https-3A__-24PA_api_ &
  d=DwIGAg &
  c=V9IgWpI5PvzTw83UyHGVSoW3Uc1MFWe5J8PTfkrzVSo &
  r=d_SIK3IecoP71XVjpi3BcPZoxsUHqt7sJzKUz6ty7Sk &
  m=W77N28e3ZJalPbZYLQx6JjUAgieML5e_F2Oj2gea2h2FTj6cX8plAOCeBMFbsoS3 &
  s=4tyM835rSwE1WkNSPgWWTbuaSkXjs8dKZWYgGhGSlts &
  e= 2>/dev/null >$THREAT
  #in version 10.1 prod "Apps and Threat"  NO "S" IN THREAT
  #in version 10.2 prod "Apps and Threats"  THE "S" EXISTS IN THREATS
  #echo "010108010498 010108010493">>$THREAT

  curl_cli -k -d key=$KEY --data-urlencode "cmd=<show><log-collector-group><name>default</name></log-collector-group></show>" -d 'type=op' -d 'action=all' https://urldefense.proofpoint.com/v2/url?u=https-3A__-24PA_api_ &
  d=DwIGAg &
  c=V9IgWpI5PvzTw83UyHGVSoW3Uc1MFWe5J8PTfkrzVSo &
  r=d_SIK3IecoP71XVjpi3BcPZoxsUHqt7sJzKUz6ty7Sk &
  m=W77N28e3ZJalPbZYLQx6JjUAgieML5e_F2Oj2gea2h2FTj6cX8plAOCeBMFbsoS3 &
  s=4tyM835rSwE1WkNSPgWWTbuaSkXjs8dKZWYgGhGSlts &
  e= 2>/dev/null >$COLLECTOR

  PROCESS_FWS

  #process panorama-testnet
  PA="PA-T"
  KEY=" =="
  curl_cli -k -d key=$KEY --output test.xml --data-urlencode "cmd=<show><devices><all></all></devices></show>" -d 'type=op' -d 'action=all' https://urldefense.proofpoint.com/v2/url?u=https-3A__-24PA_api_ &
  d=DwIGAg &
  c=V9IgWpI5PvzTw83UyHGVSoW3Uc1MFWe5J8PTfkrzVSo &
  r=d_SIK3IecoP71XVjpi3BcPZoxsUHqt7sJzKUz6ty7Sk &
  m=W77N28e3ZJalPbZYLQx6JjUAgieML5e_F2Oj2gea2h2FTj6cX8plAOCeBMFbsoS3 &
  s=4tyM835rSwE1WkNSPgWWTbuaSkXjs8dKZWYgGhGSlts &
  e= 2>/dev/null

  curl_cli -k -d key=$KEY -d 'type=config' -d 'action=get' -d "xpath=/config/devices/entry[@name='localhost.localdomain']/deviceconfig/system/push-schedule/entry[@name='Daily-push']" https://urldefense.proofpoint.com/v2/url?u=https-3A__-24PA_api_ &
  d=DwIGAg &
  c=V9IgWpI5PvzTw83UyHGVSoW3Uc1MFWe5J8PTfkrzVSo &
  r=d_SIK3IecoP71XVjpi3BcPZoxsUHqt7sJzKUz6ty7Sk &
  m=W77N28e3ZJalPbZYLQx6JjUAgieML5e_F2Oj2gea2h2FTj6cX8plAOCeBMFbsoS3 &
  s=4tyM835rSwE1WkNSPgWWTbuaSkXjs8dKZWYgGhGSlts &
  e= 2>/dev/null >$DAILY

  curl_cli -k -d key=$KEY -d 'type=config' -d 'action=get' -d "xpath=/config/devices/entry[@name='localhost.localdomain']/deviceconfig/system/deployment-update-schedule/entry[@name='Apps and Threats']" https://urldefense.proofpoint.com/v2/url?u=https-3A__-24PA_api_ &
  d=DwIGAg &
  c=V9IgWpI5PvzTw83UyHGVSoW3Uc1MFWe5J8PTfkrzVSo &
  r=d_SIK3IecoP71XVjpi3BcPZoxsUHqt7sJzKUz6ty7Sk &
  m=W77N28e3ZJalPbZYLQx6JjUAgieML5e_F2Oj2gea2h2FTj6cX8plAOCeBMFbsoS3 &
  s=4tyM835rSwE1WkNSPgWWTbuaSkXjs8dKZWYgGhGSlts &
  e= 2>/dev/null >$THREAT
  #in version 10.1 prod "Apps and Threat"  NO "S" IN THREAT
  #in version 10.2 prod "Apps and Threats"  THE "S" EXISTS IN THREATS

  curl_cli -k -d key=$KEY --data-urlencode "cmd=<show><log-collector-group><name>default</name></log-collector-group></show>" -d 'type=op' -d 'action=all' https://urldefense.proofpoint.com/v2/url?u=https-3A__-24PA_api_ &
  d=DwIGAg &
  c=V9IgWpI5PvzTw83UyHGVSoW3Uc1MFWe5J8PTfkrzVSo &
  r=d_SIK3IecoP71XVjpi3BcPZoxsUHqt7sJzKUz6ty7Sk &
  m=W77N28e3ZJalPbZYLQx6JjUAgieML5e_F2Oj2gea2h2FTj6cX8plAOCeBMFbsoS3 &
  s=4tyM835rSwE1WkNSPgWWTbuaSkXjs8dKZWYgGhGSlts &
  e= 2>/dev/null >$COLLECTOR

  PROCESS_FWS

  #summarize Data
  echo "    Number of devices : $(cat push.out.$$ | wc -l)" >>push.out.$$
  echo "    Number of devices running  10.1.6  : $(egrep "10\.1\.6" push.out.$$ | wc -l)" >>push.out.$$
  echo "    Number of devices running  10.1.5  : $(egrep "10\.1\.5" push.out.$$ | wc -l)" >>push.out.$$
  echo "    Number of devices running  10.0.4  : $(egrep "10\.0\.4" push.out.$$ | wc -l)" >>push.out.$$
  echo "    Number of devices running  unknown  : $(egrep "unknown" push.out.$$ | wc -l)" >>push.out.$$
  echo "   Number of PA-820 : $(egrep -ow PA-820 push.out.$$ | wc -l)" >>push.out.$$
  echo "   Number of PA-7050 : $(egrep -ow PA-7050 push.out.$$ | wc -l)" >>push.out.$$
  echo "   Number of PA-3250 : $(egrep -ow PA-3250 push.out.$$ | wc -l)" >>push.out.$$
  echo "   Number of PA-3220 : $(egrep -ow PA-3220 push.out.$$ | wc -l)" >>push.out.$$
  echo "   Number of PA-VM : $(egrep -ow PA-VM push.out.$$ | wc -l)" >>push.out.$$

  #echo "    ERRORCODE  $ERRORCODE" >>push.out.$$
  if ! [ $ERRORCODE -eq 0 ]; then
    ERRORCODE=" ERRORS $ERRORCODE"
  else
    ERRORCODE=""
  fi
  #cat push.out.$$ |sort| sed -e "1s/^/From: fwcheck@`hostname`.ups.com\nTo: UPSfwcheck@ups.com\nSubject: PA FW Health $ERRORCODE\n\n/"|  /opt/postfix/usr/sbin/sendmail tel1rxn@ups.com
  cat push.out.$$ | sort | sed -e "1s/^/From: fwcheck@$(hostname).ups.com\nTo: UPSfwcheck@ups.com\nSubject: PA FW Health $ERRORCODE\n\n/" | /opt/postfix/usr/sbin/sendmail upsfwcheck@ups.com

  #cat  push.out.$$
  rm push.out.$$ $COLLECTOR $DAILY #$THREAT

}

main "$@"
