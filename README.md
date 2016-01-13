# airport
WiFi Dashboard built using Shiny and the Mac airport utility

## Requirements
This Shiny app invokes system commands to run the airport utility on Mac OS X. If you're using some other operating system I can't help you.

For brevity the code expects that you've already created a symlink to the airport utility:

`ln -s /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport /usr/local/bin/airport`

## License

See license.txt

## Warning

This code invokes commands using `system2`.
