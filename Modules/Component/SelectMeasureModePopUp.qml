import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

Popup {
    property var titleStr: "选择测量模式"
    property var tipsContentStr: ""
    property bool switchvisible: false
    property var list: JSON.parse(settingsManager.selectedMeasureMode)
    signal confirmAction()
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
        ListView /**PullListViewV2*/ {
            id: listView
            anchors.top: bottomLine.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: buttonsContainer.top
            clip: true
            model: list
            delegate:itemDelegate
        }
        Component{
            id: itemDelegate
            SelectMeasureModeCell{
                cellModel: modelData
            }
        }
        Item {
            id: buttonsContainer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 51

            Button{
                id: surebtn
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.right: parent.right
                anchors.rightMargin: 24
                anchors.top: parent.top
                width: (parent.width-24*2)/2
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
                onClicked: sureAction()
            }
        }
    }
    function sureAction(){
        popup.close()
    }
}





