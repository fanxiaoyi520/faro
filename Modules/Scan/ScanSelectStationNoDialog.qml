import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12
import Http 1.0
import Api 1.0
import "../../String_Zh_Cn.js" as Settings
import "../../Util/GlobalFunc.js" as GlobalFunc

Popup {
    property var list: []
    property int currentIndex: 0
    property var titleStr: Settings.search_result

    property var page: 0
    property var selectPorjectData
    property var selectBuildingData
    property var selectUnitData
    property var selectFloorData
    property var selectRoomData

    signal selectSearchResult(var model)
    id: popup
    y: parent.height - popup.height
    width: parent.width
    height: 300
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    background: Rectangle{
        radius: 25
        color: "#FFFFFF"
        Rectangle {
            id: coverRect
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 25
            color: "#FFFFFF"
            border.color: "transparent"
        }
    }
    padding: 0
    contentItem:Rectangle{
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
            id: closeImageBtn
            source: "../../images/home_page_slices/home_more_close@2x.png"
            width: 17;height: 17
            anchors.right: parent.right
            anchors.rightMargin: 30
            anchors.verticalCenter: title.verticalCenter
            MouseArea{
                anchors.fill: parent
                onClicked: closeAction()
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
            anchors.bottomMargin: 25
            clip: true
            model: list
            delegate:itemDelegate
        }
        Component{
            id: itemDelegate
            Rectangle {
                height: 54
                width: parent.parent.width
                Text {
                    id: title
                    text: Settings.station_no+modelData.stationNo
                    anchors.left: parent.left
                    anchors.leftMargin: 25
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 15
                    color: "#3C3C3C"
                }
                Canvas {
                    id: lineview
                    width: parent.width
                    height: 1
                    y:53
                    property color lineColor: "#80EAEAEA"
                    property int lineWidth: 1

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.strokeStyle = lineColor;
                        ctx.lineWidth = lineWidth;
                        ctx.beginPath();
                        ctx.moveTo(0, 1);
                        ctx.lineTo(parent.width, 1);
                        ctx.stroke();
                    }
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        currentIndex = index;
                        popup.close()
                        selectSearchResult(modelData)
                    }
                }
            }
        }
    }

    function closeAction(){
        popup.close()
    }
}

