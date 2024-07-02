import QtQuick 2.0
import Modules 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Http 1.0
import Api 1.0
import Dialog 1.0
import QtGraphicalEffects 1.0
import QtEnumClass 1.0
import FileManager 1.0
import WifiHlper 1.0

import "../../Util/GlobalFunc.js" as GlobalFunc
import "../../String_Zh_Cn.js" as SettingString

ScrollView{
    property int page: 0
    property var inputModelData
    property var unitList:[]
    property var list:[]
    property int currentRow: 0
    property string selectedStageName: SettingString.main_stage_one
    property var loginMode
    property var majorTypeMode
    property int headerSelectedIndex: 0
    signal buildCallbackOrSyncEventHandling()
    onBuildCallbackOrSyncEventHandling: {
        kbuildCallbackOrSyncEventHandling()
    }
    id: selectFloorView
    Layout.fillWidth: true
    Layout.fillHeight: true
    anchors.fill: parent
    clip: true
    Toast {id: toastPopup}
    Http {id: http}
    FileManager{id: fileManager}
    WifiHelper{id: wifiHelper}
    Dialog{
        id: dialog
        titleStr: qsTr("选择阶段")
        onConfirmOptionsAction: {
            console.log("dialog selected data: " + JSON.stringify(model))
            settingsManager.setValue(settingsManager.selectedStageType,JSON.stringify(model))
            currentRow = model.index
            selectedStageName = model.name
            hub.open()
            getBuildingUnitPage()
        }
    }
    Hub{id: hub}
    Loader {id: selectTaskDetailsView}
    background: Rectangle{
        color: "#FFFFFF"
    }

    TipsPopUp {
        id: tipsPopUp
        tipsContentStr: SettingString.quit_measure_task
        onConfirmAction: majorModeBackAction()
    }

    BaseNavigationBar{
        id: navigationBar
        title: qsTr(inputModelData ? inputModelData.blockName : "选择楼层")
        Rectangle{
            id: stageTypeBtn
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 12
            height: 34
            width: parent.width * 0.25
            radius: 17
            color: "#F7F7F7"
            Text{
                id: subtext
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr(selectedStageName)
                color: !(loginMode === QtEnumClass.Major && majorTypeMode === QtEnumClass.Measure)? "#666666" : "#999999"
            }
            MouseArea{
                anchors.fill: parent
                enabled: !(loginMode === QtEnumClass.Major && majorTypeMode === QtEnumClass.Measure)
                onClicked: {
                    dialog.list = SettingString.stageType
                    dialog.currentIndex = currentRow
                    dialog.open()
                }
            }
        }
        onBackAction: {
            if (loginMode === QtEnumClass.Major && majorTypeMode === QtEnumClass.Measure) {
                tipsPopUp.open()
            } else {
                rootStackView.pop()
                buildCallbackOrSyncEventHandling()
            }
        }
    }

    MHeaderListButtonGroup{
        id: headerListButtonGroup
        anchors.top: navigationBar.bottom
        anchors.topMargin: 17
        height: 31
        list: unitList
        selectedButtonIndex: headerSelectedIndex
        onSelectedButtonAction: headerFilterData(index,itemData)
    }

    Canvas {
        id: lineview
        width: parent.width
        height: 1
        anchors.top: headerListButtonGroup.bottom
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

    ListView /**PullListViewV2*/ {
        id: listView
        anchors.top: lineview.bottom
        anchors.topMargin: 17.5
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 12
        clip: true
        model: list
        delegate: itemDelegate
    }

    Component {
        id: itemDelegate
        Rectangle {
            width: listView.width
            height: 54
            Rectangle {
                color: "#FFFFFF"
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                layer.enabled: true
                radius: 8
                layer.effect: DropShadow{
                    horizontalOffset: 0
                    verticalOffset: 5.5
                    radius: 11.5
                    color: "#10000000"
                }
            }
            Rectangle {
                color: "#FFFFFF"
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                radius: 8
                Text {
                    id: name
                    text: qsTr("楼层: ")+qsTr(modelData.floorName)+qsTr("层")

                    anchors.verticalCenter: parent.verticalCenter
                    x:20
                }
                Text {
                    id: contentname
                    text: qsTr("待测户数")
                    anchors.right: numname.left
                    anchors.rightMargin: 1
                    anchors.top: parent.top
                    anchors.topMargin: 13.5
                    color: "#000000"
                    visible: show()
                }
                Text {
                    id: numname
                    text: "("+modelData.finishRoomCount + "/" + modelData.totalRoomCount+")"
                    anchors.right: arrowimg.left
                    anchors.rightMargin: 10
                    anchors.top: parent.top
                    anchors.topMargin: 13.5
                    color: "#999999"
                    visible: show()
                }
                Rectangle{
                    id: progress
                    height: 5
                    color: "#F5F5F5"
                    radius: 2.5
                    visible: show()
                    anchors {
                        left: contentname.left
                        right: numname.right
                        top: contentname.bottom
                        topMargin: 4
                    }
                    Rectangle{
                        id: currentprogress
                        height: 5
                        width: parent.width * (modelData.finishRoomCount / modelData.totalRoomCount)
                        color: GlobalFunc.getStageTypeColor(currentRow+1)
                        radius: 2.5
                        visible: show()
                    }
                }
                Image {
                    id: arrowimg
                    source: "../../images/home_page_slices/select_building_arrow@2x.png"
                    width: 7
                    height: 12.5
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                }
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    jumpToTaskDetails(index,modelData)
                }
            }
        }
    }

    onInputModelDataChanged: {
        loginMode = Number(settingsManager.getValue(settingsManager.LoginMode))
        majorTypeMode = Number(settingsManager.getValue(settingsManager.MajorTypeMode))
        headerSelectedIndex = 0
        headerListButtonGroup.selectedButtonIndex = headerSelectedIndex
        if (loginMode === QtEnumClass.Major && majorTypeMode === QtEnumClass.Measure) {
            var datasjson = settingsManager.getValue(settingsManager.blockOffilneData)
            if (GlobalFunc.isJson(datasjson) && Array.isArray(JSON.parse(datasjson))) {
                console.log("datasjson: "+datasjson)
                var datas = JSON.parse(datasjson)
                const found = datas.find(obj => JSON.parse(obj).blockId === inputModelData.id);
                console.log("found: "+JSON.stringify(found))
                unitList = []
                unitList = JSON.parse(found).units
                console.log("unitList: "+JSON.stringify(unitList))
                var unit = unitList[0]
                list = []
                list = unit.floors
            }
            return
        }
        hub.open()
        getBuildingUnitPage()
    }

    //MARK: logic
    function show() {
        return !(loginMode === QtEnumClass.Major && majorTypeMode === QtEnumClass.Measure   )
    }

    function majorModeBackAction() {
        settingsManager.setValue(settingsManager.blockOffilneData,[])
        fileManager.removeArbitrarilyPath("C:\\faromajorpics")
        var wifi = settingsManager.getValue(settingsManager.currentDevice)
        if(GlobalFunc.isJson(wifi)) {
            var contentName = JSON.parse(wifi).wifiName
            var currentWifiName = wifiHelper.queryInterfaceName()
            if (currentWifiName === contentName){
                wifiHelper.disConnectWifi()
            }
        }
        rootStackView.pop()
        buildCallbackOrSyncEventHandling()
    }

    function headerFilterData(index,itemData){
        console.log("selected header index and item data: "+index,itemData)
        headerSelectedIndex = index
        if (loginMode === QtEnumClass.Major && majorTypeMode === QtEnumClass.Measure) {
            var unit = unitList[index]
            list = unit.floors
            return
        }

        accordingToUnitIdSearchFloor(index)
    }

    function floorCallbackOrSyncEventHandling(){
        console.log("signal common ....")
        var selectedStageType = JSON.parse(settingsManager.getValue(settingsManager.selectedStageType))
        selectFloorView.currentRow = selectedStageType.index
        selectFloorView.selectedStageName = selectedStageType.name
    }

    //MARK: jump
    //跳转到任务详情
    function jumpToTaskDetails(index,modelData){
        console.log("incoming data index: ("+index+") and model: "+JSON.stringify(modelData))
        selectTaskDetailsView.source = "TaskDetailsView.qml"
        selectTaskDetailsView.item.selectHeaderIndex = 0
        selectTaskDetailsView.item.inputModelData = modelData
        var selectedStageType = JSON.parse(settingsManager.getValue(settingsManager.selectedStageType))
        selectTaskDetailsView.item.currentRow = selectedStageType.index === undefined ? 0 : selectedStageType.index
        selectTaskDetailsView.item.selectedStageName = selectedStageType.name === undefined ? "主体阶段(一阶段)" : selectedStageType.name
        rootStackView.push(selectTaskDetailsView)
    }

    //MARK: network
    function getBuildingUnitPage(){
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            var response = JSON.parse(reply)
            console.log("complete building unit page data: "+reply)
            if (response.data.length <=0) return;
            unitList = response.data
            if (unitList.length === 0) {
                hub.close()
                return
            }
            accordingToUnitIdSearchFloor(0)
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

    function accordingToUnitIdSearchFloor(index){
        var unit = unitList[index]
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            console.log("complete building floor page data: "+reply)
            var response = JSON.parse(reply)
            assemblySelectedProjectData(index,response.data.records)
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            hub.close()
        }

        http.onReplySucSignal.connect(onReply)
        http.replyFailSignal.connect(onFail)
        http.post(Api.building_floor_page,
                  {"current":1,"size":2000,"unitId":unit.id,"projectId":inputModelData.projectId,"blockId":inputModelData.id,"floorName":""})
    }

    function assemblySelectedProjectData(index,dataList){
        var unit = unitList[index]
        var floorIds = dataList.map(item=>{
                                        return item.id
                                    })
        console.log("input params floorIds: " + floorIds)
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            hub.close()
            console.log("complete building room countFloorRoom data: "+reply)
            var response = JSON.parse(reply)
            var endlist = dataList
            response.data.map(item => {
                                  endlist = dataList.map(subItem => {
                                                             if (subItem.id === item.floorId){
                                                                 subItem.finishRoomCount = item.finishRoomCount
                                                                 subItem.totalRoomCount = item.totalRoomCount
                                                                 subItem.status = item.status
                                                             }
                                                             return subItem
                                                         })
                              })
            list = endlist
            console.log("complete floor data: "+JSON.stringify(list))
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            hub.close()
        }

        http.onReplySucSignal.connect(onReply)
        http.replyFailSignal.connect(onFail)
        http.post(Api.building_room_countFloorRoom,
                  {"floorIds":floorIds,"stageType":currentRow+1,"unitId":unit.id})
    }
}
