import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

Rectangle {

    property alias title: titleText.text

    id: navigationBar
    anchors.top: parent.top
    width: parent.width
    height: 44
    color: "#FFFFFF"
    layer.enabled: true
    layer.effect: DropShadow{
        horizontalOffset: 0
        verticalOffset: 5.5
        radius: 11.5
        color: "#0A000000"
    }

    Text {
        id: titleText
        anchors.centerIn: parent
        text: title === "" ? "Measure" : title
        font.pixelSize: 17
        color: "black"
    }
}
