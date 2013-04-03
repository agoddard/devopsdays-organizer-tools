#!/usr/bin/env ruby
require 'google_drive'

account = YAML.load_file('./account.yaml')
session = GoogleDrive.login(account['mail'], account['password'])
key = ARGV[0]
ws = session.spreadsheet_by_key(key).worksheets[0]
ws.rows.each_with_index do |row,index|

  time,event,description,type,location = row
  next if time == ""
    
  #day header
  if time.match(/^Day/)
    puts "<div class=\"span-7 append-bottom border\">"
    puts "<div class=\"span-7 last\">"
    puts "<h4>#{row[0]} </h4>"
    puts "</div>"
    next
  end

  time = Time.parse(time).strftime('%H:%M')
  finish_time = Time.parse(ws.rows[index+1][0]).strftime('%H:%M') rescue nil
  
  print "<div class=\"span-2\">#{time}"
  print "- #{finish_time ||= ''}" if finish_time
  print "</div>"
  #if it's break or lunch, <div class="span-4 append-bottom last">
  if %w(introduction break lunch closing).include? event.downcase
    puts "<div class=\"span-4 append-bottom last\">#{event}</div>"
  else
    print "<div class=\"span-4 box last\"><strong>#{event}</strong>"
    print " (#{type}) " unless type == ""
    print "<br /> #{description}</div>"
  end
  if event.downcase == "closing"
    puts "</div>"
  end
end
