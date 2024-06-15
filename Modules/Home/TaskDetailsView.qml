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
    property string selectedStageName: SettingString.main_stage_one
    property string projectName: "Measure"
    property string imageUrl : ""
    property double imageBackHeight : parent.width * 0.6
    property double imageBackWidth : parent.width * 0.6
    property var inputCellModel
    property string room_id
    property int selectHeaderIndex: 0
    signal callbackOrSyncEventHandling()
    id: selectTaskDetailsView
    Layout.fillWidth: true
    Layout.fillHeight: true
    anchors.fill: parent
    clip: true
    onCallbackOrSyncEventHandling: {
        floorCallbackOrSyncEventHandling()
    }
    Toast {id: toastPopup}
    Http {id: http}
    WifiHelper{id: wifiHelper}
    Loader{ id : userInfoLoader}
    Dialog{
        id: dialog
        titleStr: qsTr(SettingString.selection_stage)
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
        tipsContentStr: qsTr(SettingString.is_restart_scan)
        onConfirmAction: {
            var model = inputModel
            tipsSwitchPopUp.inputModel = model
            tipsSwitchPopUp.open()
        }
    }
    TipsPopUp{
        id: tipsSwitchPopUp
        tipsContentStr: qsTr(SettingString.is_start_scan)
        switchvisible: true
        cancelBtnStr: qsTr(SettingString.cancel_scan)
        sureBtnStr: qsTr(SettingString.start_scan)
        onConfirmAndSwitchAction: startScan(checked,inputModel)
    }
    TipsPopUp{
        id: nonerworkPopUp
        tipsContentStr: qsTr(SettingString.unable_obtain_device_WiFi)
        isVisibleCancel: false
        onConfirmAction: {}
    }
    ScanningFaroPop{
        id: scanningFaroPop
        lottieType: 0
    }
    ScanningFaroPop{
        id: recalculatePopUp
        lottieType: 0
    }
    MorePopUp {
        id: morePopUp
        onConfirmOptionsAction: moreCellClickAction(model)
    }
    SelectMeasureModePopUp{
        id: selectMeasureModePopUp
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
        title: qsTr(SettingString.tasks_details)
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
                textStr: qsTr(SettingString.no_datas)
            }
            visible: list && list.length > 0 && imageUrl ? false : true
        }
    }

    Component{
        id: headerDelegate
        TaskDetailsListHeaderView{
            imgUrl: imageUrl
            model: roomTaskVoModel
        }
    }

    Component {
        id: itemDelegate
        TaskDetailsCell{
            model: modelData
            cellroom_id: room_id
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
        selectHeaderIndex = index
        room_id = model.id
        hub.open()
        getBuildingRoomTaskAndGetRoomTaskInfo(model)
    }

    function enlargeImageAction(inputImageUrl){
        console.log("need enlarge image: "+ inputImageUrl)
        enlargeImagePopUp.imgUrl = imageUrl
        enlargeImagePopUp.model = roomTaskVoModel
        enlargeImagePopUp.open()
    }

    ///扫描点击事件
    function scanAction(scanModel){
        inputCellModel = scanModel

        if (inputCellModel.calculationStatus === 1) {
            nonerworkPopUp.tipsContentStr = qsTr(SettingString.station_being_calculated)
            nonerworkPopUp.open()
            return
        }

        if (inputCellModel.stationTaskNo !== null
                || inputCellModel.stationTaskNo !== ""
                || inputCellModel.stationTaskNo !== undefined){
            var model = scanModel
            tipsSwitchPopUp.inputModel = model
            tipsSwitchPopUp.open()
            return
        }

        tipsPopUp.inputModel = scanModel
        tipsPopUp.open()
    }

    function moreAction(scanModel){
        morePopUp.open()
        inputCellModel = scanModel
    }

    function moreCellClickAction(model){
        morePopUp.close()
        if (model.index === 0) {
            console.log("start recalculate")
            if (inputCellModel.calculationStatus === 1) {
                nonerworkPopUp.tipsContentStr = qsTr(SettingString.station_being_calculated)
                nonerworkPopUp.open()
                return
            }

            recalculatePopUp.tipsconnect = SettingString.recalculating
            recalculatePopUp.title = SettingString.recalculate
            recalculatePopUp.lottieType = 0
            recalculatePopUp.open()
            recalculate()
            return
        }
        if (model.index === 1) {
            console.log("jump upload file")
            jumpToUserInfo()
            return
        }
        if (model.index === 2) {
            selectMeasureModePopUp.stageType = roomTaskVoModel.stageType
            selectMeasureModePopUp.stationType = inputCellModel.stationType
            selectMeasureModePopUp.open()
            return
        }
    }

    function jumpToUserInfo(){
        userInfoLoader.source = "../Mine/UploadPage.qml"
        userInfoLoader.item.pushStackSource = "home"
        rootStackView.push(userInfoLoader)
    }

    ///重新计算
    function recalculate(){
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            console.log("complete building roomTaskExecute return: "+reply)
            var response = JSON.parse(reply)
            recalculatePopUp.close()
            nonerworkPopUp.tipsContentStr = qsTr(SettingString.execution_successful)
            nonerworkPopUp.open()
            getBuildingRoomListByFloorId()
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            recalculatePopUp.close()
            nonerworkPopUp.tipsContentStr = qsTr(SettingString.execution_fail)
            nonerworkPopUp.open()
        }

        http.onReplySucSignal.connect(onReply)
        http.replyFailSignal.connect(onFail)
        console.log("taskNo: "+JSON.stringify(inputCellModel.stationTaskNo))
        http.post(Api.building_roomTaskExecute_rerun,
                  {"taskNo":inputCellModel.stationTaskNo})
    }

    function startScan(checked,inoutModel){
        console.log("is auto upload file: "+checked)
        console.log("start scan ...")

        var selectedMeasureData = JSON.parse(settingsManager.getValue(settingsManager.selectedMeasureData))
        var scanParams = {
            "activeColoring": selectedMeasureData ? selectedMeasureData.activeColoring : "0",
            "map_mode": selectedMeasureData ? selectedMeasureData.map_mode : "4",
            "scanningMode": selectedMeasureData ? selectedMeasureData.scanningMode : "1/20",
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
            "roomId":room_id,
            "stationTaskNo": inputCellModel.stationTaskNo
        }

        console.log("input scanning parameters: "+JSON.stringify(scanParams))
        console.log("~inoutModel: "+JSON.stringify(inoutModel))
        console.log("~selectedMeasureData: "+JSON.stringify(selectedMeasureData))
        console.log("~roomTaskVoModel: "+JSON.stringify(roomTaskVoModel))
        console.log("~inputCellModel: "+JSON.stringify(inputCellModel))
        wifiConectHandle(scanParams,checked)
    }

    function wifiConectHandle(scanParams,checked){
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
            //var currentWifiName = wifiHelper.queryInterfaceName()
            //console.log("current Wifi Name: " + currentWifiName)
            if (isSuc/* && currentWifiName === JSON.parse(wifi).wifiName*/){
                console.log("wifi connect suc ...")
                enteringScanningPhase(scanParams,checked)
            } else {
                console.log("wifi connect fail ...")
                nonerworkPopUp.open()
            }
        }
        wifiHelper.onConnectToWiFiResult.connect(connectResult)
        wifiHelper.connectToWiFi(JSON.parse(wifi).wifiName,JSON.parse(wifi).wifiPass)
    }

    function enteringScanningPhase(scanParams,checked){
        ///扫描完成回调
        function scanComplete(filePath){
            faroManager.onScanComplete.disconnect(scanComplete)
            faroManager.onScanProgress.disconnect(scanProgress)
            scanCompleteDataHandle(scanParams,filePath)
            scanningFaroPop.tipsconnect = qsTr(SettingString.scanning_in_progress)+"(" + "100" + "%)"
            scanningFaroPop.close()
            /**
            if (!checked){
                scanningFaroPop.tipsconnect = qsTr(SettingString.scanning_in_progress)+"(" + "100" + "%)"
                scanningFaroPop.close()
            } else {
                scanningFaroPop.tipsconnect = qsTr(SettingString.uploading_pointcloud_file)
                scanningFaroPop.lottieType = 1
            }
            */

            faroManager.stopScan()
            faroManager.disconnect()
            taskDetialViewMonitorNetworkChanges()
            function wifiDisConnect(result){
                wifiHelper.onDisConnectWifiResult.disconnect(wifiDisConnect)
                nonerworkPopUp.tipsContentStr = qsTr(SettingString.file_sync_suc)
                nonerworkPopUp.open()
                /**
                if (!checked){
                    nonerworkPopUp.tipsContentStr = qsTr(SettingString.file_sync_suc)
                    nonerworkPopUp.open()
                }
                if (result){
                    console.log("wifi disconnect success")
                    if (checked) uploadFile(filePath)
                } else {
                    console.log("wifi disconnect fail")
                }
                */
            }
            wifiHelper.onDisConnectWifiResult.connect(wifiDisConnect)
            wifiHelper.disConnectWifi()
        }

        ///扫描进度
        function scanProgress(percent){
            console.log("scan progress percent: "+percent)
            scanningFaroPop.tipsconnect = qsTr(SettingString.scanning_in_progress)+"(" + percent + "%)"
        }

        ///扫描异常
        function scanAbnormal(scanStatus){
            scanningFaroPop.close()
            nonerworkPopUp.tipsContentStr = qsTr(SettingString.device_conncet_fail_tips)
            nonerworkPopUp.open()
        }

        faroManager.onScanComplete.connect(scanComplete)
        faroManager.onScanProgress.connect(scanProgress)
        faroManager.scanAbnormal.connect(scanAbnormal)
        var connectResult = faroManager.connect()
        console.log("connect result: "+connectResult)
        if (connectResult !== 1) {
            nonerworkPopUp.tipsContentStr = qsTr(SettingString.device_conncet_fail_tips)
            nonerworkPopUp.open()
        } else {
            scanningFaroPop.tipsconnect = SettingString.starting_connection_to_machine
            scanningFaroPop.title = SettingString.scan_station_id+inputCellModel.stationNo
            scanningFaroPop.lottieType = 0
            scanningFaroPop.open()
            faroManager.startScan(JSON.stringify(scanParams))
        }
    }

    function taskDetialViewMonitorNetworkChanges(){
        faroManager.monitorNetworkChanges()
        function networkChangesComplete(isOnline){
            console.log("network changes result: "+isOnline)
            faroManager.onMonitorNetworkChangesComplete.disconnect(networkChangesComplete)
            getBuildingRoomListByFloorId()
        }
        faroManager.onMonitorNetworkChangesComplete.connect(networkChangesComplete)
    }

    function scanCompleteDataHandle(scanParams,filePath){
        console.log("scan params: "+scanParams+" file path: "+filePath)
        scanParams.filePath = filePath
        var newscanParams = scanParams
        console.log("new scan params: "+JSON.stringify(scanParams))
        var filejson = settingsManager.getValue(settingsManager.fileInfoData)
        console.log("get file json data: "+filejson)
        if (!filejson || filejson.length === 0) {
            var filedatas = []
            filedatas.push(JSON.stringify(scanParams))
            console.log("new data: "+filejson)
            console.log("new data: "+JSON.stringify(scanParams))
            settingsManager.setValue(settingsManager.fileInfoData,JSON.stringify(filedatas))
        } else {
            var datas = JSON.parse(filejson)
            if (Array.isArray(datas)){
                let index = datas.findIndex(value => {
                                                var iscon = JSON.parse(value).stationId === scanParams.stationId
                                                && JSON.parse(value).roomId === scanParams.roomId
                                                && JSON.parse(value).stageType === scanParams.stageType
                                                return iscon
                                            });
                if (index !== -1) {
                    datas[index] = JSON.stringify(scanParams);
                } else {
                    datas.push(JSON.stringify(scanParams))
                }
                console.log("scan params and datas: "+JSON.stringify(datas))
                settingsManager.setValue(settingsManager.fileInfoData,JSON.stringify(datas))
            } else {
                var nulldatas = []
                nulldatas.push(JSON.stringify(scanParams))
                settingsManager.setValue(settingsManager.fileInfoData,JSON.stringify(nulldatas))
            }
        }
        var newfilejson = settingsManager.getValue(settingsManager.fileInfoData)
        console.log("new data: "+newfilejson)
    }

    //MARK: network
    function uploadFile(filePath){
        function onReply(reply){
            faroManager.uploadFileSucResult.disconnect(onReply)
            if (GlobalFunc.isJson(reply)) {
                var response = JSON.parse(reply)
                console.log("upload file result data: "+reply)
                performCalculation(JSON.stringify(response.data),filePath)
                scanningFaroPop.close()
                nonerworkPopUp.tipsContentStr = qsTr(SettingString.upload_file_suc)
                nonerworkPopUp.open()
                deleSavedFile(filePath)
            } else {
                nonerworkPopUp.tipsContentStr = qsTr(SettingString.upload_file_fial)
                nonerworkPopUp.open()
            }
        }

        function onFail(reply,code){
            console.log(reply,code)
            faroManager.uploadFileFailResult.disconnect(onFail)
            scanningFaroPop.close()
            nonerworkPopUp.tipsContentStr = qsTr(SettingString.upload_file_fial)
            nonerworkPopUp.open()
        }

        faroManager.uploadFileSucResult.connect(onReply)
        faroManager.uploadFileFailResult.connect(onFail)
        faroManager.uploadFileHandle()
    }

    function deleSavedFile(filePath){
        var filejson = settingsManager.getValue(settingsManager.fileInfoData)
        console.log("get file json data 2: "+filejson)
        if (filejson) {
            var datas = JSON.parse(filejson)
            if (Array.isArray(datas)){
                var uniqueArray = datas.filter((value, index, self) => {
                                                   console.log("file path value: "+JSON.parse(value).filePath)
                                                   return JSON.parse(value).filePath !== filePath || !JSON.parse(value).filePath;
                                               });
                console.log("new: "+JSON.stringify(uniqueArray))
                settingsManager.setValue(settingsManager.fileInfoData,JSON.stringify(uniqueArray))
            } else {
                console.log("file make error ...")
                var nulldatas = []
                settingsManager.setValue(settingsManager.fileInfoData,JSON.stringify(nulldatas))
            }
        }
        var newfilejson = settingsManager.getValue(settingsManager.fileInfoData)
        console.log("new data 2: "+filejson)
        fileManager.removePath(filePath)
    }

    function performCalculation(result,filePath){
        function onReply(reply){
            faroManager.performCalculationSucResult.disconnect(onReply)
            console.log("perform calculation data: "+reply)
            getBuildingRoomListByFloorId()
        }

        function onFail(reply,code){
            console.log(reply,code)
            faroManager.performCalculationFailResult.disconnect(onFail)
        }

        faroManager.performCalculationSucResult.connect(onReply)
        faroManager.performCalculationFailResult.connect(onFail)
        faroManager.performCalculation(result,filePath)
    }

    function getBuildingRoomListByFloorId(floorId){
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            var response = JSON.parse(reply)
            console.log("complete building room listByFloorId data: "+reply)
            if (response.data.length <=0) {
                hub.close()
                return;
            }
            if (response.data.length <= selectHeaderIndex) selectHeaderIndex = 0
            roomsList = response.data
            room_id = roomsList[selectHeaderIndex].id
            console.log("select header index: "+selectHeaderIndex)
            getBuildingRoomTaskAndGetRoomTaskInfo(roomsList[selectHeaderIndex-1])
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            hub.close()
        }

        http.onReplySucSignal.connect(onReply)
        http.replyFailSignal.connect(onFail)
        console.log("inputModelData.id: "+ inputModelData.id)
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
                hub.close()
                return;
            }
            list = response.data.stations
            var urlStr = response.data.vectorgraph !== null ? response.data.vectorgraph : response.data.houseTypeDrawing
            admin_sys_file_listFileByFileIds([urlStr])
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
        function onFileReply(reply){
            hub.close()
            http.onReplySucSignal.disconnect(onFileReply)
            console.log("complete admin sys file listFileByFileIds: "+reply)
            var response = JSON.parse(reply)
            imageUrl = "http://"+response.data[0].bucketName+"."+response.data[0].fileUri+"/"+response.data[0].fileName
            console.log("imageUrl: "+imageUrl)
        }

        function onFileFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFileFail)
            hub.close()
        }
        http.onReplySucSignal.connect(onFileReply)
        http.replyFailSignal.connect(onFileFail)
        http.post(Api.admin_sys_file_listFileByFileIds,
                  {"integers":urlStrs})
    }
}
