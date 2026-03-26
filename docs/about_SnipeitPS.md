# About SnipeitPS
## about_SnipeitPS

# SHORT DESCRIPTION
PowerShell API Wrapper for Snipe-IT.

# LONG DESCRIPTION
Collection of tools that makes interacting with Snipe-IT API more pleasant.

# EXAMPLES
Prepare connection to Snipe-IT with:

Connect-SnipeitPS -url https://your.site -apikey YourVeryLongApiKey....

For secure ways to pass API key to script, see Get-Help Connect-SnipeitPS -full

To search assets use:

Get-SnipeitAsset -search needle

Piping get and new commands results to set commands is supported. Following will
set notes for every asset that has model_id 123.

Get-SnipeitAsset -model_id 123 -all | Set-SnipeitAsset

You can get specific items with -id parameter like

Get-SnipeitModel -id 123

# NOTE
Most of commands are using same parameters as in Snipe-IT API,
but it's always a good idea to check syntax with Get-Help

# TROUBLESHOOTING NOTE
Check your API Key and certificate on server first.

# SEE ALSO

Report any issues to:
[GitHub project page](https://github.com/snazy2000/SnipeitPS/issues)

# KEYWORDS

- Snipe-IT
- asset management
