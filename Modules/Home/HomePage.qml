import QtQuick 2.0
import Modules 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Http 1.0
import Api 1.0
import Dialog 1.0
StackView{
    property var modellist: []
    property var menuItems: []
    property string navigationBarTitle: qsTr("房间实测")
    property int headerSelectedIndex: 0
    id: homestack
    initialItem: homeview
    Toast {id: toastPopup}
    Http {id: http}
    Dialog{id: dialog}
    Hub{id: hub}
    Loader {
        id: searchview
        source: "SearchView.qml"
    }
    Component {
        id: homeview
        Rectangle{
            id: rect
            Layout.fillHeight: true
            Layout.fillWidth: true
            BaseNavigationBar{
                id: navigationBar
                title: navigationBarTitle

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
                selectedButtonIndex: headerSelectedIndex
                onSelectedButtonAction: {
                    console.log("selected header index and item data: "+index,itemData)
                    if (index === 0) {
                        modellist = 10
                    } else if (index === 1) {
                        modellist = 5
                    } else {
                        modellist = 1
                    }
                }
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
                height: parent.height
                HomeGridView{
                    list: modellist
                }
            }
        }
    }

    Component.onCompleted: {
        hub.open()
        getNumberOfOrganizations()
    }

    function jumpToSearchView(){
        //searchview.menuItems = menuItems
        homestack.push(searchview)
    }

    function sureSelectedSearchResult(modelData){
        searchview.parent.pop()
        console.log("search selected cell clicked: "+ JSON.stringify(modelData))
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
                headerSelectedIndex = 0
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
            response.data.forEach((obj, index) => {
                model.records.forEach((item, recordIndex) => {
                    if (obj.projectId === item.id) {
                        item.reduceItem = addObjData(index, obj); // 假设 addObjData 是一个函数，用于添加或修改数据
                    }
                });
                                      modellist = model.records
                                      console.log("ffffffffff:"+JSON.stringify(modellist))
            });
//            response.data.map(obj =>{
//                                  var dataItems = model.records.map(item => {
//                                                                        if(obj.projectId === item.id){
//                                                                            item.reduceItem = addObjData(index,obj)
//                                                                        }
//                                                                        return item
//                                                                    })
//                                  console.log("Combined data: " + JSON.stringify(dataItems))
//                                  modellist = dataItems
//                              })
        }

        function addObjData(index,obj) {
            if (index === 0) {
                obj.text = "一阶段"
                obj.progresscolor = "#1FA3FF"
            } else if (index === 1) {
                obj.text = "二阶段"
                obj.progresscolor = "#FE9623"
            } else if (index === 2) {
                obj.text = "三阶段"
                obj.progresscolor = "#44D7B6"
            } else if (index === 3) {
                obj.text = "四阶段"
                obj.progresscolor = "#32C5FF"
            } else  {
                obj.text = "五阶段"
                obj.progresscolor = "#38BE76"
            }
            return obj
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
            menuItems = response.data
            handleOrgData(response.data[0])
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

    function handleOrgData(data){
        console.log("neet handle,s data :"+JSON.stringify(data))
    }
}
