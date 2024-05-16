import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.5

Rectangle{

    property alias inputfield: input
    property alias leftimage: leftimage
    property alias rightimage: rightimage
    width: 320;height: 53
    color: "#FFFFFFFF"
    radius: 12
    layer.enabled: true
    anchors.horizontalCenter: parent.horizontalCenter
    layer.effect: DropShadow{
        horizontalOffset: 0
        verticalOffset: 0
        radius: 22
        color: "#0F000000"
    }

    Image {
        id: leftimage
        width: 23;height: 23
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.verticalCenter: parent.verticalCenter
    }

    Image {
        id: rightimage
        width: 23;height: 23
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        MouseArea{
            anchors.fill: parent
            onClicked: {
                input.clear()
            }
        }
    }

    TextField{
        id: input
        height: parent.height
        anchors.left: leftimage.right
        anchors.right: rightimage.left
        font.capitalization: Font.MixedCase
        font.pixelSize: 15
        background: Rectangle{
            color: "transparent"
            border.color: "transparent"
        }
    }
}
