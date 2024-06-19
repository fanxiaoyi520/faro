import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import "../../Util/GlobalFunc.js" as GlobalFunc
import "../../String_Zh_Cn.js" as Settings
import "../../Util/GlobalEnum.js" as GlobalEnum

Rectangle {
    property var model
    property double ratioWidth : 1.0
    property double oldWidth : parent.width
    property string cellroom_id

    width: parent.width
    height: 82.5
    Component.onCompleted: {
        oldWidth = parent.width
    }
    onWidthChanged: {
        ratioWidth = parent.width / oldWidth
    }
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
        Image {
            id: cellStatusImage
            source: setStatusImageSource(model)
            width: 17;height: 17
            anchors.left: parent.left
            anchors.leftMargin: 23.5
            anchors.top: parent.top
            anchors.topMargin: 20.5
            MouseArea{
                width: parent.width
                height: parent.height
                onClicked: {
                    console.log("station info")
                    stationInfo(model)
                }
            }
        }
        Text {
            id: title
            text: qsTr("测站")+model.stationNo
            anchors.left: cellStatusImage.right
            anchors.leftMargin: 5
            anchors.verticalCenter: cellStatusImage.verticalCenter
            color: "#2E2E2E"
            font.pixelSize: 16
        }
        Text {
            id: subTitle
            text: qsTr("/")+GlobalFunc.setStationType(model.stationType)
            anchors.left: title.right
            anchors.leftMargin: 3
            anchors.verticalCenter: cellStatusImage.verticalCenter
            color: "#999999"
            font.pixelSize: 15
        }
        Image {
            id: arrowimg
            source: "../../images/home_page_slices/select_building_arrow@2x.png"
            width: 7
            height: 12.5
            anchors.verticalCenter: cellStatusImage.verticalCenter
            anchors.left: subTitle.right
            anchors.leftMargin: 10
        }
        Rectangle{
            id: scoreRect
            anchors.left: arrowimg.right
            anchors.leftMargin: 10
            anchors.verticalCenter: arrowimg.verticalCenter
            width: parent.width * 0.1
            height: 23
            radius: 11.5
            color: "#0C1890FF"
            visible: setScoresIsHidden(model)
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                id: scoreTitle
                text: Math.round(model.percentageScore !== null ? model.percentageScore : 0.00)+Settings.minute
                color: "#1890FF"
                font.pixelSize: 14
            }
        }
        Text {
            id: tipsTitle
            text: tipsTitleContent(model)
            anchors.left: parent.left
            anchors.leftMargin: 23.5
            anchors.top: parent.top
            anchors.topMargin: 47
            color: tipsTitleColor(model)
            font.pixelSize: 13
        }
        Rectangle {
            id: verticalLine
            width: 1
            height: 47
            anchors.verticalCenter: parent.verticalCenter
            color: "#80EAEAEA"
            anchors.right: parent.right
            anchors.rightMargin: parent.width * 0.18
        }

        ColumnLayout{
            id: scanColumnLayout
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: verticalLine.left
            anchors.leftMargin: 18.5 * ratioWidth
            Image {
                id: scanimage
                source: "../../images/home_page_slices/home_scan@2x.png"
                width: 20;height: 20
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                id: scantitle
                Layout.fillWidth: true
                y: 5
                text: qsTr("扫描")
                color: "#000000"
                font.pixelSize: 13
            }
            MouseArea{
                width: parent.width
                height: parent.height
                onClicked: {
                    console.log("scan clicked")
                    scanAction(model)
                }
            }
        }

        Rectangle{
            id: reddort
            color: "red"
            width: 6;height: 6
            anchors.right: moreColumnLayout.right
            anchors.top: moreColumnLayout.top
            radius: 3
            visible: model.status === 0 && filtering(model) !== undefined
        }

        ColumnLayout{
            id: moreColumnLayout
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 13.5 * ratioWidth
            Image {
                id: moreimage
                source: "../../images/home_page_slices/home_more@2x.png"
                width: 20;height: 20
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                id: moretitle
                Layout.fillWidth: true
                y: 5
                text: qsTr(Settings.more)
                color: "#000000"
                font.pixelSize: 13
            }
            MouseArea{
                width: parent.width
                height: parent.height
                onClicked: {
                    console.log("more clicked")
                    moreAction(model)
                }
            }
        }
    }

    function setScoresIsHidden(model){
        return !model.percentageScore ? false : model.status === 2
    }

    function tipsTitleColor(model){
        if (model.status === 2) {
            return "#999999"
        }
        return "#2e2e2e"
    }

    function tipsTitleContent(model){
        console.log("cell display model: "+JSON.stringify(model))
        var uniqueModel = filtering(model)
        console.log("detais cell model: "+JSON.stringify(model))
        if (model.status === 0 && uniqueModel === undefined) {
            return Settings.station_waiting_scan
        } else if (model.status === 0) {
            return Settings.station_waiting_upload_file
        } else if (model.status === 1) {
            return Settings.station_waiting_calculated
        } else if (model.status === 2) {
            return model.operationTime
        } else if (model.status === 3) {
            return Settings.station_calculated_fail
        }
        return Settings.station_waiting_measurement
    }

    function filtering(model) {
        var filejson = settingsManager.getValue(settingsManager.fileInfoData);
        var selectedStageType = JSON.parse(settingsManager.getValue(settingsManager.selectedStageType))
        console.log("filejson: "+filejson)
        var uniqueModel
        if (GlobalFunc.isJson(filejson)){
            var fileModel = JSON.parse(filejson)
            if (Array.isArray(fileModel)){
                uniqueModel = fileModel.find((value, index, self) => {
                                                 console.log("JSON.parse(value).stationId: "+JSON.parse(value).stationId)
                                                 console.log("model.stationId: "+model.stationId)
                                                 console.log("JSON.parse(value).roomId: "+model.roomId)
                                                 console.log("cellroom_id: "+model.roomId)
                                                 console.log("stageType: "+model.stageType)

                                                 return JSON.parse(value).stationId === model.stationId
                                                 && JSON.parse(value).roomId === model.roomId
                                                 && JSON.parse(value).stageType === selectedStageType.index+1
                                             });
            }
        }
        console.log("unique model: " + JSON.stringify(uniqueModel))
        return uniqueModel
    }

    function setStatusImageSource(modelData){
        var uniqueModel = filtering(model)
        if (modelData) {
            var status = modelData.status;
            switch (modelData.status){
            case GlobalEnum.MMProjectStatus.NotTurnedOn:
                if (uniqueModel === undefined) {
                    return "../../images/measure_other/measure_ic_not_created@2x.png"
                } else {
                    return "../../images/measure_other/measure_ic_progress@2x.png"
                }
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
}
