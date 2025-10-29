# Shisher

Version 2.3.5

An automated phishing framework designed for security research and educational purposes.

Written by darkwall
https://github.com/pythonplayer396/


## LEGAL DISCLAIMER

READ THIS CAREFULLY BEFORE USING THIS TOOL.

This software is provided strictly for educational and authorized security testing purposes only. 
Any malicious use of this tool is entirely your responsibility. Unauthorized access to computer 
systems and accounts is illegal in virtually all jurisdictions.

By using Shisher, you acknowledge that:

- You will only use this tool on systems you own or have explicit written permission to test
- Unauthorized phishing attacks are criminal offenses that carry serious legal consequences
- The author and contributors assume no liability for misuse of this software
- You understand how phishing works as an attack vector and how to defend against it
- This is a research and learning tool, not a weapon

If you intend to use this tool for illegal purposes, stop here. You are not welcome.


## What is Shisher?

Shisher is a phishing framework built in Bash that automates the creation and deployment of 
phishing pages. It includes over 30 pre-built templates mimicking popular services and supports 
multiple tunneling methods to expose local servers.

The tool is designed to help security researchers, penetration testers, and students understand 
how phishing attacks work and how to defend against them.


## Key Features

- 30+ realistic login page templates
- Automatic dependency installation
- Multiple tunneling options (localhost, Cloudflared, LocalXpose)
- Advanced device fingerprinting and tracking
- Credential harvesting with detailed victim information
- Real-time activity logging
- URL masking support
- Docker support for isolated testing
- Clean, minimal interface
- Cross-platform compatibility


## Requirements

Shisher needs the following to run:

- git
- curl  
- php
- unzip

Don't worry about installing these manually. When you first run Shisher, it will detect what's 
missing and install dependencies automatically using your system's package manager.


## Installation

### Standard Installation

Clone this repository:

```bash
git clone --depth=1 https://github.com/pythonplayer396/shisher.git
```

Navigate to the directory:

```bash
cd shisher
```

Run the main script:

```bash
bash shisher.sh
```

The first run will install all necessary dependencies. After that, you're ready to go.


### Termux Installation

If you're using Termux on Android, you can install via tur-repo:

```bash
pkg install tur-repo
pkg install shisher
shisher
```

Important: Termux explicitly discourages using the platform for hacking activities. 
Do not discuss or promote Shisher in official Termux channels. See the Termux wiki 
on hacking for their policy.


### Debian Package Installation

Download the appropriate .deb file from the releases page:
https://github.com/pythonplayer396/shisher/releases/latest

For Termux, use the file ending in *_termux.deb

Install using apt:

```bash
apt install ./shisher_*.deb
```

Or using dpkg:

```bash
dpkg -i ./shisher_*.deb
apt install -f
```


### Docker Installation

Pull the image from DockerHub:

```bash
docker pull pythonplayer396/shisher
```

Or from GitHub Container Registry:

```bash
docker pull ghcr.io/pythonplayer396/shisher:latest
```

Run as a temporary container:

```bash
docker run --rm -ti pythonplayer396/shisher
```

Note: Make sure to mount the auth directory to preserve captured data.

You can also use the wrapper script:

```bash
curl -LO https://raw.githubusercontent.com/pythonplayer396/shisher/master/run-docker.sh
bash run-docker.sh
```


## How to Use

1. Run shisher.sh
2. Choose a phishing template from the list
3. Select a tunneling method (Cloudflared, LocalXpose, or localhost)
4. Share the generated link with your target (in authorized testing scenarios only)
5. Wait for credentials to be captured
6. Review captured data in the auth/ directory

All captured information is saved in the auth folder, including:
- Credentials (usernames.dat)
- IP addresses and geolocation data (ip.txt)
- Device fingerprints (fingerprint.txt)
- MAC addresses when available (mac_hunt.txt)


## Supported Platforms

Tested and working on:

- Ubuntu
- Debian
- Arch Linux
- Manjaro
- Fedora
- Termux (Android)

Should work on most Unix-like systems with bash support.


## Advanced Features

### Device Fingerprinting

Shisher captures detailed device information including:
- Screen resolution and color depth
- CPU core count and architecture
- Available memory
- Installed plugins and extensions
- Canvas fingerprinting
- WebGL renderer information
- Audio context fingerprinting
- Battery status
- Network information
- Geolocation (if permitted)
- Local IP addresses

### Activity Logging

Real-time activity logging displays all events in a separate terminal window, including:
- Server initialization
- Victim connections
- Captured credentials
- IP and geolocation data
- Device fingerprint collection
- Timestamp for all events


## Project Structure

```
shisher/
├── shisher.sh          # Main executable
├── .sites/             # Phishing page templates
├── .server/            # Temporary server files
├── auth/               # Captured data storage
├── scripts/            # Helper scripts
└── build_env/          # Build configuration files
```


## Captured Data

All harvested information is stored in the auth/ directory:

- usernames.dat: Captured credentials
- ip.txt: IP addresses with geolocation data
- fingerprint.txt: Detailed device fingerprints
- mac_hunt.txt: Discovered MAC addresses


## Tunneling Methods

### Localhost
Basic option for local testing. Server runs on your machine only.

### Cloudflared
Creates a tunnel through Cloudflare's network. No account required. 
Generates a random subdomain that expires when the session ends.

### LocalXpose
Alternative tunneling service. Requires a free account for extended use.
Provides custom subdomain options.


## Contributing

This is an open source project. If you want to contribute:

- Fork the repository
- Create a feature branch
- Make your changes
- Test thoroughly
- Submit a pull request

Bug reports and feature requests are welcome in the issues section.


## Support

If you encounter issues:

1. Make sure all dependencies are installed
2. Check that you have appropriate permissions
3. Verify your internet connection for tunneling features
4. Review the activity log for error details
5. Open an issue on GitHub with details about your problem


## License

This project is released under an open source license. See LICENSE file for details.


## Ethics and Responsible Use

Phishing is a serious threat to online security. This tool exists to:

- Educate people about how phishing attacks work
- Help security professionals test defenses
- Train users to recognize phishing attempts
- Research attack vectors and mitigation strategies

If you use Shisher, use it responsibly. Get proper authorization before any testing.
Help make the internet safer, not more dangerous.


## Contact

Author: darkwall

GitHub: https://github.com/pythonplayer396
Discord: https://discord.com/users/1238914120179515402


---

Remember: With knowledge comes responsibility. Use this tool wisely.
