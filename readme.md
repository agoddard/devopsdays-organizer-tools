A few hacky scripts for automating tasks for planning devopsdays events
Patches welcome!

These scripts have only been tested with the Austin 2013 spreadsheet, YMMV. I've tried to keep things general but email notifications are still hardcoded for Austin


##program-generator
reads google doc spreadsheet and outputs HTML for the devopsdays.org webby site

`ruby program-generator.rb (spreadsheet_key)`

Only tested so far with the format of the Austin spreadsheet

##speaker-notifier
Reads google doc spreadsheet, finds all accepted talks and output an applescript to automate Mail.app to send the mail.
Probably should switch the script to mail people directly, but it's nice to be able to override individual messages

`ruby speaker-notifier.rb (spreadsheet_key)`

##check-registration
Checks eventbrite registration against accepted talk lists in google spreadsheet. Currently uses public API data only from eventbrite, could be extended with private API data to check what price was paid

`ruby check-registration.rb (spreadsheet_key) (event_id)`
