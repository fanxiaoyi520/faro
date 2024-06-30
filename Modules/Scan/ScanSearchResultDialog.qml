import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12
import Http 1.0
import Api 1.0
import Modules 1.0
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
    onOpened: getListData()
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
            ScrollView {
                anchors.fill: parent
                background: NoDataView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    y: 0
                    width: parent.width
                    height: parent.height
                    id: noDataView
                    textStr: qsTr(Settings.no_datas)
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
                    text: getDisplayName(modelData)
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

    function getListData() {
        hub.open()
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            var response = JSON.parse(reply)
            hub.close()
            console.log("complete search fast scan room task data: "+reply)
            if (response.data.length <=0) {
                hub.close()
                return;
            }
            if(response.data.records.length === 0) {
                list = response.data.records
                hub.close()
                return
            }
            list = []
            list = response.data.records
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            hub.close()
        }

        var params = {
            "size":10000,
            "current":page
        }
        if (!GlobalFunc.isEmpty(selectPorjectData)) params["projectId"] = selectPorjectData.id
        if (!GlobalFunc.isEmpty(selectBuildingData)) params["blockId"] = selectBuildingData.id
        if (!GlobalFunc.isEmpty(selectFloorData)) params["floorId"] = selectFloorData.id
        if (!GlobalFunc.isEmpty(selectUnitData)) params["unitId"] = selectUnitData.id
        if (!GlobalFunc.isEmpty(selectRoomData)) params["roomId"] = selectRoomData.id
        console.log("search result enter params: "+JSON.stringify(params))
        http.onReplySucSignal.connect(onReply)
        http.replyFailSignal.connect(onFail)
        http.post(Api.building_roomTask_searchFastScanRoomTask,params)
    }

    function getDisplayName(modelData){
        var blockName = modelData.blockName.includes(Settings.building) ? modelData.blockName : modelData.blockName+Settings.building
        var unitName = modelData.unitName.includes(Settings.unit) ? modelData.unitName : modelData.unitName+Settings.unit
        var floorName = modelData.floorName.includes(Settings.layer) ? modelData.floorName : modelData.floorName+Settings.layer
        var roomName = modelData.roomName
        var foundjson = Settings.stageType.find(obj => {
                                                      var a = JSON.parse(obj)
                                                      return a.index === modelData.stageType-1
                                                  });
        var foundObject = JSON.parse(foundjson)
        var name = modelData.projectName+"_"+blockName+"_"+unitName+"_"+floorName+"_"+roomName+"_"+foundObject.name+"_"+Settings.room_task
        return name
    }
}

