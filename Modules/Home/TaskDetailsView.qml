import QtQuick 2.0
import Modules 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Http 1.0
import Api 1.0
import Dialog 1.0
import QtGraphicalEffects 1.0
import "../../Util/GlobalFunc.js" as GlobalFunc

Item{
    property int page: 0
    property var inputModelData
    property var roomsList:[]
    property var list:[]
    property int currentRow: 0
    property string selectedStageName: "主体阶段（一阶段）"
    property string projectName: "Measure"
    property string imageUrl : ""
    property double imageBackHeight : parent.width * 0.6
    property double imageBackWidth : parent.width * 0.6

    id: selectTaskDetailsView
    Layout.fillWidth: true
    Layout.fillHeight: true
    anchors.fill: parent
    clip: true
    Toast {id: toastPopup}
    Http {id: http}
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
    TipsPopUp{
        id: tipsPopUp
        tipsContentStr: qsTr("是否重新开始扫描")
        onConfirmAction: {
            tipsSwitchPopUp.open()
        }
    }
    TipsPopUp{
        id: tipsSwitchPopUp
        tipsContentStr: qsTr("扫描后是否自动上传")
        switchvisible: true
        onConfirmAndSwitchAction: {
            console.log("is auto upload file: "+checked)
        }
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
                    dialog.list = JSON.parse(settingsManager.stageType)
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

    function scanAction(){
        tipsPopUp.open()
    }

    function moreAction(){
        morePopUp.open()
    }

    function moreCellClickAction(model){
        selectMeasureModePopUp.open()
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
            if (!response.data || response.data.length <=0) {
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
