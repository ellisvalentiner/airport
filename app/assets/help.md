# Help

This is the help page for the Shiny WiFi Dashboard.

Wireless signal strength is usually measured using the power ratio of [decibels (db)](https://en.wikipedia.org/wiki/Decibel).

The maximum received signal power of a wireless network (802.ll) is about -10 dBm. The maximum achievable signal strength is typically about -30 dBm. Signal strength less than -80 dBm 

### Received Signal Strength Indicator (RSSI)

Received signal strength indicator is a measure of the signal strength as measured by the receiving device.

### Noise

Documentation here.

### Quality

Quality is based on the signal-to-noise ratio (SNR).

### Distance

Distance is approximated using [free-space path loss](https://en.wikipedia.org/wiki/Free-space_path_loss) equation.

$m = 10^{(27.55 - (20 * \log_{10} F)) + \frac{\lvert S \rvert}{20}}$

where $F$ is the frequency in MHz, $S$ is the signal strength, and $m$ is distance in meters.

Each channel operates on a different frequency (e.g. channel 1 has a center frequency of 2412 and ranges from 2401 to 2423) so I employ a lookup table to find the center frequency for the particular channel ([reference](http://www.radio-electronics.com/info/wireless/wi-fi/80211-channels-number-frequencies-bandwidth.php)).

It should be noted that FSPL is based on _line of sight_ and WiFi signals are almost never unobstructed so distance estimates may be especially wrong.
