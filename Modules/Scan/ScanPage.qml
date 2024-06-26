import QtQuick 2.0
import Modules 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Http 1.0
import Api 1.0
import Dialog 1.0
import QtGraphicalEffects 1.0
import "../../String_Zh_Cn.js" as SettingString
import "../../Util/GlobalFunc.js" as GlobalFunc
StackView{
    id: scanstack
    initialItem: scanview
    property string navigationBarTitle: SettingString.quick_scan
    //公布stackView，让其在所有子控件可以访问到homestack
    property var rootStackView: scanstack
    property var scanSelectTaskData: SettingString.selectTask
    property var roomTaskVoModel
    property var imageUrl

    property double imageBackHeight : scanstack.width * 0.6
    property double imageBackWidth : scanstack.width * 0.6
    property var selectPorjectData
    property var selectBuildingData
    property var selectUnitData
    property var selectFloorData
    property var selectRoomData

    Toast {id: toastPopup}
    Http {id: http}
    Dialog{id: dialog}
    Hub{id: hub}
    Loader {id: searchview}
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
    }

    Component {
        id: scanview
        Rectangle{
            id: rect
            Layout.fillHeight: true
            Layout.fillWidth: true

            BaseNavigationBar{
                id: navigationBar
                title: navigationBarTitle
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
                        height: 119.5
                        onSetupMeasureData: scanSetupMeasureData()
                        onClickSelectTask: scanClickSelectTask()
                        onClickSelectStationNo: scanClickSelectStationNo()
                    }

                    Rectangle{
                        Layout.fillWidth: true
                        height: 200
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
        console.log("start scan")
    }

    //MARK: jump
    //跳转到搜索
    function jumpToSearchView(){
        //使用的时候再加载
        searchview.source = "../Home/SearchView.qml"
        scanstack.push(searchview)
    }

    function scanSetupMeasureData() {
        var params = settingsManager.getValue(settingsManager.selectedStageType)
        if (!params) {
            settingsManager.setValue(settingsManager.selectedStageType,SettingString.stageType[0])
        }
        var selectedStageType = JSON.parse(settingsManager.getValue(settingsManager.selectedStageType))
        selectMeasureModePopUp.stageType = selectedStageType.index+1
        selectMeasureModePopUp.stationType = 2

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
        if (index === 0) {
            selectPorjectData = modelData
        } else if (index === 1) {
            selectBuildingData = modelData
        } else if (index === 2) {
            selectUnitData = modelData
        } else if (index === 3) {
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

    function scanClickSelectTask() {
        console.log("click select task")
        scanSelectTaskDialog.isChangeColor = false
        scanSelectTaskDialog.list = SettingString.selectTask
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
}
