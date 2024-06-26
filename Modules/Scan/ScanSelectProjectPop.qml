import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12
import Http 1.0
import Api 1.0
import "../../Util/GlobalFunc.js" as GlobalFunc
import "../../String_Zh_Cn.js" as SettingString
Popup {
    property var titleStr: SettingString.scan_select_project
    property var list
    property var index: 0
    property var selectModelData
    signal cellClickHandle(var modelData,int index)
    onOpened: accordingIndexHandleRequest(index)
    id: popup
    y: parent.height * 0.1
    x: parent.width * 0.1
    width: parent.width * 0.8
    height: parent.height * 0.8


    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    background: Rectangle{
        radius: 25
        color: "transparent"
    }

    contentItem:     Rectangle{
        anchors.fill: parent
        radius: 25
        color: "#FFFFFF"

        Text {
            id: title
            text: titleStr
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 17
            font.pointSize: 18
            color: "#2C2C2C"
            font.weight: Font.Bold
        }
        Image {
            id: closeimg
            source: "../../images/measure_other/measure_back.png"
            width: 17;height: 17
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: title.verticalCenter
            MouseArea{
                anchors.fill: parent
                onClicked: popup.close()
            }
        }
        Rectangle {
            id: bottomLine
            anchors.top: title.bottom
            anchors.topMargin: 17
            width: parent.width
            height: 1
            color: "#80EAEAEA"
        }
        ListView {
            id: listView
            anchors.top: bottomLine.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 25
            clip: true
            model: list
            delegate:itemDelegate
        }
        Component{
            id: itemDelegate
            Rectangle {
                height: 54
                width: parent.parent.width
                Text {
                    id: title
                    text: qsTr(modelData.projectName)
                    anchors.left: parent.left
                    anchors.leftMargin: 25
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 15
                    color: "#3C3C3C"
                }
                Canvas {
                    id: lineview
                    width: parent.width
                    height: 1
                    y:53
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
                MouseArea {
                    anchors.fill: parent
                    onClicked: cellClick(modelData,index)
                }
            }
        }
    }

    //MARK: Func Logic
    function accordingIndexHandleRequest(index) {
        console.log("index: " + index)
        selectedProjectData()
    }

    function cellClick(modelData) {
        console.log("cell clicked: "+JSON.stringify(modelData))
        popup.close()
        cellClickHandle(modelData,index)
    }

    //MARK: Network
    function selectedProjectData(){
        var tree = settingsManager.getValue(settingsManager.organizationalTree)
        if (GlobalFunc.isJson(tree)) {
            var organizationalTree = JSON.parse(settingsManager.getValue(settingsManager.organizationalTree))
            if (organizationalTree.data.length > 0) {
                var selectedProjectData = JSON.parse(settingsManager.getValue(settingsManager.selectedProject))
                list = []
                list = selectedProjectData
                console.log("scan project list: "+settingsManager.getValue(settingsManager.selectedProject))
            } else {
                hub.open()
                getNumberOfOrganizations()
            }
        } else {
            hub.open()
            getNumberOfOrganizations()
        }
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





