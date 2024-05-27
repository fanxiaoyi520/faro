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
ScrollView{
    property int page: 0
    property var inputModelData
    property string projectName: "Measure"
    property var list:[]
    property int currentRow: 0
    property string selectedStageName: "主体阶段（一阶段）"

    id: selectBuildingView
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
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    jumpToSelectFloor(index,modelData)
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
    function callbackOrSyncEventHandling(){
        var selectedStageType = JSON.parse(settingsManager.getValue(settingsManager.selectedStageType))
        selectBuildingView.currentRow = selectedStageType.index
        selectBuildingView.selectedStageName = selectedStageType.name
    }

    //MARK: jump
    //跳转到选择楼层
    function jumpToSelectFloor(index,modelData){
        console.log("incoming data index: ("+index+") and model: "+JSON.stringify(modelData))
        selectFloorView.source = "SelectFloorView.qml"
        selectFloorView.item.inputModelData = modelData
        var selectedStageType = JSON.parse(settingsManager.getValue(settingsManager.selectedStageType))
        selectFloorView.item.currentRow = selectedStageType.index
        selectFloorView.item.selectedStageName = selectedStageType.name
        rootStackView.push(selectFloorView)
    }

    //MARK: network
    function getBuildingBlockPage(){
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            var response = JSON.parse(reply)
            console.log("complete building block page data: "+reply)
            if (response.data.length <=0) return;
            if(response.data.records.length === 0) {
                list = response.data.records
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
}
