import QtQuick 2.0
import Modules 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import "../../Util/GlobalEnum.js" as GlobalEnum

Grid {
    property var list: []
    ListModel {
        id: listModel
        ListElement {
            text: "一阶段"
            progresscolor: "#1FA3FF"
        }
        ListElement {
            text: "二阶段"
            progresscolor: "#FE9623"
        }
        ListElement {
            text: "三阶段"
            progresscolor: "#44D7B6"
        }
        ListElement {
            text: "四阶段"
            progresscolor: "#32C5FF"
        }
        ListElement {
            text: "五阶段"
            progresscolor: "#38BE76"
        }
    }
    columns: 3
    rowSpacing: 16
    columnSpacing: 13
    x: 16
    y: 13.5
    flow: Flow.LeftToRight
    Repeater {
        model: list
        Rectangle{
            width: (parent.parent.parent.width-16*2-13*(3-1))/3
            height: 175
            color: "#FFFFFF"
            Rectangle{
                anchors.fill: parent
                color: "#FFFFFF"
                layer.enabled: true
                radius: 8
                layer.effect: DropShadow{
                    horizontalOffset: 0
                    verticalOffset: 5.5
                    radius: 11.5
                    color: "#10000000"
                }
                Image {
                    id: img
                    source: setStatusImageSource(modelData)
                    width: 17
                    height: 17
                    anchors.left: parent.left
                    anchors.leftMargin: 11
                    anchors.top: parent.top
                    anchors.topMargin: 17.5
                }
                Text{
                    text: qsTr(setStatusStr(modelData))
                    elide: Qt.ElideMiddle
                    anchors {
                        verticalCenter: img.verticalCenter
                        left: img.right
                        leftMargin: 10
                        right: parent.right
                    }
                }
                Text{
                    id: subtitle
                    text: qsTr(modelData.projectName)
                    elide: Qt.ElideRight
                    wrapMode: Text.NoWrap
                    anchors {
                        left: parent.left
                        leftMargin: 11
                        right: parent.right
                        rightMargin: 11
                        top: img.bottom
                        topMargin: 11
                    }
                }
                Text{
                    id : content
                    text: qsTr("待测户数")
                    elide: Qt.ElideRight
                    wrapMode: Text.WrapAnywhere
                    anchors {
                        left: parent.left
                        leftMargin: 11
                        right: parent.right
                        rightMargin: 11
                        top: subtitle.bottom
                        topMargin: 7
                    }
                }

                ListView {
                    id: listView
                    width: parent.width
                    height: modelData.reduceItem ? 18*modelData.reduceItem.totalData : 18*listModel.count
                    anchors{
                        top: content.bottom
                        topMargin: 13
                    }
                    model: modelData.reduceItem ? modelData.reduceItem.totalData : listModel
                    delegate: itemDelegate
                }

                Component {
                    id: itemDelegate
                    HomeGridSubConView{
                        width: parent.width
                        height: 14
                        titlestr: modelData.text ? modelData.text : "一阶段"
                        progresscolor: modelData.progresscolor ? modelData.progresscolor : "#1FA3FF"
                    }
                }
            }
        }
    }

    function setStatusImageSource(modelData){

        if (modelData && modelData.reduceItem) {
            var status = modelData.reduceItem.status;
            switch (modelData.reduceItem.status){
            case GlobalEnum.MMProjectStatus.NotTurnedOn:
                return "../../images/measure_other/measure_ic_not_created@2x.png"
            case GlobalEnum.MMProjectStatus.InProgress:
                return "../../images/measure_other/measure_ic_progress@2x.png"
            case GlobalEnum.MMProjectStatus.Completed:
                return "../../images/measure_other/measure_complete@2x.png"
            case GlobalEnum.MMProjectStatus.Close:
                return "../../images/measure_other/measure_ic_calculation_failed@2x.png"
            default: break
            }
        } else {
            return "../../images/measure_other/measure_ic_not_created@2x.png"
        }
    }

    function setStatusStr(modelData){

        if (modelData && modelData.reduceItem) {
            var status = modelData.reduceItem.status;
            switch (modelData.reduceItem.status){
            case GlobalEnum.MMProjectStatus.NotTurnedOn:
                return "未开启"
            case GlobalEnum.MMProjectStatus.InProgress:
                return "进行中"
            case GlobalEnum.MMProjectStatus.Completed:
                return "已完成"
            case GlobalEnum.MMProjectStatus.Close:
                return "已关闭"
            default: break
            }
        } else {
            return "未开启"
        }
    }
}
