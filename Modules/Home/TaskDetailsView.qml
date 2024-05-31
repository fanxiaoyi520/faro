import QtQuick 2.0
import Modules 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Http 1.0
import Api 1.0
import Dialog 1.0
import QtGraphicalEffects 1.0
import "../../Util/GlobalFunc.js" as GlobalFunc
import "../../String_Zh_Cn.js" as SettingString
import FaroManager 1.0
import WifiHlper 1.0
Item{
    property int page: 0
    property var inputModelData
    property var roomsList:[]
    property var roomTaskVoModel
    property var list:[]
    property int currentRow: 0
    property string selectedStageName: "主体阶段（一阶段）"
    property string projectName: "Measure"
    property string imageUrl : ""
    property double imageBackHeight : parent.width * 0.6
    property double imageBackWidth : parent.width * 0.6
    property var inputCellModel

    id: selectTaskDetailsView
    Layout.fillWidth: true
    Layout.fillHeight: true
    anchors.fill: parent
    clip: true
    Toast {id: toastPopup}
    Http {id: http}
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
            getBuildingRoomListByFloorId()
        }
    }
    TipsPopUp{
        id: tipsPopUp
        tipsContentStr: qsTr("是否重新开始扫描")
        onConfirmAction: {
            var model = inputModel
            tipsSwitchPopUp.inputModel = model
            tipsSwitchPopUp.open()
        }
    }
    TipsPopUp{
        id: tipsSwitchPopUp
        tipsContentStr: qsTr("扫描后是否自动上传")
        switchvisible: true
        cancelBtnStr: qsTr("取消扫描")
        sureBtnStr: qsTr("开始扫描")
        onConfirmAndSwitchAction: startScan(checked,inputModel)
    }
    TipsPopUp{
        id: recalculatePopUp
        tipsContentStr: qsTr("执行成功")
        isVisibleCancel: false
        onConfirmAction: {

        }
    }
    MorePopUp {
        id: morePopUp
        onConfirmOptionsAction: moreCellClickAction(model)
    }
    SelectMeasureModePopUp{
        id: selectMeasureModePopUp
        stageType: roomTaskVoModel.stageType
        stationType: inputCellModel.stationType
    }
    Hub{id: hub}
    EnlargeImage{
        id: enlargeImagePopUp
    }
    FaroManager {
        id: faroManager
        Component.onCompleted: {
            if(faroManager.init()) {
                console.log("--------------初始化成功--------------")
            }
        }
    }
    BaseNavigationBar{
        id: navigationBar
        title: qsTr("任务详情")
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
                color: "#666666"
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    dialog.list = SettingString.stageType
                    dialog.open()
                }
            }
        }
        onBackAction: {
            rootStackView.pop()
            callbackOrSyncEventHandling()
        }
    }

    Text{
        id: title
        text: qsTr(projectName)
        anchors.top: navigationBar.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        font.bold: true
        font.pixelSize: 19
    }

    MHeaderListView{
        id: headerListView
        anchors.top: title.bottom
        anchors.topMargin: 17
        height: 31
        list: roomsList
        onClickSwitchAction: headerClickSwitchAction(index,model)
    }

    Canvas {
        id: lineview
        width: parent.width
        height: 1
        anchors.top: headerListView.bottom
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
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 12
        clip: true
        model: list
        delegate:itemDelegate
        header: headerDelegate
        ScrollView {
            anchors.fill: parent
            background: NoDataView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                y: 0
                width: parent.width
                height: parent.height
                id: noDataView
                textStr: qsTr("暂无数据")
            }
            visible: list && list.length > 0 && imageUrl ? false : true
        }
    }

    Component{
        id: headerDelegate
        TaskDetailsListHeaderView{
            imgUrl: imageUrl
        }
    }

    Component {
        id: itemDelegate
        TaskDetailsCell{
            model: modelData
        }
    }

    onInputModelDataChanged: {
        console.log("task details input model data: "+JSON.stringify(inputModelData))
        var selectedItem = JSON.parse(settingsManager.getValue(settingsManager.selectedItem))
        projectName = selectedItem.projectName
        hub.open()
        getBuildingRoomListByFloorId()
    }

    //MARK: logic
    function headerClickSwitchAction(index,model){
        console.log("selected header index and model data: "+index,JSON.stringify(model))
        getBuildingRoomTaskAndGetRoomTaskInfo(model)
    }

    function enlargeImageAction(inputImageUrl){
        console.log("need enlarge image: "+ inputImageUrl)
        enlargeImagePopUp.imgUrl = imageUrl
        enlargeImagePopUp.open()
    }

    function scanAction(scanModel){
        inputCellModel = scanModel
        tipsPopUp.inputModel = scanModel
        tipsPopUp.open()
    }

    function moreAction(){
        morePopUp.open()
    }

    function moreCellClickAction(model){
        morePopUp.close()
        if (model.index === 0) {
            console.log("start recalculate")
            recalculatePopUp.open()
            return
        }
        if (model.index === 1) {
            console.log("jump upload file")
            return
        }
        if (model.index === 2) {
            selectMeasureModePopUp.open()
            return
        }
    }

    function startScan(checked,inoutModel){
        console.log("is auto upload file: "+checked)
        console.log("start scan ...")
        var selectedMeasureData = JSON.parse(settingsManager.getValue(settingsManager.selectedMeasureData))
        var scanParams = {
            "activeColoring": selectedMeasureData ? selectedMeasureData.activeColoring : "0",
            "map_mode": selectedMeasureData ? selectedMeasureData.map_mode : "4",
            "scanningMode": selectedMeasureData ? selectedMeasureData.scanningMode : "4",
            "masonry_mode": selectedMeasureData ? selectedMeasureData.masonry_mode : 0,
            "xy_crop_dist": selectedMeasureData ? selectedMeasureData.xy_crop_dist : 6,
            "z_crop_dist": selectedMeasureData ? selectedMeasureData.z_crop_dist : 3,

            "stationId":inoutModel.stationId,
            "taskNo":inoutModel.stationNo,
            "stationType":inoutModel.stationType,
            "isAutoUpload":checked,
            "projectName":roomTaskVoModel.projectName,
            "blockName":roomTaskVoModel.blockName,
            "unitName":roomTaskVoModel.unitName,
            "floorName":roomTaskVoModel.floorName,
            "roomName":roomTaskVoModel.roomName,
            "stageType":roomTaskVoModel.stageType,
            "filePath":"",
            "roomId":inputModelData.id,
        }
        console.log("input scanning parameters: "+JSON.stringify(scanParams))

        var wifi = settingsManager.getValue(settingsManager.currentDevice)
        if (!wifi) {
            var myWifiObject = {
                wifiName : "LLS082118788",
                wifiPass : "0123456789"
            }
            settingsManager.setValue(settingsManager.currentDevice,JSON.stringify(myWifiObject))
            console.log("wifi info =" + wifi)
            return
        }
        console.log("wifi info =" + wifi)
        function connectResult(isSuc){
            wifiHelper.connectToWiFiResult.disconnect(connectResult)
            if (isSuc){
                enteringScanningPhase(scanParams)
            } else {
                console.log("wifi connect fail ...")
            }
        }
        wifiHelper.onConnectToWiFiResult.connect(connectResult)
        wifiHelper.connectToWiFi(JSON.parse(wifi).wifiName,JSON.parse(wifi).wifiPass)
    }

    function enteringScanningPhase(scanParams){
        function scanComplete(){
            faroManager.onScanComplete.disconnect(scanComplete)
            faroManager.onScanProgress.disconnect(scanProgress)
            console.log("received scan complete info ...")
            faroManager.stopScan()
            faroManager.disconnect()

            function wifiDisConnect(result){
                wifiHelper.onDisConnectWifiResult.disconnect(wifiDisConnect)
                if (result){
                    console.log("wifi disconnect success")
                } else {
                    console.log("wifi disconnect fail")
                }
            }
            wifiHelper.onDisConnectWifiResult.connect(wifiDisConnect)
            wifiHelper.disConnectWifi()
        }

        function scanProgress(percent){
            console.log("scan progress percent: "+percent)
        }

        faroManager.onScanComplete.connect(scanComplete)
        faroManager.onScanProgress.connect(scanProgress)
        faroManager.startScan(scanParams)
    }

    //MARK: network
    function getBuildingRoomListByFloorId(floorId){
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            hub.close()
            var response = JSON.parse(reply)
            console.log("complete building room listByFloorId data: "+reply)
            if (response.data.length <=0) return;
            roomsList = response.data
            getBuildingRoomTaskAndGetRoomTaskInfo(roomsList[0])
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            hub.close()
        }

        http.onReplySucSignal.connect(onReply)
        http.replyFailSignal.connect(onFail)
        http.get(Api.building_room_listByFloorId,{"floorId":inputModelData.id})
    }

    function getBuildingRoomTaskAndGetRoomTaskInfo(roomModel){
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            console.log("complete building room task and get roomTaskInfo: "+reply)
            var response = JSON.parse(reply)
            roomTaskVoModel = response.data
            if (!response.data || response.data.stations.length <=0) {
                list = []
                imageUrl = ""
                return;
            }
            list = response.data.stations
            admin_sys_file_listFileByFileIds([response.data.houseTypeDrawing])
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            hub.close()
        }

        http.onReplySucSignal.connect(onReply)
        http.replyFailSignal.connect(onFail)
        http.get(Api.building_roomTask_getRoomTaskInfo,
                 {"roomId":roomModel.id,"stageType":currentRow+1})
    }

    function admin_sys_file_listFileByFileIds(urlStrs){
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            console.log("complete admin sys file listFileByFileIds: "+reply)
            var response = JSON.parse(reply)
            imageUrl = "http://"+response.data[0].bucketName+"."+response.data[0].fileUri+"/"+response.data[0].fileName
            console.log("imageUrl: "+imageUrl)
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            hub.close()
        }
        http.onReplySucSignal.connect(onReply)
        http.replyFailSignal.connect(onFail)
        http.post(Api.admin_sys_file_listFileByFileIds,
                  {"integers":urlStrs})
    }
}
