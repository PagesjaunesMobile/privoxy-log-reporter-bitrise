# privoxy-log-reporter-bitrise

This step is useful to analyze Privoxy's logs.
In order for this step to work you should first use `Privoxy` step.

# To Do

- support for multiple regexes

# Changelog

* 1.0.0

  * Extract all request from the log and expose them in `PRIVOXYLOG_REQUEST_DATA`
  * Extract all request that match the regex and expose them in `PRIVOXYLOG_FILTERED_DATA`
  * Can kill Privoxy
  * Can delete Privoxy log file
