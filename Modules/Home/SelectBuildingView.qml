import QtQuick 2.0
import Modules 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Http 1.0
import Api 1.0
import Dialog 1.0
import QtGraphicalEffects 1.0
import "../../Util/GlobalFunc.js" as GlobalFunc

ScrollView{
    property int page: 0
    property var inputModelData
    property string projectName: "Measure"
    property var list:[]

    id: selectBuildingView
    Layout.fillWidth: true
    Layout.fillHeight: true
    anchors.fill: parent
    clip: true
    Toast {id: toastPopup}
    Http {id: http}
    Dialog{id: dialog}
    Hub{id: hub}
    background: Rectangle{
        color: "#FFFFFF"
    }

    BaseNavigationBar{
        id: navigationBar
        title: qsTr("选择楼栋")
        onBackAction: {
            selectBuildingView.parent.parent.pop()
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

    ListView {
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
                    source: GlobalFunc.setStatusImageSource(1)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20
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
                    text: qsTr("(2/5)")
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
                        width: parent.width * (1 / 5)
                        color: "red"
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
        }
    }

    onInputModelDataChanged: {
        projectName = JSON.parse(settingsManager.getValue(settingsManager.selectedProjectSource)).name + inputModelData.projectName
        hub.open()
        getBuildingBlockPage()
    }

    //MARK: network
    function getBuildingBlockPage(){
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            hub.close()
            var response = JSON.parse(reply)
            console.log("complete building block page data: "+reply)
            if (response.data.length <=0) return;
            list = response.data.records
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
}
