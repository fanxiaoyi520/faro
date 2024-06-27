import QtQuick 2.0
import QtQuick.Controls 2.12
import "../../String_Zh_Cn.js" as Settings
import "../../Util/GlobalFunc.js" as GlobalFunc

Rectangle {
    color: "#FFFFFF"
    property var setupModel
    signal setupMeasureData()
    signal clickSelectTask()
    signal clickSelectStationNo()
    property var selectProjectData
    property var selectStationData
    
    Rectangle{
        id: leftSelectTaskRec
        anchors.left: parent.left
        anchors.leftMargin: 16
        height: 43
        radius: 5
        border.color: "#010101"
        border.width: 1
        width: parent.width * 0.6
        Text {
            id: leftSelectTaskRecText
            text: qsTr(!GlobalFunc.isEmpty(selectProjectData) ? selectProjectData.projectName : Settings.click_select_task)
            font.pointSize: 16
            color: !GlobalFunc.isEmpty(selectProjectData) ? "#333333" : "#999999"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 20
        }

        Image{
            id: arrowImage
            source: "../../images/home_page_slices/home_measure_right_arrow.png"
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
        }

        MouseArea{
            anchors.fill: parent
            onClicked: clickSelectTask()
        }
    }

    Rectangle{
        id: rightStationNoRec
        anchors.left: leftSelectTaskRec.right
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 16
        height: 43
        radius: 5
        border.color: "#010101"
        border.width: 1
        Text {
            id: rightStationNoRecText
            text: qsTr(!GlobalFunc.isEmpty(selectStationData) ? (Settings.stationname+selectStationData.stationNo): Settings.station_no)
            font.pointSize: 16
            color: !GlobalFunc.isEmpty(selectStationData) ? "#333333" : "#999999"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
        MouseArea{
            anchors.fill: parent
            onClicked: clickSelectStationNo()
        }
    }

    /**
    Text {
        id: autoUploadText
        text: qsTr(Settings.scan_auto_upload)
        font.pointSize: 16
        color: "#333333"
        anchors.top: leftSelectTaskRec.bottom
        anchors.topMargin: 34.5
        anchors.left: parent.left
        anchors.leftMargin: 16
    }

    Switch {
        id: scanswitch
        anchors.verticalCenter: autoUploadText.verticalCenter
        width: 42
        height: 32
        anchors.right: parent.right
        anchors.rightMargin: 16
        //onCheckedChanged: switchAction(checked)
    }
    */

    Canvas {
        id: lineview
        width: parent.width
        height: 1
        //anchors.top: autoUploadText.bottom
        //anchors.topMargin: 15.5
        anchors.top: leftSelectTaskRec.bottom
        anchors.topMargin: 34.5
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

    Text {
        id: measureModeText
        text: qsTr(Settings.measure_mode_tips)
        font.pointSize: 16
        color: "#333333"
        anchors.top: lineview.bottom
        anchors.topMargin: 16
        anchors.left: parent.left
        anchors.leftMargin: 16
    }

    Text {
        id: scansetup
        text: qsTr(Settings.scan_set_up)
        font.pointSize: 16
        color: "#1890FF"
        anchors.top: lineview.bottom
        anchors.topMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: 16
        MouseArea{
            anchors.fill: parent
            onClicked: {
                console.log("enter setup")
                setupMeasureData()
            }
        }
    }
}
