nagios-page-bulksms
===================

A (very nasty) script to page people from Nagios via BulkSMS. It's here only in the hopes it be useful to someone someday.

To use it you'll need to change everywhere you see "changeme".

If there's any interest I'll fix it up some day.

Configuration
-------------

    define command{
            command_name    notify-host-by-sms-script-bulksms
            command_line    /usr/bin/printf "%b" "Type:$NOTIFICATIONTYPE$\nHost:$HOSTNAME$\nState:$HOSTSTATE$\nAddress:$HOSTADDRESS$\nInfo:$HOSTOUTPUT$\nDate/Time: $LONGDATETIME$" |  $USER1$    /bulksms.rb
            }
    
    define command{
            command_name    notify-service-by-sms-script-bulksms
            command_line    /usr/bin/printf "%b" "$SERVICEOUTPUT$\nType:$NOTIFICATIONTYPE$\nService:$SERVICEDESC$\nHost:$HOSTALIAS$\nAddress:$HOSTADDRESS$\nState: $SERVICESTATE$\nDate/Time:     $LONGDATETIME$" |  $USER1$/bulksms.rb
            }
    
    
    define contact{
            contact_name                    sms
            alias                           Ops
            service_notification_period     24x7
            host_notification_period        24x7
            service_notification_options    u,c,r
            host_notification_options       d,r
            service_notification_commands   notify-service-by-sms-script-bulksms
            host_notification_commands      notify-host-by-sms-script-bulksms
            }
    