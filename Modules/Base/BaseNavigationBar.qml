import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

Rectangle {

    property alias title: titleText.text
    property bool isVisibleBackBtn: true
    signal backAction()

    id: navigationBar
    anchors.top: parent.top
    width: parent.width
    height: 44
    z:1
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

    Item {
        id: backbutton
        width: image.width + text.width + spacing
        height: 44
        property int spacing: 10
        anchors.left: parent.left
        anchors.leftMargin: spacing * 2
        visible: isVisibleBackBtn
        Image {
            id: image
            source: "../../images/measure_other/measure_back.png"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 15;height: 15
        }

        Text {
            id: text
            text: qsTr("返回")
            anchors.left: image.right
            anchors.leftMargin: spacing
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: 14
        }

        MouseArea {
            anchors.fill: parent
            onClicked: backAction()//searchview.parent.parent.pop()
        }
    }
}
