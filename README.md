# SlopBro for LG CineBeam HU710PW

Root access for the **LG CineBeam HU710PW** running webOS.

This project is an adaptation of [throwaway96's SlopBro](https://github.com/throwaway96/slopbro), modified to make the `jsserver` exploit and autoroot process work on the LG CineBeam HU710PW projector.

> [!WARNING]
> This project exploits and modifies software running on your projector.
>
> **Use it at your own risk.**
>
> Modifications performed with root privileges can potentially render the device unusable. Do not modify system partitions or unknown hardware interfaces unless you know exactly what you are doing.

## Tested Device

This project has currently been tested on:

- **Device:** LG CineBeam HU710PW
- **webOS:** 6.3.1
- **Firmware:** 03.01.13
- **Platform:** K7LP / Realtek
- **Result:** Root access + Homebrew Channel

Other LG CineBeam models and firmware versions may use similar webOS components, but they have **not been tested yet**.

## What is this?

The original SlopBro project targets LG webOS TVs.

The LG CineBeam HU710PW also runs webOS and contains much of the same underlying webOS infrastructure. However, differences in the applications available on the projector prevent the original SlopBro configuration from working without modification.

This repository adapts SlopBro for the CineBeam HU710PW and provides a way to obtain persistent root access on the projector.

## HU710PW Compatibility

The main compatibility change is the WAM application used to launch the exploit.

On the tested HU710PW, `com.webos.app.voiceweb` can be used as the target application.

The corresponding `TARGET_APPS` configuration was extended from:

```python
[11]
```

to:

```python
[6, 11]
```

This allows `com.webos.app.voiceweb` to be used as an exploit target on the HU710PW running webOS 6.

Additional CineBeam-specific changes may be added as other firmware versions and devices are tested.

## How It Works

The exploit mechanism is inherited from the original SlopBro project.

At a high level, SlopBro:

1. Starts a local HTTP server containing the exploit and payload.
2. Establishes an SSAP connection to the webOS device.
3. Launches a suitable WAM application and points it at the exploit page.
4. Uses the application's privileged Luna access to deploy a fake `com.webos.service.jsserver` package.
5. Exploits `jsserver` to execute the payload with root privileges.
6. Runs `autoroot.sh`.
7. Installs and configures the Homebrew environment.

The CineBeam adaptation changes the configuration required to make this process work on the HU710PW.

## Usage

Clone this repository:

```bash
git clone <YOUR-REPOSITORY-URL>
cd <YOUR-REPOSITORY-NAME>
```

Make sure your computer and projector are connected to the same local network.

Find the IP address of the HU710PW and run:

```bash
python3 slopbro.py <PROJECTOR_IP>
```

For example:

```bash
python3 slopbro.py 192.168.1.100
```

Accept the pairing request displayed by webOS when prompted.

SlopBro will then attempt to launch the exploit and execute the autoroot process.

After a successful installation, the **Homebrew Channel** should be available on the projector.

## Documentation

Additional CineBeam-specific research, commands and examples are documented separately from the rooting process.

These documents contain examples of functionality that becomes accessible after obtaining root access and are **not required for rooting the projector**.

See the [`docs`](docs/) directory for more information.

## Original Project

This project is based on [SlopBro by throwaway96](https://github.com/throwaway96/slopbro).

SlopBro provides the original `jsserver` exploit implementation, web payload, autoroot mechanism and supporting tooling used by this project.

This repository contains modifications and documentation for compatibility with the **LG CineBeam HU710PW**.

Huge thanks to **throwaway96** and the webOS homebrew/rooting community for the original research and tooling.

## Disclaimer

This project is intended for research, experimentation and modification of devices you own or are authorized to modify.

This project is not affiliated with, endorsed by or supported by LG Electronics.

Exploiting or modifying system software may void warranties, cause data loss, interfere with firmware updates or render a device unusable.

You are responsible for any modifications made to your device.

## License

This project is derived from SlopBro and is distributed under the terms of the **GNU Affero General Public License v3.0 or later (AGPL-3.0-or-later)**.

The original copyright and license notices are retained.

See [`COPYING`](COPYING) for the complete license text.