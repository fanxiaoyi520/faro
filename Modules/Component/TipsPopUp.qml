import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

Popup {
    property var inputModel
    property var titleStr: "温馨提示"
    property var tipsContentStr: ""
    property var cancelBtnStr: "取消"
    property var sureBtnStr: "确定"
    property bool switchvisible: false
    property bool isVisibleCancel: true
    signal confirmAction(var inputModel)
    signal confirmAndSwitchAction(bool checked,var inputModel)
    id: popup
    width: parent.width
    height: parent.height
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    background: Rectangle{
        radius: 25
        color: "transparent"
    }
    Rectangle{
        id:rect_root
        width: (parent.width / 3 < 300) ? 300 : parent.width / 3
        height: (parent.height / 2 < 240) ? 240 : parent.height * 0.3/*parent.height / 2*/
        radius: 25
        color: "#FFFFFF"
        anchors.centerIn: parent
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
        Rectangle{
            width: parent.width
            height: rect_root.height - title.height - 1 - buttonsContainer.height
            anchors{
                  top: bottomLine.bottom
                  left: parent.left
                  right: parent.right
                  bottom: buttonsContainer.top
                  margins: 8
              }

            Text {
                id: tipscontent
                text: qsTr(tipsContentStr)
                clip: true
                elide:  Text.ElideRight
                wrapMode: Text.WrapAnywhere
                height: parent.height
                width: parent.width/*switchvisible ? parent.width - 74 : parent.width*/
                font.pixelSize: 16
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.centerIn: parent.Center
                color: "#3C3C3C"
            }

            /**
            Switch {
                id: poposwitch
                anchors.verticalCenter: tipscontent.verticalCenter
                width: 42
                height: 32
                anchors.left: tipscontent.right
                anchors.leftMargin: 8
                visible: switchvisible
                onCheckedChanged: switchAction(checked)
            }
            */
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
                text: qsTr(cancelBtnStr)
                highlighted: true
                visible: isVisibleCancel
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
//                layer.enabled: true
//                layer.effect: DropShadow{
//                    horizontalOffset: 0
//                    verticalOffset: 12
//                    radius: 20.5
//                    color: "#1A1890FF"
//                }
                onClicked: cancelAction()
            }

            Button{
                id: surebtn
                anchors.right: parent.right
                anchors.rightMargin: 20
                width: isVisibleCancel ? (parent.width-20*3)/2 : (parent.width-20*2)
                height: 41
                text: qsTr(sureBtnStr)
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
//                layer.enabled: true
//                layer.effect: DropShadow{
//                    horizontalOffset: 0
//                    verticalOffset: 12
//                    radius: 20.5
//                    color: "#1A1890FF"
//                }
                onClicked: sureAction(true/*poposwitch.checked*/,inputModel)
            }
        }
    }

    function cancelAction(){
        popup.close()
    }

    function sureAction(checked,inputModel){
        popup.close()
        if (switchvisible){
            confirmAndSwitchAction(checked,inputModel)
        }else{
            confirmAction(inputModel)
        }
    }

    function switchAction(checked){
        console.log(checked ? "开关已打开" : "开关已关闭")
    }
}





