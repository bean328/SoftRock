// Clock that wakes once a minute, not once a second.
import Quickshell
import QtQuick

Text {
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    text: Qt.formatDateTime(clock.date, "ddd d MMM   HH:mm")
    color: Theme.text
    font.family: Theme.fontUi
    font.pixelSize: Theme.fontSizeBody
    font.weight: Font.DemiBold
}
