import QtQuick 2.0
import Modules 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Http 1.0
import Api 1.0
import Dialog 1.0
import QtGraphicalEffects 1.0
import QtEnumClass 1.0
import "../../Util/GlobalFunc.js" as GlobalFunc
import "../../String_Zh_Cn.js" as SettingString
ScrollView{
    property int page: 0
    property var inputModelData
    property string projectName: "Measure"
    property var list:[]
    property int currentRow: 0
    property string selectedStageName: "主体阶段（一阶段）"
    property int inputIndex
    property var transferModelData
    property var blockOffilneData
    id: selectBuildingView
    Layout.fillWidth: true
    Layout.fillHeight: true
    anchors.fill: parent
    clip: true
    Toast {id: toastPopup}
    Http {id: http}
    TipsPopUp{
        id: tipsPopUp
        onConfirmAction: preEnterMeasureMode()
    }
    //    Timer {
    //        id: downloadTimer
    //        interval: 500
    //        repeat: true
    //        onTriggered: downloadTimerTaskHandle ()
    //    }
    ScanningFaroPop{
        id: scanningFaroPop
        title: SettingString.faro_measure_task
        isVisibleCancle: true
        lottieType: 1
        onCancleBlock: buildingCancleBlock()
    }
    Dialog{
        id: dialog
        titleStr: qsTr("选择阶段")
        onConfirmOptionsAction: {
            console.log("dialog selected data: " + JSON.stringify(model))
            settingsManager.setValue(settingsManager.selectedStageType,JSON.stringify(model))
            currentRow = model.index
            selectedStageName = model.name
            hub.open()
            getBuildingBlockPage()
        }
    }
    Hub{id: hub}
    Loader {id: selectFloorView}
    background: Rectangle{
        color: "#FFFFFF"
    }

    BaseNavigationBar{
        id: navigationBar
        title: qsTr("选择楼栋")
        Rectangle{
            id: stageTypeBtn
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 12
            height: 34
            width: parent.width *  0.25
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
                    dialog.currentIndex = currentRow
                    dialog.open()
                }
            }
        }
        onBackAction: {
            rootStackView.pop()
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

    ListView /**PullListViewV2*/ {
        id: listView
        anchors.top: title.bottom
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
                Image{
                    id: img
                    source: GlobalFunc.setStatusImageSource(modelData)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    width: 17.5
                    height: 17.5
                }
                Text {
                    id: name
                    text: qsTr(modelData.blockName.replace(/栋/g,''))
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: img.right
                    anchors.leftMargin: 5
                }
                Text {
                    id: contentname
                    text: qsTr("待测户数")
                    anchors.right: numname.left
                    anchors.rightMargin: 1
                    anchors.top: parent.top
                    anchors.topMargin: 13.5
                    color: "#000000"
                }
                Text {
                    id: numname
                    text: "("+modelData.finishRoomCount + "/" + modelData.totalRoomCount+")"
                    anchors.right: arrowimg.left
                    anchors.rightMargin: 10
                    anchors.top: parent.top
                    anchors.topMargin: 13.5
                    color: "#999999"
                }
                Rectangle{
                    id: progress
                    height: 5
                    color: "#F5F5F5"
                    radius: 2.5
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

            Timer {
                id: longPressTimer
                interval: 500
                repeat: false
                onTriggered: {
                    if (mouseArea.pressed) {
                        console.log("Long press detected!");
                        // 在这里添加你的长按响应代码
                        longPressDetected()
                    }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: {
                    var loginMode = settingsManager.getValue(settingsManager.LoginMode)
                    inputIndex = index
                    transferModelData = modelData
                    if (Number(loginMode) === QtEnumClass.Ordinary) {
                        jumpToSelectFloor(index,modelData)
                    } else {
                        console.log("this is a major mode")
                    }
                }
                onPressed: {
                    if (Number(loginMode) === QtEnumClass.Major) {
                        longPressTimer.start();
                    }
                }

                onReleased: {
                    if (Number(loginMode) === QtEnumClass.Major) {
                        longPressTimer.stop();
                    }
                }

                onPositionChanged: {
                    if (mouseArea.pressed) {
                        if (Number(loginMode) === QtEnumClass.Major) {
                            longPressTimer.stop();
                        }
                    }
                }
            }
        }
    }

    onInputModelDataChanged: {
        projectName = JSON.parse(settingsManager.getValue(settingsManager.selectedProjectSource)).name + inputModelData.projectName
        hub.open()
        getBuildingBlockPage()
    }

    //MARK: logic
    function kbuildCallbackOrSyncEventHandling(){
        var selectedStageType = JSON.parse(settingsManager.getValue(settingsManager.selectedStageType))
        selectBuildingView.currentRow = selectedStageType.index
        selectBuildingView.selectedStageName = selectedStageType.name
    }

    //MARK: jump
    //跳转到选择楼层
    function longPressDetected(){
        tipsPopUp.tipsContentStr = SettingString.enter_measure_mode
        tipsPopUp.open()
    }

    function preEnterMeasureMode() {
        if (tipsPopUp.tipsContentStr === SettingString.enter_measure_mode) {
            console.log("inputIndex: "+inputIndex)
            console.log("transferModelData: "+JSON.stringify(transferModelData))
            tipsPopUp.close()
            scanningFaroPop.tipsconnect = SettingString.measure_resource_download_progress+"0%"
            scanningFaroPop.open()
            queryBlockOffilneData()
        }

        if (tipsPopUp.tipsContentStr === SettingString.sure_cancle_tasks) {
            console.log("sure cancle task ...")
            //downloadTimer.stop()
            scanningFaroPop.close()
            tipsPopUp.close()
        }
    }

    function buildingCancleBlock() {
        tipsPopUp.tipsContentStr = SettingString.sure_cancle_tasks
        tipsPopUp.open()
    }

    function jumpToSelectFloor(index,modelData){
        console.log("incoming data index: ("+index+") and model: "+JSON.stringify(modelData))
        selectFloorView.source = "SelectFloorView.qml"
        selectFloorView.item.inputModelData = modelData
        var selectedStageType = JSON.parse(settingsManager.getValue(settingsManager.selectedStageType))
        selectFloorView.item.currentRow = selectedStageType.index === undefined ? 0 : selectedStageType.index
        selectFloorView.item.selectedStageName = selectedStageType.name === undefined ? "主体阶段(一阶段)" : selectedStageType.name
        rootStackView.push(selectFloorView)
    }

    //MARK: network
    function getBuildingBlockPage(){
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            var response = JSON.parse(reply)
            console.log("complete building block page data: "+reply)
            if (response.data.length <=0) {
                hub.close()
                return;
            }
            if(response.data.records.length === 0) {
                list = response.data.records
                hub.close()
                return
            }
            assemblySelectedProjectData(response.data.records)
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            hub.close()
        }

        http.onReplySucSignal.connect(onReply)
        http.replyFailSignal.connect(onFail)
        http.post(Api.building_block_page,{"current":page,"size":"2000","projectId":inputModelData.id})
    }

    function assemblySelectedProjectData(dataList){
        var blockIds = dataList.map(item=>{
                                        return item.id
                                    })
        console.log("input params blockIds: " + blockIds)
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            hub.close()
            console.log("complete building room blockRoomCount data: "+reply)
            var response = JSON.parse(reply)
            var endlist = dataList
            response.data.map(item => {
                                  endlist = dataList.map(subItem => {
                                                             if (subItem.id === item.blockId){
                                                                 subItem.finishRoomCount = item.finishRoomCount
                                                                 subItem.totalRoomCount = item.totalRoomCount
                                                                 subItem.status = item.status
                                                             }
                                                             return subItem
                                                         })
                              })
            list = endlist
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            hub.close()
        }

        http.onReplySucSignal.connect(onReply)
        http.replyFailSignal.connect(onFail)
        http.post(Api.building_room_blockRoomCount,
                  {"blockIds":blockIds,"stageType":currentRow+1})
    }

    function queryBlockOffilneData(){
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            var response = JSON.parse(reply)
            console.log("complete query block offilne data: "+reply)
            if (!response.data) {
                hub.close()
                return;
            }
            blockOffilneData = response.data
            //downloadTimer.start()
            scanningFaroPop.tipsconnect = SettingString.measure_resource_download_progress+"1%"
            downloadTaskHandle()
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            hub.close()
        }

        http.onReplySucSignal.connect(onReply)
        http.replyFailSignal.connect(onFail)
        http.get(Api.building_block_queryBlockOfflineData,{"stageType":currentRow+1,"blockId":transferModelData.id})
    }

    function downloadTaskHandle(){
        function onFileReply(reply){
            hub.close()
            http.onReplySucSignal.disconnect(onFileReply)
            console.log("complete admin sys file listFileByFileIds: "+reply)
        }

        function onFileFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFileFail)
            hub.close()
        }
        console.log("blockOffilneData.pics: "+blockOffilneData.pics)
        http.onReplySucSignal.connect(onFileReply)
        http.replyFailSignal.connect(onFileFail)
        blockOffilneData.pics.map(item=>{
                                      console.log("urlStr: "+item)
                                      http.download(Api.admin_sys_file_listFileByFileIds,
                                                    {"integers":item})
                                      return item
                                  })
    }
}
