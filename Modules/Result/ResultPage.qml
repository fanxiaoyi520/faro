import Modules 1.0
import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import Http 1.0
import Api 1.0
import "../../String_Zh_Cn.js" as String

StackView{
    id: resultstack
    initialItem: resultview
    Component {
        id: resultview
        Rectangle{
            id:root
            property var modellist: []
            anchors.fill: parent
            BaseNavigationBar{
                id: navigationBar
                title: qsTr("测量结果")
                isVisibleBackBtn: false
            }
            Http{ id:http }
            Http{ id:http1 }
            MHeaderListButtonGroup{
                id: headerListButtonGroup
                anchors.top: navigationBar.bottom
                anchors.topMargin: 24
                height: 31
                list: ["全部","计算失败","计算完成"]
                selectedButtonIndex: 0
                onSelectedButtonAction: headerFilterData(index)
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
                width: parent.width
                anchors{
                    top: lineview.bottom
                    topMargin: 8
                }
                height: parent.height - lineview.height - headerListButtonGroup.height - navigationBar.height - rect_bottom.height - tabbar.height - 24 - 8 - 12
                Loader {
                    id: myLoader
                    sourceComponent: modellist.length === 0 ? noDataViewComponent : resultGridViewComponent
                }

                Component {
                    id: resultGridViewComponent
                    GridView{
                        id:grid_view
                        width: scrollView.width
                        height: scrollView.height
                        model: modellist
                        cellHeight: 120
                        cellWidth: scrollView.width / 2
                        clip: true
                        delegate: ItemviewResult{
                            width: grid_view.cellWidth
                            height: grid_view.cellHeight
                            resultData: modellist[index]
                        }
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

            Rectangle{
                id:rect_bottom
                width: parent.width
                anchors.bottom: parent.bottom
                anchors.bottomMargin: tabbar.height
                height: 25
                color: "#FFFFFF"
                property var all: 0
                property var success: 0
                property var faild: 0

                layer.enabled: true
                layer.effect: DropShadow{
                    horizontalOffset: 0
                    verticalOffset: 5.5
                    radius: 11.5
                    color: "#0A000000"
                }

                Rectangle{
                    id:rect_all
                    anchors.left: parent.left
                    width: parent.width / 3
                    height: parent.height
                    Row{
                        anchors.centerIn: parent
                        Text {
                            id:text_all_title
                            text: qsTr(String.result_statistics_all)
                        }
                        Rectangle{
                            width: 8
                            height: 1
                        }
                        Text {
                            id: text_all_content
                            text: rect_bottom.all
                        }
                    }
                }

                Rectangle{
                    id:rect_success
                    anchors.left: rect_all.right
                    width: parent.width / 3
                    height: parent.height
                    Row{
                        anchors.centerIn: parent
                        Image {
                            id: img_success
                            source: "../../images/ic_success.png"
                            width: 14
                            height: 14
                        }
                        Rectangle{
                            width: 8
                            height: 1
                        }
                        Text {
                            id:text_success_title
                            text: qsTr(String.result_statistics_success)
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#38BE76"
                        }
                        Rectangle{
                            width: 8
                            height: 1
                        }
                        Text {
                            id: text_success_content
                            text: rect_bottom.success
                            color: "#38BE76"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Rectangle{
                    id:rect_faild
                    anchors.left: rect_success.right
                    width: parent.width / 3
                    height: parent.height
                    Row{
                        anchors.centerIn: parent
                        Image {
                            id: img_faild
                            source: "../../images/ic_fail.png"
                            width: 14
                            height: 14
                        }
                        Rectangle{
                            width: 8
                            height: 1
                        }
                        Text {
                            id:text_faild_title
                            text: qsTr(String.result_statistics_faild)
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#FF4D4F"
                        }
                        Rectangle{
                            width: 8
                            height: 1
                        }
                        Text {
                            id: text_faild_content
                            text: rect_bottom.faild
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#FF4D4F"
                        }
                    }
                }
                Component.onCompleted: {
                    requestTaskNotifyStatisitic()
                }
            }

            property var loaded: false

            onVisibleChanged: {
                if(visible && !loaded){
                    requestMeasureResultPage(0)
                    loaded = true
                }
            }

            function requestMeasureResultPage(position){
                function onReply(reply){
                    http1.onReplySucSignal.disconnect(onReply)
                    http1.onReplyFailSignal.disconnect(onFail)
                    hub.close()
                    var replyObj = JSON.parse(reply)
                    modellist = replyObj.data.records
                    if(modellist.length > 0){
                        myLoader.sourceComponent = resultGridViewComponent
                    }else{
                        myLoader.sourceComponent = noDataViewComponent
                    }
                }


                function onFail(reply,code){
                    console.log(reply,code)
                    http1.onReplySucSignal.disconnect(onReply)
                    http1.onReplyFailSignal.disconnect(onFail)
                    hub.close()
                }

                http1.onReplySucSignal.connect(onReply)
                http1.onReplyFailSignal.connect(onFail)
                var appendData = "?current=1&size=999"
                if(position === 1){
                    appendData = "?current=1&size=999&status=3"
                }
                if(position === 2){
                    appendData = "?current=1&size=999&status=2"
                }

                http1.postForm(Api.building_measureTask_pager + appendData)
            }

            function requestTaskNotifyStatisitic(){
                function onReply(reply){
                    http.onReplySucSignal.disconnect(onReply)
                    http.onReplyFailSignal.disconnect(onFail)
                    hub.close()
                    var replyObj = JSON.parse(reply)
                    rect_bottom.all = replyObj.data.totalCount
                    rect_bottom.success = replyObj.data.successCount
                    rect_bottom.faild = replyObj.data.failedCount
                }


                function onFail(reply,code){
                    console.log(reply,code)
                    http.onReplySucSignal.disconnect(onReply)
                    http.onReplyFailSignal.disconnect(onFail)
                    hub.close()
                }

                http.onReplySucSignal.connect(onReply)
                http.onReplyFailSignal.connect(onFail)
                http.get(Api.building_tasknotify_statistics)
            }

            function headerFilterData(index){
                requestMeasureResultPage(index)
                if(rect_bottom.all === 0){
                    requestTaskNotifyStatisitic()
                }
            }
        }
    }
}
