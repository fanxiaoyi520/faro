import QtQuick 2.0
import Modules 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Http 1.0
import Api 1.0
import Dialog 1.0
import "../../String_Zh_Cn.js" as SettingString
import "../../Util/GlobalFunc.js" as GlobalFunc

StackView{
    property var modellist: []
    property var sourcelist: []
    property string navigationBarTitle: qsTr("房间实测")
    property int headerSelectedIndex: 0
    //公布stackView，让其在所有子控件可以访问到homestack
    property var rootStackView: homestack
    id: homestack
    initialItem: homeview
    Toast {id: toastPopup}
    Http {id: http}
    Dialog{id: dialog}
    Hub{id: hub}
    Loader {id: searchview}
    Loader {id: selectBuildingView}

    Component {
        id: homeview
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
                text: qsTr("项目信息")
                anchors.top: navigationBar.bottom
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.leftMargin: 20
                font.bold: true
                font.pixelSize: 19
            }

            MHeaderListButtonGroup{
                id: headerListButtonGroup
                anchors.top: title.bottom
                anchors.topMargin: 24
                height: 31
                list: ["全部","进行中","已完成"]
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

            ScrollView {
                id: scrollView
                clip: true
                anchors.top: lineview.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 79+16
                width: parent.width
                height: parent.height - 1 - headerListButtonGroup.height - 24 - title.height - 20 - navigationBar.height - tabbar.height
                Loader {
                    id: myLoader
                    sourceComponent: modellist.length === 0 ? noDataViewComponent : homeGridViewComponent
                }

                Component {
                    id: homeGridViewComponent
                    HomeGridView{
                        clip: true
                        width: scrollView.width
                        height: scrollView.height
                        id: homeGridView
                        list: modellist
                    }
                }

                Component{
                    id: noDataViewComponent
                    NoDataView{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        width: scrollView.width
                        height: scrollView.height
                        id: noDataView
                        textStr: qsTr("暂无项目数据")
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        var tree = settingsManager.getValue(settingsManager.organizationalTree)
        if (GlobalFunc.isJson(tree)) {
            var organizationalTree = JSON.parse(settingsManager.getValue(settingsManager.organizationalTree))
            if (organizationalTree.data.length > 0) {
                var selectedProjectData = JSON.parse(settingsManager.getValue(settingsManager.selectedProject))
                sourcelist = modellist = selectedProjectData
            } else {
                hub.open()
                getNumberOfOrganizations()
            }
        } else {
            hub.open()
            getNumberOfOrganizations()
        }
    }

    //MARK: logic
    function headerFilterData(index,itemData){
        console.log("selected header index and item data: "+index,itemData)
        if (index !== 0) {
            modellist = sourcelist.filter(model => {
                                              return model.reduceItem.status === index;
                                          })
        } else {
            modellist = sourcelist
        }
    }

    //MARK: jump
    //跳转到搜索
    function jumpToSearchView(){
        //使用的时候再加载
        searchview.source = "SearchView.qml"
        homestack.push(searchview)
    }

    //跳转到选择楼栋
    function jumpToSelectBuilding(index,modelData){
        console.log("incoming data model: "+JSON.stringify(modelData))
        selectBuildingView.source = "SelectBuildingView.qml"
        selectBuildingView.item.inputModelData = modelData
        var params = settingsManager.getValue(settingsManager.selectedStageType)
        if (!params) {
            settingsManager.setValue(settingsManager.selectedStageType,SettingString.stageType[0])
        }
        var selectedStageType = JSON.parse(settingsManager.getValue(settingsManager.selectedStageType))
        selectBuildingView.item.currentRow = selectedStageType.index === undefined ? 0 : selectedStageType.index
        selectBuildingView.item.selectedStageName = selectedStageType.name === undefined ? "主体阶段(一阶段)" : selectedStageType.name
        settingsManager.setValue(settingsManager.selectedItem,JSON.stringify(modelData))
        homestack.push(selectBuildingView)
    }

    //MARK: network
    function sureSelectedSearchResult(modelData){
        searchview.parent.pop()
        headerSelectedIndex = 0
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

    function getNumberOfOrganizations(){
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            hub.close()
            var response = JSON.parse(reply)
            console.log("complete dept tree data: "+response)
            if (response.data.length <=0) return;
            settingsManager.setValue(settingsManager.organizationalTree,reply)
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            hub.close()
        }

        http.onReplySucSignal.connect(onReply)
        http.replyFailSignal.connect(onFail)
        http.get(Api.admin_dept_tree)
    }
}
