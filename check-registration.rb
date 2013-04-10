#!/usr/bin/env ruby
require 'google_drive'
require 'eventbrite-client'

# checks to see if accepted speakers have registered for the event yet
# requires API access to eventbrite, but only supports public API requests. With a key that has access to private eventbrite data, script could check what type of ticket has been purchaed etc.

# ruby check-registration.rb (key)

# prolly wanna optparse
if ARGV[0].nil? || ARGV[1].nil?
  puts "You must supply a google spreadsheet key and event ID"
  puts "Usage: ruby check-registration.rb (key) (id)"
  exit 1
end

spreadsheet_key = ARGV[0] #Austin 0AoUCodwCv313dDROMHc5cXBaM3dzbDkxS0c3RjllSnc
event_id = ARGV[1] #Austin 5178370646

#compare everything downcase and make it look nice later
class String
  def titleize
    split(/(\W)/).map(&:capitalize).join
  end
end

#load google,eventbrite creds,establish connections
settings = YAML.load_file('./settings.yaml')
session = GoogleDrive.login(settings['mail'], settings['password'])
eb_auth_tokens = { app_key: settings['eventbrite_app_key'], user_key: settings['eventbrite_user_key']}
eb_client = EventbriteClient.new(eb_auth_tokens)

#could do with some cleanup here 0_o
attendees = eb_client.event_list_attendees({ id: event_id})
registered_attendees = []
attendees.first[1].each do|attendee|
  registered_attendees << attendee['attendee']['first_name'].downcase + ' ' + attendee['attendee']['last_name'].downcase
end

worksheets = ["Accepted Ignites","Accepted Talks"]

selected_speakers = []
worksheets.each do |worksheet|
  ws = session.spreadsheet_by_key(spreadsheet_key).worksheet_by_title(worksheet)
  ws.rows.each do |row|
    name,email,title = row
    next if name.downcase == "name"
    selected_speakers << name.downcase
  end
end

registered_speakers = []
unregistered_speakers = []
selected_speakers.each do |speaker|
  if registered_attendees.include? speaker
    registered_speakers << speaker.titleize
  else
    unregistered_speakers << speaker.titleize
  end
end

puts "Registered: (#{registered_speakers.count})"
puts registered_speakers
puts
puts "Unregistered: (#{unregistered_speakers.count})"
puts unregistered_speakers