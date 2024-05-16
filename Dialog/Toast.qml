import QtQuick 2.0
import QtQuick.Controls 2.12

Rectangle  {
    id: root

    property var text: ""
    color: "transparent"
    y:  parent.height - 100
    z: 100
    anchors.horizontalCenter: parent.horizontalCenter
    width:message.width + 20
    height: message.height + 10
    radius: height / 2
    onTextChanged: {
        if (root.text.length > 0) {
            timer.start();
            popup.open();
        }
    }

    Timer {
        id: timer
        interval: 2000
        repeat: false
        onTriggered: popup.close()
    }

    Popup {
        id: popup
        modal: false
        focus: true
        width: root.width
        height: root.height
        background: Rectangle{
            radius: 25
            color: "#CC000000"
        }

        Text{
            id:message
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14
            text: root.text
            color: "#FFFFFF"
        }

        onClosed: {
            root.text = ""
            timer.stop();
        }
    }
}
