import QtQuick 2.0
import Modules 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import "../../Util/GlobalEnum.js" as GlobalEnum

Grid {
    property var list: []
    columns: 3
    rowSpacing: 16
    columnSpacing: 13
    x: 16
    y: 13.5
    flow: Flow.LeftToRight
    id: grid
    Repeater {
        model: list
        Rectangle{
            width: (parent.parent.parent.parent.width-16*2-13*(3-1))/3
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
            }
            Rectangle{
                anchors.fill: parent
                color: "#FFFFFF"
                radius: 8
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
                    text: qsTr(modelData ? modelData.projectName : "Measure")
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
                    height: 18*modelData.stageProgresses.length
                    anchors{
                        top: content.bottom
                        topMargin: 13
                    }
                    model: modelData.stageProgresses
                    delegate: itemDelegate
                }

                Component {
                    id: itemDelegate
                    HomeGridSubConView{
                        width: parent.width
                        height: 14
                        titlestr: getStageTypeStr(modelData)
                        progresscolor: getStageTypeColor(modelData)
                        totalRoomCount: modelData.totalTaskCount
                        finishRoomCount: modelData.finishedTaskCount
                    }
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        console.log("clicked project item to: "+ index)
                        jumpToSelectBuilding(index,modelData)
                    }
                }
            }
        }
    }

    function getStageTypeStr(modelData){
        switch(modelData.stageType){
        case GlobalEnum.MMStageType.One:
            return "一阶段"
        case GlobalEnum.MMStageType.Two:
            return "二阶段"
        case GlobalEnum.MMStageType.Three:
            return "三阶段"
        case GlobalEnum.MMStageType.Four:
            return "四阶段"
        case GlobalEnum.MMStageType.Five:
            return "五阶段"
        default: break
        }

    }

    function getStageTypeColor(modelData){
        switch(modelData.stageType){
        case GlobalEnum.MMStageType.One:
            return "#1FA3FF"
        case GlobalEnum.MMStageType.Two:
            return "#FE9623"
        case GlobalEnum.MMStageType.Three:
            return "#44D7B6"
        case GlobalEnum.MMStageType.Four:
            return "#32C5FF"
        case GlobalEnum.MMStageType.Five:
            return "#38BE76"
        default: break
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
