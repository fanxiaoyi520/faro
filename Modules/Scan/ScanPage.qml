import QtQuick 2.0
import Modules 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Http 1.0
import Api 1.0
import Dialog 1.0
import QtGraphicalEffects 1.0
import FaroManager 1.0

import "../../String_Zh_Cn.js" as SettingString
import "../../Util/GlobalFunc.js" as GlobalFunc

StackView{
    id: scanstack
    initialItem: scanview
    //property string navigationBarTitle: SettingString.quick_scan
    //公布stackView，让其在所有子控件可以访问到homestack
    property var rootStackView: scanstack
    property var scanSelectTaskData: SettingString.selectTask
    property var roomTaskVoModel
    property var imageUrl
    property var scanSelectProjectData
    property var scanSelectStationData

    property double imageBackHeight : scanstack.width * 0.8
    property double imageBackWidth : scanstack.width * 0.8
    property var selectPorjectData
    property var selectBuildingData
    property var selectUnitData
    property var selectFloorData
    property var selectRoomData
    onVisibleChanged: {
        if (visible) clearAll()
    }
    Toast {id: toastPopup}
    Http {id: http}
    Dialog{id: dialog}
    Hub{id: hub}
    Loader {id: searchview}
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
        onConnectResult: detailConnectResult(result)
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
    SelectMeasureModePopUp{
        id: selectMeasureModePopUp
    }
    ScanSelectTaskDialog{
        id: scanSelectTaskDialog
        onConfirmOptionsAction: scanConfirmOptionsAction(model)
        onPopUpclickSelectTask: scanPopUpclickSelectTask(index)
    }
    ScanSelectProjectPop {
        id: scanSelectProjectPop
        onCellClickHandle: scanSellClickHandle(modelData,index)
    }
    ScanSelectBuildingPop {
        id: scanSelectBuildingPop
        onCellClickHandle: scanSellClickHandle(modelData,index)
    }
    ScanSelectUnitPop {
        id: scanSelectUnitPop
        onCellClickHandle: scanSellClickHandle(modelData,index)
    }
    ScanSelectFloorPop {
        id: scanSelectFloorPop
        onCellClickHandle: scanSellClickHandle(modelData,index)
    }
    ScanSelectRoomPop {
        id: scanSelectRoomPop
        onCellClickHandle: scanSellClickHandle(modelData,index)
    }
    ScanSearchResultDialog{
        id: scanSearchResultDialog
        onSelectSearchResult: scanSelectSearchResult(model)
    }
    ScanSelectStationNoDialog {
        id: scanSelectStationNoDialog
        onSelectStationNo: scanFuncSelectStationNo(model)
    }

    Component {
        id: scanview
        Rectangle{
            id: rect
            Layout.fillHeight: true
            Layout.fillWidth: true

            BaseNavigationBar{
                id: navigationBar
                title: GlobalFunc.isEmpty(navigationBarTitle) ? SettingString.quick_scan : navigationBarTitle
                isVisibleBackBtn: false

                Image{
                    id: searchimage
                    source: "../../images/home_page_slices/measure_search.png"
                    width: 20;height: 20
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    MouseArea{
                        anchors.fill: parent
                        onClicked: jumpToSearchView()
                    }
                }
            }

            Text{
                id: title
                text: SettingString.scanning_tasks
                anchors.top: navigationBar.bottom
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.leftMargin: 20
                font.bold: true
                font.pixelSize: 19
            }

            ScrollView {
                id: scrollView
                clip: true
                anchors.top: title.bottom
                anchors.topMargin: 15
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 79
                ColumnLayout{
                    id: column
                    anchors.fill: parent
                    ScanImageHeaderView {
                        id: scanImageHeaderView
                        visible: GlobalFunc.isEmpty(roomTaskVoModel) ? false : true
                        imgUrl: imageUrl
                        model: roomTaskVoModel
                        Layout.fillWidth: true
                        Layout.preferredHeight: imageBackHeight+90-64
                    }

                    ScanHeaderView{
                        id: scanHeaderView
                        Layout.fillWidth: true
                        Layout.topMargin: 20
                        height: 119.5
                        onSetupMeasureData: scanSetupMeasureData()
                        onClickSelectTask: scanClickSelectTask()
                        onClickSelectStationNo: scanClickSelectStationNo()
                        selectProjectData: scanSelectProjectData
                        selectStationData: scanSelectStationData
                    }

                    Rectangle{
                        Layout.fillWidth: true
                        height: 120
                        Button{
                            id: startScanBtn
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 30
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width * 0.4
                            height: 53
                            text: qsTr(SettingString.start_scan)
                            font.capitalization: Font.MixedCase
                            font.pixelSize: 18
                            highlighted: true
                            palette.buttonText: "#FFFFFF"
                            background: Rectangle{
                                id: btnrect
                                color: "#1890FF"
                                radius: 12
                            }
                            layer.enabled: true
                            layer.effect: DropShadow{
                                horizontalOffset: 0
                                verticalOffset: 12
                                radius: 50
                                color: "#1A1890FF"
                            }
                            onClicked: startScan()
                        }
                    }
                }
            }
        }
    }

    //MARK: Scan
    function startScan() {
        if (!checkPreScan()) return

        console.log("start scan ...")
        var timer = new Date()
        console.log("timer = " + timer.toLocaleString())
        console.log("selectedMeasureData" + settingsManager.getValue(settingsManager.selectedMeasureData))
        var selectedMeasureData = JSON.parse(settingsManager.getValue(settingsManager.selectedMeasureData))
        var scanParams = {
            "activeColoring": selectedMeasureData ? selectedMeasureData.activeColoring : "0",
            "map_mode": selectedMeasureData ? selectedMeasureData.map_mode : "4",
            "scanningMode": selectedMeasureData ? selectedMeasureData.scanningMode : "1/20",
            "masonry_mode": selectedMeasureData ? selectedMeasureData.masonry_mode : 0,
            "xy_crop_dist": selectedMeasureData ? selectedMeasureData.xy_crop_dist : 6,
            "z_crop_dist": selectedMeasureData ? selectedMeasureData.z_crop_dist : 3,

            "stationId":scanSelectStationData.stationId,
            "taskNo":scanSelectStationData.stationNo,
            "stationType":scanSelectStationData.stationType,
            "isAutoUpload":false,
            "projectName":roomTaskVoModel.projectName,
            "blockName":roomTaskVoModel.blockName,
            "unitName":roomTaskVoModel.unitName,
            "floorName":roomTaskVoModel.floorName,
            "roomName":roomTaskVoModel.roomName,
            "stageType":roomTaskVoModel.stageType,
            "roomId":scanSelectStationData.roomId,
            "stationTaskNo": scanSelectStationData.stationTaskNo,
            "update_time": timer.toLocaleString()
        }

        console.log("input scanning parameters: "+JSON.stringify(scanParams))
        console.log("~scanSelectStationData: "+JSON.stringify(scanSelectStationData))
        console.log("~selectedMeasureData: "+JSON.stringify(selectedMeasureData))
        console.log("~roomTaskVoModel: "+JSON.stringify(roomTaskVoModel))
        wifiConectHandle(scanParams)
    }

    function checkPreScan(){
        if (GlobalFunc.isEmpty(roomTaskVoModel)
                || roomTaskVoModel.ifReadyForTask === 0
                || GlobalFunc.isEmpty(scanSelectProjectData)) {
            toastPopup.text = SettingString.please_first_select_task
            return false
        }

        if (GlobalFunc.isEmpty(scanSelectStationData)) {
            toastPopup.text = SettingString.please_select_station
            return false
        }
        return true
    }

    function wifiConectHandle(scanParams){
        var wifi = settingsManager.getValue(settingsManager.currentDevice)
        if (!wifi) {
            nonerworkPopUp.tipsContentStr = qsTr(SettingString.unable_obtain_device_WiFi)
            nonerworkPopUp.open()
            return
        }
        console.log("wifi info =" + wifi)

        function connectResult(isSuc){
            wifiHelper.connectToWiFiResult.disconnect(connectResult)
            if (isSuc){
                console.log("wifi connect suc ...")
                enteringScanningPhase(scanParams,false)
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
            //clearAll()
            taskDetialViewMonitorNetworkChanges()
            function wifiDisConnect(result){
                nonerworkPopUp.tipsContentStr = qsTr(SettingString.file_sync_suc)
                nonerworkPopUp.open()
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
        var connectResult = faroManager.connect(scanParams)
        console.log("connect result: "+connectResult)

        scanningFaroPop.tipsconnect = SettingString.starting_connection_to_machine
        scanningFaroPop.title = SettingString.scan_station_id+scanSelectStationData.stationNo
        scanningFaroPop.lottieType = 0
        scanningFaroPop.open()
    }

    function detailConnectResult(result){
        console.log("result: "+result)
        var wifi = settingsManager.getValue(settingsManager.currentDevice)
        if(GlobalFunc.isJson(wifi)) {
            console.log("start scan wifi info =" + wifi)
            var contentName = JSON.parse(wifi).wifiName
            var currentWifiName = wifiHelper.queryInterfaceName()
            if (currentWifiName === contentName){
                scanningFaroPop.tipsconnect = SettingString.device_connect_suc
            }
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
                console.log("cover index: "+index)
                if (index !== -1) {
                    if (!GlobalFunc.isEmpty(scanParams.stageType)) {
                        datas[index] = JSON.stringify(scanParams);
                    }
                } else {
                    if (!GlobalFunc.isEmpty(scanParams.stageType)) {
                        datas.push(JSON.stringify(scanParams))
                    }
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

    //MARK: jump
    //跳转到搜索
    function jumpToSearchView(){
        //使用的时候再加载
        searchview.source = "../Home/SearchView.qml"
        scanstack.push(searchview)
    }

    function enlargeImageAction(inputImageUrl){
        console.log("need enlarge image: "+ inputImageUrl)
        enlargeImagePopUp.imgUrl = imageUrl
        enlargeImagePopUp.model = roomTaskVoModel
        enlargeImagePopUp.open()
    }

    function scanSetupMeasureData() {
        var params = settingsManager.getValue(settingsManager.selectedStageType)
        if (!params) {
            settingsManager.setValue(settingsManager.selectedStageType,SettingString.stageType[0])
        }
        var selectedStageType = JSON.parse(settingsManager.getValue(settingsManager.selectedStageType))
        selectMeasureModePopUp.stageType = GlobalFunc.isEmpty(scanSelectProjectData) ? selectedStageType.index+1 : scanSelectProjectData.stageType
        selectMeasureModePopUp.stationType = GlobalFunc.isEmpty(scanSelectStationData) ? 2 : scanSelectStationData. stationType
        console.log("stageType: "+selectMeasureModePopUp.stageType)
        var selectedMeasureData = JSON.parse(settingsManager.getValue(settingsManager.selectedMeasureData))
        var dataList = SettingString.selectedMeasureMode.map(function(itemString) {
            var itemObject = JSON.parse(itemString);
            itemObject.xy_crop_dist = selectedMeasureData.xy_crop_dist;
            itemObject.z_crop_dist = selectedMeasureData.z_crop_dist;
            return JSON.stringify(itemObject);
        });
        console.log("dataList: "+JSON.stringify(dataList))
        selectMeasureModePopUp.list = []
        selectMeasureModePopUp.list = dataList
        selectMeasureModePopUp.open()
    }

    //MARK: Func Logic
    function scanSellClickHandle(modelData,index) {
        console.log("func index: "+index)
        console.log("scan select model data: "+ JSON.stringify(modelData))
        if (GlobalFunc.isEmpty(scanSelectTaskData)) scanSelectTaskData = SettingString.selectTask
        if (index === 0) {
            if (!GlobalFunc.isEmpty(selectPorjectData)
                    && modelData.id !== selectPorjectData.id) {
                selectBuildingData = undefined
                selectUnitData = undefined
                selectFloorData = undefined
                selectRoomData = undefined
                scanSelectTaskData = SettingString.selectTask
            }
            selectPorjectData = modelData
        } else if (index === 1) {
            if (!GlobalFunc.isEmpty(selectBuildingData)
                    && modelData.id !== selectBuildingData.id) {
                selectUnitData = undefined
                selectFloorData = undefined
                selectRoomData = undefined
                scanSelectTaskData = scanSelectTaskData.map(function(itemString) {
                    var itemObject = JSON.parse(itemString);
                    if (itemObject.index === 2) itemObject.content = SettingString.please_select_unit
                    if (itemObject.index === 3) itemObject.content = SettingString.please_select_floor
                    if (itemObject.index === 4) itemObject.content = SettingString.please_select_roomno
                    return JSON.stringify(itemObject);
                });
            }
            selectBuildingData = modelData
        } else if (index === 2) {
            if (!GlobalFunc.isEmpty(selectUnitData)
                    && modelData.id !== selectUnitData.id) {
                selectFloorData = undefined
                selectRoomData = undefined
                scanSelectTaskData = scanSelectTaskData.map(function(itemString) {
                    var itemObject = JSON.parse(itemString);
                    if (itemObject.index === 3) itemObject.content = SettingString.please_select_floor
                    if (itemObject.index === 4) itemObject.content = SettingString.please_select_roomno
                    return JSON.stringify(itemObject);
                });
            }
            selectUnitData = modelData
        } else if (index === 3) {
            if (!GlobalFunc.isEmpty(selectFloorData)
                    && modelData.id !== selectFloorData.id) {
                selectRoomData = undefined
                scanSelectTaskData = scanSelectTaskData.map(function(itemString) {
                    var itemObject = JSON.parse(itemString);
                    if (itemObject.index === 4) itemObject.content = SettingString.please_select_roomno
                    return JSON.stringify(itemObject);
                });
            }
            selectFloorData = modelData
        } else {
            selectRoomData = modelData
        }
        scanSelectTaskData = scanSelectTaskData.map(function(itemString) {
            var itemObject = JSON.parse(itemString);
            if (itemObject.index === index) {
                itemObject.content = accoringIndexGetContent(index,modelData)
                return JSON.stringify(itemObject);
            }
            return itemString;
        });
        console.log("modified data: "+scanSelectTaskData)
        scanSelectTaskDialog.isChangeColor = GlobalFunc.isEmpty(selectPorjectData) ? false : true
        scanSelectTaskDialog.list = scanSelectTaskData
    }

    function accoringIndexGetContent(index,modelData) {
        if (index === 0) return modelData.projectName
        if (index === 1) return modelData.blockName
        if (index === 2) return modelData.unitName
        if (index === 3) return modelData.floorName
        if (index === 4) return modelData.roomName
    }

    function accoringIndexReductionContent(index,modelData) {
        if (index === 0) return modelData.projectName
        if (index === 1) return modelData.blockName
        if (index === 2) return modelData.unitName
        if (index === 3) return modelData.floorName
        if (index === 4) return modelData.roomName
    }

    function scanClickSelectTask() {
        console.log("click select task"+JSON.stringify(selectPorjectData))
        scanSelectTaskDialog.isChangeColor = GlobalFunc.isEmpty(selectPorjectData) ? false : true
        scanSelectTaskDialog.list = !GlobalFunc.isEmpty(scanSelectTaskData) ? scanSelectTaskData : SettingString.selectTask
        scanSelectTaskDialog.open()
    }

    function scanClickSelectStationNo() {
        console.log("click select stationNo")
        if (GlobalFunc.isEmpty(roomTaskVoModel)) {
            toastPopup.text = SettingString.station_info_null
            return
        }
        if (GlobalFunc.isEmpty(roomTaskVoModel.stations) && roomTaskVoModel.stations.length === 0) {
            toastPopup.text = SettingString.station_info_null
            return
        } else {
            console.log("stations: "+JSON.stringify(roomTaskVoModel.stations))
            scanSelectStationNoDialog.list = roomTaskVoModel.stations
            scanSelectStationNoDialog.open()
        }
    }

    function scanFuncSelectStationNo(modelData) {
        console.log("selected station no: "+JSON.stringify(modelData))
        if (GlobalFunc.isEmpty(modelData.stationTaskNo)) {
            createRoomStationTask(modelData)
        } else {
            scanSelectStationData = modelData
        }
    }

    function scanConfirmOptionsAction(model) {
        console.log("select task sure")
        scanSearchResultDialog.selectPorjectData = selectPorjectData
        scanSearchResultDialog.selectBuildingData = selectBuildingData
        scanSearchResultDialog.selectFloorData = selectFloorData
        scanSearchResultDialog.selectRoomData = selectRoomData
        scanSearchResultDialog.selectUnitData = selectUnitData
        scanSearchResultDialog.open()
    }

    function scanPopUpclickSelectTask(index) {
        console.log("scan pop up click select task")
        if (index === 0) {
            scanSelectProjectPop.index = index
            scanSelectProjectPop.open()
        } else if (index === 1) {

            if (GlobalFunc.isEmpty(selectPorjectData)) {
                toastPopup.text = SettingString.please_select_project
            } else {
                scanSelectBuildingPop.index = index
                scanSelectBuildingPop.inputModelData = selectPorjectData
                scanSelectBuildingPop.open()
            }
        } else if (index === 2) {
            if (GlobalFunc.isEmpty(selectBuildingData)) {
                toastPopup.text = SettingString.please_select_building
            } else {
                scanSelectUnitPop.index = index
                scanSelectUnitPop.inputModelData = selectBuildingData
                scanSelectUnitPop.open()
            }
        } else if (index === 3) {
            if (GlobalFunc.isEmpty(selectUnitData)) {
                toastPopup.text = SettingString.please_select_unit
            } else {
                scanSelectFloorPop.index = index
                scanSelectFloorPop.inputModelData = selectBuildingData
                scanSelectFloorPop.unitInputModelData = selectUnitData
                scanSelectFloorPop.open()
            }
        } else {
            if (GlobalFunc.isEmpty(selectFloorData)) {
                toastPopup.text = SettingString.please_select_floor
            } else {
                scanSelectRoomPop.index = index
                scanSelectRoomPop.inputModelData = selectFloorData
                scanSelectRoomPop.open()
            }
        }
    }

    function scanSelectSearchResult(modelData) {
        console.log("selected search result data: " + JSON.stringify(modelData))
        clearSelectedData()
        scanSelectProjectData = modelData
        hub.open()
        getBuildingRoomTaskAndGetRoomTaskInfo(modelData)
    }

    //MARK: Network
    function getBuildingRoomTaskAndGetRoomTaskInfo(roomModel){
        function onBuildingReply(reply){
            http.onReplySucSignal.disconnect(onBuildingReply)
            console.log("complete building room task and get roomTaskInfo: "+reply)
            var response = JSON.parse(reply)
            roomTaskVoModel = response.data
            if (!response.data || response.data.stations.length <=0) {
                imageUrl = ""
                hub.close()
                return;
            }

            var urlStr = response.data.vectorgraph !== null ? response.data.vectorgraph : response.data.houseTypeDrawing
            admin_sys_file_listFileByFileIds([urlStr])
        }

        function onBuildingFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onBuildingFail)
            hub.close()
        }

        http.onReplySucSignal.connect(onBuildingReply)
        http.replyFailSignal.connect(onBuildingFail)
        http.get(Api.building_roomTask_getRoomTaskInfo,
                 {"roomId":roomModel.roomId,"stageType":roomModel.stageType})
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

    function clearSelectedData(){
        scanSelectProjectData = undefined
        scanSelectStationData = undefined
        roomTaskVoModel = undefined
        imageUrl = undefined
    }

    function createRoomStationTask(modelData) {
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            console.log("complete building roomStation task create "+reply)
            var response = JSON.parse(reply)
            if (!response.data) {
                hub.close()
                return;
            }
            modelData.stationTaskNo = response.data
            scanSelectStationData = modelData
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            hub.close()
        }

        http.onReplySucSignal.connect(onReply)
        http.replyFailSignal.connect(onFail)
        http.post(Api.building_roomStationTask_create,
                  {"roomTaskNo":modelData.roomTaskNo,"stationId":modelData.stationId})
    }

    function clearAll() {
        scanSelectTaskData = undefined
        selectPorjectData = undefined
        selectBuildingData = undefined
        selectFloorData = undefined
        selectUnitData = undefined
        selectRoomData = undefined
        clearSelectedData()
    }

    function sureSelectedSearchResult(modelData){
        searchview.parent.pop()
        headerSelectedIndex = 0
        clearAll()
        console.log("search selected project data: "+JSON.stringify(modelData))
        settingsManager.setValue(settingsManager.selectedProjectSource,JSON.stringify(modelData))
        assemblySelectedProjectData(modelData)
    }

    function assemblySelectedProjectData(modelData){
        navigationBarTitle = qsTr(modelData.name)

        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            hub.close()
            console.log("complete project page data: "+reply)
            var response = JSON.parse(reply)
            reduceData(response.data)
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            hub.close()
        }

        http.onReplySucSignal.connect(onReply)

        http.replyFailSignal.connect(onFail)
        http.post(Api.building_project_page,
                  {"current":1,"size":10,"deptId":modelData.id})
    }

    function reduceData(model){
        if (model && Array.isArray(model.records)) {
            var ids = model.records.map(item => item.id)
            console.log("ids: "+ ids)
            if(ids.length <= 0) {
                //更新数据UI
                return
            }
            buildingRoomProjectRoomCount(ids,model)
        } else {
            console.error("model 或 model.records 是 undefined 或不是数组");
        }
    }

    function buildingRoomProjectRoomCount(ids,model){
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            hub.close()
            console.log("complete building room projectRoomCount data: "+reply)
            var response = JSON.parse(reply)
            response.data.map(obj =>{
                                  var dataItems = model.records.map(item => {
                                                                        if(obj.projectId === item.id){
                                                                            item.reduceItem = obj
                                                                        }
                                                                        return item
                                                                    })
                                  console.log("Combined data: " + JSON.stringify(dataItems))
                                  settingsManager.setValue(settingsManager.selectedProject,JSON.stringify(dataItems))
                                  sourcelist = dataItems
                                  modellist = dataItems
                              })
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            hub.close()
        }

        http.onReplySucSignal.connect(onReply)
        http.replyFailSignal.connect(onFail)
        http.post(Api.building_room_projectRoomCount,
                  {"integers":ids})
    }
}
