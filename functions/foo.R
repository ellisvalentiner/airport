
# Channel frequences in MHz lookup
# from: http://www.radio-electronics.com/info/wireless/wi-fi/80211-channels-number-frequencies-bandwidth.php
channelFrequencies <- data.table(wifi_channel = c(seq(1, 11), seq(36, 48, 4)),
                                 MHz = c(seq(2412, 2462, 5), seq(5180, 5240, 20)))

# Convert RSSI to distance in meters
# from: http://stackoverflow.com/a/18359639/2643154
# and also: http://www.rapidtables.com/electric/decibel.htm
rssi_to_meters <- function(dBm, channel){
  if (is.character(channel)){
    channel <- strsplit(channel, ",")[[1]][[1]] %>% as.numeric
  }
  MHz <- channelFrequencies[wifi_channel==channel, MHz]
  10^((27.55 - (20 * log(MHz, base=10)) + abs(dBm))/20) %>%
    return
}

get_preferences <- function(){
  prefs <- system2("airport", "prefs", stdout=TRUE) %>%
    .[3:10] %>%
    strsplit("=") %>%
    do.call(rbind, .)
  colnames(prefs) <- c("Key", "Value")
  return(prefs)
}

perform_scan <- function(){
  x <- system2("airport", "-I", stdout=TRUE) %>%
    gsub("^\\s+|$\\s+", "", .) %>%
    strsplit(., ":")
  keys = sapply(x, '[', 1) %>%
    make.names %>%
    c(., "Time")
  values = sapply(x, '[', -1) %>%
    lapply(., paste, collapse=":") %>% 
    gsub("^\\s+|$\\s+", "", .) %>%
    c(., as.ITime(Sys.time())) %>%
    as.list
  DT <- rapply(values, utils::type.convert, classes = "character", how = "replace", as.is = TRUE) %>%
    rbind.data.frame %>%
    data.table
  setnames(DT, names(DT), keys)
  DT[, snr := agrCtlRSSI / agrCtlNoise]
  DT[, distm := rssi_to_meters(agrCtlRSSI, channel)]
  return(DT)
}

plot_labeller <- function(x){
  c("agrCtlRSSI"="db", "agrCtlNoise"="db", "snr"="S/N", "distm"="meters")[x] %>%
    return
}