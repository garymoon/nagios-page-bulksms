#!/usr/bin/env ruby

require 'rubygems'
require 'net/http'
require 'net/smtp'
require 'syslog'

#See API here: http://www.bulksms.com/int/docs/eapi/submission/send_sms/

begin

  content = ARGF.read

  uri = URI('http://bulksms.vsms.net/eapi/submission/send_sms/2/2.0')
  params =
  {
    :username => '', #changeme
    :password => '', #changeme
    :dest_group_id => '', #changme
    #:msisdn => '', #use for single number
    #:allow_concat_text_sms => 1, #can only be used for single recipients
    #:concat_text_sms_max_parts => 3,
    :message => content.slice(0, 159) #limit to single sms, remove if using concar options
  }
  res = Net::HTTP.post_form(uri, params)
  if (res.body[0] != '0' and res.body[0] != 48); raise Exception, 'Message sending failed: ' + res.body.strip end

  Syslog.open($0, Syslog::LOG_PID | Syslog::LOG_CONS) { |s| s.alert '%s', 'Sent SMS: [' + content.strip + '] [' + res.body + ']' }

rescue SystemExit
  raise
# Yes I know, terrible, bla bla bla
rescue Exception => e
# Send email to via AWS if sending fails
  Syslog.open($0, Syslog::LOG_PID | Syslog::LOG_CONS) { |s| s.alert '%s', 'Unexpected error sending SMS [' + content.strip + ']:' + e.message }
  smtp = Net::SMTP.new 'email-smtp.us-east-1.amazonaws.com', 587
  smtp.start('localhost', '', '') do |smtp| #changeme
    smtp.open_message_stream('', ['']) do |f| #changeme
      f.puts 'From: ' #changeme
      f.puts 'To: ' #changeme
      f.puts 'Subject: Nagios failed to send SMS alert'
      f.puts
      f.puts 'Error: [' + e.message  + '] [' + e.backtrace[0] + ']'
      f.puts 'Message: ' + content.strip
    end
  end
end
