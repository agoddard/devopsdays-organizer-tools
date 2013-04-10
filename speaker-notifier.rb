#!/usr/bin/env ruby
require 'google_drive'

account = YAML.load_file('./settings.yaml')
session = GoogleDrive.login(settings['mail'], settings['password'])

# prolly wanna optparse
if ARGV[0].nil?
  puts "You must supply a google spreadsheet key"
  puts "Usage: ruby speaker-notifier.rb (key)"
  exit 1
end
key = ARGV[0]

worksheets = ["Accepted Ignites","Rejected Ignites","Accepted Talks","Rejected Talks"]

#todo dry the ish out of this
def reject(name,email,title,type)
  message = []
  message << "Dear #{name.split[0]},\nThank you for submitting a proposal for DevOpsDays Austin 2013!"
  if type == "ignite"
  message << "Unfortunately, due to the high number of ignite talks submitted, we were unable to select all of the proposals, and unfortunately '#{title}' wasn't selected this year.\nThis year we will be running open mic ignites on Wednesday, so we'd encourage you to come along and present your ignite during the open mic ignite session.\nIf you have not yet purchased a ticket for the event, we'd also like to extend a $60 discount for being awesome and submitting a proposal.\nTo take advantage of the discount, simply use the promo code 'DODLOVE' when registering. This code will expire on April 12.\n\nThanks again for proposing an ignite talk, we look forward to seeing you in Austin!"
    elsif type =="talk"
      message << "This year we received over 35 proposals for only 7 speaker slots, and spent considerable time deciding on the program for the event.\nUnfortunately '#{title}' wasn't selected this year, but we would like to encourage you to pitch your topic during the event for an Open Space, or to join in the open mic ignites on Wednesday.\nTo say thank you for being awesome and submitting a talk, we'd like to offer you a $60 discount for your ticket to the event.\nTo take advantage of the discount, simply use the promo code 'DODLOVE' when registering. This code will expire on April 12.\n\nThanks again for proposing a talk, we look forward to seeing you in Austin!"
  end
  message << "\nBest,\nDevopsDays Austin 2013 Team\nproposals-austin-2013@devopsdays.org"
  
  
  script = []
  script << "tell application \"Mail\""
  script << "	set newMessage to make new outgoing message with properties {subject:\"DevopsDays Austin Proposal: #{title}\",content:\"#{message.join('\n')}\" & return & return}"
  script << "	tell newMessage"
  script << "		set visible to true"
	script << "make new to recipient at end of to recipients with properties {name:\"#{name}\", address:\"#{email}\"}"
  script << "make new to recipient at end of cc recipients with properties {name:\"Austin 2013 Proposals\", address:\"proposals-austin-2013@devopsdays.org\"}"
  script << "end tell"
  script << "activate"
  script << "end tell"
  return script.join("\n")
end
 
def accept(name,email,title,type)
  message = []
  message << "Dear #{name.split[0]},\nThank you for submitting a proposal for DevOpsDays Austin 2013!"
  if type == "ignite"
  message << "Congratulations, '#{title}' was selected by our program committee to be part of the ignite program for the event. We're really excited about the event and wanted to say a huge thank you for being a part of the program. \nAs a speaker, you'll have free entry to the event but you still need to register if you haven't already.\nYou can register at http://devopsdays.org/events/2013-austin/registration/ where you'll need to select the 'Special' ticket type and enter the promotional code 'DOD-LOVES-SPEAKERS'\n\nThanks again for proposing an ignite talk, we look forward to seeing you in Austin!"
    elsif type =="talk"
      message << "Congratulations, your proposed talk '#{title}' was selected by our program committee to be a part of the DevopsDays Austin program this year.\nThis year was tough - we received over 35 proposals for only 7 speaker slots, and spent considerable time deciding on the program for the event.\nWe're really excited about this year's event and wanted to say a huge thank you for being a part of the program. As a speaker, you'll have free entry to the event but you still need to register if you haven't already.\nYou can register at http://devopsdays.org/events/2013-austin/registration/ where you'll need to select the 'Special' ticket type and enter the promotional code 'DOD-LOVES-SPEAKERS'\n\nThanks again for proposing a talk, we look forward to seeing you in Austin!"
  end
  message << "\nBest,\nDevopsDays Austin 2013 Team\nproposals-austin-2013@devopsdays.org"
  
  
  script = []
  script << "tell application \"Mail\""
  script << "	set newMessage to make new outgoing message with properties {subject:\"DevopsDays Austin Proposal: #{title}\",content:\"#{message.join('\n')}\" & return & return}"
  script << "	tell newMessage"
  script << "		set visible to true"
	script << "make new to recipient at end of to recipients with properties {name:\"#{name}\", address:\"#{email}\"}"
#  if CC is required
#  script << "make new to recipient at end of cc recipients with properties {name:, address:}"
  script << "end tell"
  script << "activate"
  script << "end tell"
  return script.join("\n")
end


worksheets.each do |worksheet|
  ws = session.spreadsheet_by_key(key).worksheet_by_title(worksheet)
  if ws.title.downcase.include? 'ignite'
    type = "ignite"
  elsif ws.title.downcase.include? 'talk'
    type = "talk"
  end
  ws.rows.each do |row|
    name,email,title = row
    next if name.downcase == "name"
    if ws.title.downcase.include? 'accept'
      puts accept(name,email,title,type)
    elsif ws.title.downcase.include? 'reject'
      puts reject(name,email,title,type)
    end
  end
end
