import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

Popup {
    property var titleStr: "温馨提示"
    property var tipsContentStr: ""
    property bool switchvisible: false
    signal confirmAction()
    signal confirmAndSwitchAction(bool checked)
    id: popup
    y: (parent.height-188)/2
    x: (parent.width-285)/2
    width: 285
    height: 188
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
        Rectangle {
            id: bottomLine
            anchors.top: title.bottom
            anchors.topMargin: 17
            width: parent.width
            height: 1
            color: "#80EAEAEA"
        }
        Text {
            id: tipscontent
            text: qsTr(tipsContentStr)
            clip: true
            elide:  Text.ElideRight
            wrapMode: Text.WrapAnywhere
            height: switchvisible ? font.pixelSize : font.pixelSize*2+10
            width: parent.width-20-(switchvisible ? 74 : 20)
            font.pixelSize: 16
            anchors.top: bottomLine.top
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: switchvisible ? 74 : 20
            color: "#3C3C3C"
        }
        Switch {
            id: poposwitch
            anchors.verticalCenter: tipscontent.verticalCenter
            width: 42
            height: 32
            anchors.left: tipscontent.right
            anchors.leftMargin: 12
            visible: switchvisible
            onCheckedChanged: switchAction(checked)
        }
        Item {
            id: buttonsContainer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 57
            Button{
                id: cancelbtn
                anchors.left: parent.left
                anchors.leftMargin: 20
                width: (parent.width-20*3)/2
                height: 41
                text: qsTr("取消")
                highlighted: true
                background: Rectangle{
                    id: cancelbtnrect
                    color: "#F5F5F7"
                    radius: 20.5
                }
                contentItem: Text {
                    text: cancelbtn.text
                    color: "#333333"
                    anchors.centerIn: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.capitalization: Font.MixedCase
                    font.pixelSize: 15
                }
                layer.enabled: true
                layer.effect: DropShadow{
                    horizontalOffset: 0
                    verticalOffset: 12
                    radius: 20.5
                    color: "#1A1890FF"
                }
                onClicked: cancelAction()
            }

            Button{
                id: surebtn
                anchors.right: parent.right
                anchors.rightMargin: 20
                width: (parent.width-20*3)/2
                height: 41
                text: qsTr("确定")
                highlighted: true
                background: Rectangle{
                    id: surebtnrect
                    color: "#1890FF"
                    radius: 20.5
                }
                contentItem: Text {
                    text: surebtn.text
                    color: "#FFFFFF"
                    anchors.centerIn: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.capitalization: Font.MixedCase
                    font.pixelSize: 15
                }
                layer.enabled: true
                layer.effect: DropShadow{
                    horizontalOffset: 0
                    verticalOffset: 12
                    radius: 20.5
                    color: "#1A1890FF"
                }
                onClicked: sureAction(poposwitch.checked)
            }
        }
    }

    function cancelAction(){
        popup.close()
    }

    function sureAction(checked){
        popup.close()
        if (switchvisible){
            confirmAndSwitchAction(checked)
        }else{
            confirmAction()
        }
    }

    function switchAction(checked){
        console.log(checked ? "开关已打开" : "开关已关闭")
    }
}





