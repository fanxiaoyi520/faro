import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12
import Http 1.0
import Api 1.0
import Modules 1.0
import "../../Util/GlobalFunc.js" as GlobalFunc
import "../../String_Zh_Cn.js" as SettingString
Popup {
    property var titleStr: SettingString.scan_select_unit
    property var list
    property var index: 0
    property int page: 0
    property var inputModelData
    signal cellClickHandle(var modelData,int index)
    onOpened: accordingIndexHandleRequest(index)
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
            anchors.bottomMargin: 25
            clip: true
            model: list
            delegate:itemDelegate
            ScrollView {
                anchors.fill: parent
                background: NoDataView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    y: 0
                    width: parent.width
                    height: parent.height
                    id: noDataView
                    textStr: qsTr(SettingString.no_datas)
                }
                visible: list && list.length > 0 ? false : true
            }
        }
        Component{
            id: itemDelegate
            Rectangle {
                height: 54
                width: parent.parent.width
                Text {
                    id: title
                    text: qsTr(modelData.unitName)
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
                MouseArea {
                    anchors.fill: parent
                    onClicked: cellClick(modelData,index)
                }
            }
        }
    }

    //MARK: Func Logic
    function accordingIndexHandleRequest(index) {
        console.log("index: " + index)
        getBuildingUnitPage()
    }

    function cellClick(modelData) {
        console.log("cell clicked: "+JSON.stringify(modelData))
        popup.close()
        cellClickHandle(modelData,index)
    }

    function getBuildingUnitPage(){
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            var response = JSON.parse(reply)
            console.log("complete building unit page data: "+reply)
            if (response.data.length <=0) return;
            var unitList = response.data
            if (unitList.length === 0) {
                hub.close()
                return
            }
            list = []
            list = unitList
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            hub.close()
        }

        http.onReplySucSignal.connect(onReply)
        http.replyFailSignal.connect(onFail)
        http.get(Api.building_unit_page,{"projectId":inputModelData.projectId,"blockId":inputModelData.id,"unitName":""})
    }
}





