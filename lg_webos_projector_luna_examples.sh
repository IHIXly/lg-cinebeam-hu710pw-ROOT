i#!/bin/sh
# LG webOS Projector – Luna Service Test Examples
#
# Reference commands for experimenting with Bluetooth audio, sound output,
# fan telemetry, and read-only system information on a rooted LG webOS projector.
#
# Replace all placeholders with values for your own device.
#
# WARNING
# -------
# These examples intentionally prefer LG's Luna service APIs over direct
# hardware access. Do not blindly write to eMMC partitions, /dev/mem, PWM,
# I2C, SPI, Micom, TEE, or other low-level device nodes.
#
# Tested concepts include:
# - High-level Bluetooth audio connect/disconnect through btaudiosrc
# - Bluetooth/A2DP status queries
# - Sound-output selection
# - Fan/temperature telemetry
# - Fan-control API experiments
# - Read-only system inspection

###############################################################################
# Configuration placeholders
###############################################################################

PROJECTOR_IP="<PROJECTOR_IP>"
SSH_KEY="<PATH_TO_SSH_KEY>"

BT_HEADPHONES="<HEADPHONES_MAC>"
BT_SPEAKERS="<SPEAKERS_MAC>"


###############################################################################
# 1. SSH
###############################################################################

# Run from another machine:
ssh -i "$SSH_KEY" root@"$PROJECTOR_IP"


###############################################################################
# 2. Bluetooth – status and device information
###############################################################################

# Bluetooth adapter status:
luna-send -n 1 -f \
  luna://com.webos.service.bluetooth2/adapter/getStatus \
  '{}'

# Known/paired Bluetooth devices:
luna-send -n 1 -f \
  luna://com.webos.service.bluetooth2/device/getStatus \
  '{}'

# Bluetooth audio device currently known as connected by LG's high-level
# Bluetooth audio service:
luna-send -n 1 -f \
  luna://com.webos.service.btaudiosrc/getConnectedDevice \
  '{}'

# Paired audio devices managed by btaudiosrc:
luna-send -n 1 -f \
  luna://com.webos.service.btaudiosrc/getPairedDevices \
  '{}'

# A2DP status for a specific device:
luna-send -n 1 -f \
  luna://com.webos.service.bluetooth2/a2dp/getStatus \
  "{\"address\":\"$BT_HEADPHONES\"}"


###############################################################################
# 3. Bluetooth – silent/high-level connect
###############################################################################

# Prefer btaudiosrc/connect over calling bluetooth2/a2dp/connect directly.
#
# On the tested firmware, btaudiosrc/connect performs the higher-level LG
# connection scenario and also switches sound output to the selected Bluetooth
# audio device.

# Connect headphones:
luna-send -n 1 -f \
  luna://com.webos.service.btaudiosrc/connect \
  "{\"address\":\"$BT_HEADPHONES\"}"

# Connect speakers:
luna-send -n 1 -f \
  luna://com.webos.service.btaudiosrc/connect \
  "{\"address\":\"$BT_SPEAKERS\"}"


###############################################################################
# 4. Bluetooth – disconnect
###############################################################################

# Disconnect headphones:
luna-send -n 1 -f \
  luna://com.webos.service.btaudiosrc/disconnect \
  "{\"address\":\"$BT_HEADPHONES\"}"

# Disconnect speakers:
luna-send -n 1 -f \
  luna://com.webos.service.btaudiosrc/disconnect \
  "{\"address\":\"$BT_SPEAKERS\"}"

# Disconnecting the active Bluetooth audio target may cause webOS to fall back
# to the internal speaker automatically.


###############################################################################
# 5. Sound output
###############################################################################

# Select the projector/TV's internal speaker:
luna-send -n 1 -f \
  luna://com.webos.settingsservice/setSystemSettings \
  '{"category":"sound","settings":{"soundOutput":"tv_speaker"}}'

# Select Bluetooth sound output:
#
# Usually unnecessary after a successful btaudiosrc/connect call, because the
# high-level service can perform the sound-output switch itself.
luna-send -n 1 -f \
  luna://com.webos.settingsservice/setSystemSettings \
  '{"category":"sound","settings":{"soundOutput":"bt_soundbar"}}'

# Read sound settings:
luna-send -n 1 -f \
  luna://com.webos.settingsservice/getSystemSettings \
  '{"category":"sound"}'


###############################################################################
# 6. Fan and temperature telemetry
###############################################################################

# Current fan-control data:
luna-send -n 1 -f \
  luna://com.webos.service.fancontroller/getFanControlData \
  '{}'

# Depending on the model/firmware, the response may contain fields such as:
#   fan1RPM
#   fan2RPM
#   fan3RPM
#   fan1Volt
#   fan2Volt
#   fan3Volt
#   ld1Temp
#   ld2Temp
#   ambientFront
#
# Do not assume undocumented units or scaling without verifying them.

# Current fan-control table:
luna-send -n 1 -f \
  luna://com.webos.service.fancontroller/getFanTableData \
  '{}'


###############################################################################
# 7. Fan-control API experiment
###############################################################################

# Example only.
#
# Use conservative values and monitor temperatures/RPM while testing.
# Do not disable thermal protection or fake temperature/RPM feedback.

luna-send -n 1 -f \
  luna://com.webos.service.fancontroller/setFanControlData \
  '{"fan1Volt":<TEST_VALUE>}'

# Check telemetry immediately afterwards:
luna-send -n 1 -f \
  luna://com.webos.service.fancontroller/getFanControlData \
  '{}'


###############################################################################
# 8. Live monitoring
###############################################################################

# Fan/temperature telemetry every two seconds:
#
# while true; do
#   date
#   luna-send -n 1 -f \
#     luna://com.webos.service.fancontroller/getFanControlData \
#     '{}'
#   sleep 2
# done

# Connected Bluetooth audio device every two seconds:
#
# while true; do
#   luna-send -n 1 -f \
#     luna://com.webos.service.btaudiosrc/getConnectedDevice \
#     '{}'
#   sleep 2
# done


###############################################################################
# 9. Read-only system inspection
###############################################################################

uname -a
cat /proc/cmdline
cat /proc/thermalinfo/soc_temperature
cat /proc/partitions

# Optional device-node discovery:
# ls -l /dev/video* 2>/dev/null
# ls -l /dev/pwm* 2>/dev/null
# ls -l /dev/i2c-* 2>/dev/null
#
# The presence of a device node does NOT mean it is safe to write to it.


###############################################################################
# 10. Inspect relevant LG services
###############################################################################

# Running processes:
# ps | grep -E 'fancontroller|btaudiosrc|bluetooth|audio'

# Read-only string inspection can be useful for discovering service names,
# handlers, schemas, and internal Luna calls:
#
# strings /usr/sbin/btaudiosrc | grep -i -E \
#   'connect|disconnect|stream|sound|address|device'
#
# strings /usr/sbin/fancontroller | grep -i -E \
#   'fan|temp|duty|volt|rpm|pwm'


###############################################################################
# 11. Bluetooth audio database – read only
###############################################################################

# The btaudiosrc service may maintain a persistent paired-device list:
#
# cat /var/lib/bluetooth-audio/paired_audio_device_list.json
#
# If jq is installed:
# jq . /var/lib/bluetooth-audio/paired_audio_device_list.json


###############################################################################
# 12. Optional shell helpers
###############################################################################

bt_connect() {
  luna-send -n 1 -f \
    luna://com.webos.service.btaudiosrc/connect \
    "{\"address\":\"$1\"}"
}

bt_disconnect() {
  luna-send -n 1 -f \
    luna://com.webos.service.btaudiosrc/disconnect \
    "{\"address\":\"$1\"}"
}

bt_status() {
  luna-send -n 1 -f \
    luna://com.webos.service.btaudiosrc/getConnectedDevice \
    '{}'
}

# Examples:
#
# bt_connect "$BT_HEADPHONES"
# bt_disconnect "$BT_HEADPHONES"
#
# bt_connect "$BT_SPEAKERS"
# bt_disconnect "$BT_SPEAKERS"
#
# bt_status


###############################################################################
# Home Assistant / automation notes
###############################################################################

# These APIs are enough to build simple external automation without installing
# a custom application on the projector:
#
#   Power on:
#     Wake-on-LAN or another supported power-on mechanism
#
#   Wait until projector is available:
#     Use the automation platform's existing projector/media-player state
#
#   Select Bluetooth output:
#     com.webos.service.btaudiosrc/connect
#
#   Select internal speaker:
#     settingsservice -> soundOutput = tv_speaker
#
#   Read active Bluetooth target:
#     com.webos.service.btaudiosrc/getConnectedDevice
#
#   Read thermal/fan telemetry:
#     com.webos.service.fancontroller/getFanControlData
#
# For production automation, add timeouts, availability checks, retries, and
# verification that the requested output actually became active.

