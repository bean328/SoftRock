// Battery percentage from UPower. Turns the warning color below 20%.
import Quickshell.Services.UPower
import QtQuick

Text {
    readonly property var device: UPower.displayDevice
    // Accept either a 0 to 1 fraction or a 0 to 100 value.
    readonly property int percent: Math.round(device.percentage <= 1 ? device.percentage * 100 : device.percentage)
    readonly property bool charging: device.state === UPowerDeviceState.Charging

    text: (charging ? "Charging " : "Battery ") + percent + "%"
    color: percent < 20 && !charging ? Theme.warn : Theme.textMuted
    font.family: Theme.fontUi
    font.pixelSize: Theme.fontSizeBody
}
