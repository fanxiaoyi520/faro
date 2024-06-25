import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12
import "../../String_Zh_Cn.js" as SettingString
Popup {
    property var titleStr: "选择楼栋"
    property var tipsContentStr: ""
    property var list

    id: popup
    y: parent.height * 0.1
    x: parent.width * 0.1
    width: parent.width * 0.8
    height: parent.height * 0.8


    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    background: Rectangle{
        radius: 25
        color: "transparent"
    }

    contentItem:     Rectangle{
        anchors.fill: parent
        radius: 25
        color: "#FFFFFF"

        Text {
            id: title
            text: titleStr
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 17
            font.pointSize: 18
            color: "#2C2C2C"
            font.weight: Font.Bold
        }
        Image {
            id: closeimg
            source: "../../images/measure_other/measure_back.png"
            width: 17;height: 17
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: title.verticalCenter
            MouseArea{
                anchors.fill: parent
                onClicked: popup.close()
            }
        }
        Rectangle {
            id: bottomLine
            anchors.top: title.bottom
            anchors.topMargin: 17
            width: parent.width
            height: 1
            color: "#80EAEAEA"
        }
        ListView {
            id: listView
            anchors.top: bottomLine.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true
            model: list
            delegate:itemDelegate
        }
        Component{
            id: itemDelegate
            Rectangle {
                height: 54
                width: parent.parent.width
            }
        }
    }
}





