import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import "../../String_Zh_Cn.js" as String

Rectangle{
    property var spacer: 0
    property var column: 0
    property var parentWidth: 0
    property var resultData
    color: "transparent"
//    height: 120
//    width: (parentWidth - (column * (spacer + 1))) / 2

    Rectangle{
        anchors.fill: parent
        anchors.margins: 8
        color: "transparent"

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
            anchors.margins: 8
            color: "#FFFFFF"
            radius: 8
            Text {
                id: text_title
                anchors{
                    top: parent.top
                    topMargin: 8
                }
                text: "111111"
            }

            Text {
                id: text_subtitle
                anchors{
                    top: text_title.bottom
                    topMargin: 8
                }
                text: "111111111111111"
            }

            RowLayout{
                anchors{
                    bottom: parent.bottom
                    bottomMargin: 16
                }
                width: parent.width
                height: 30
                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Image {
                        id: img_status
                        //                    source: "../../images/measure_other/measure_ic_progress.png"
                        anchors{
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                        }
                        width: 16
                        height: 16
                    }

                    Image {
                        id: img_right_arrow
                        source: "../../images/home_page_slices/home_more_arrow.png"
                        anchors{
                            right: parent.right
                            rightMargin:  16
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        id: text_date
                        text: ""
                        color: "#999999"
                        anchors.left: img_status.right
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle{
                        id:rect_stationno
                        height: parent.height - 8
                        width: 16
                        radius: 11
                        color: "#F5F5F5"
                        anchors.right: img_right_arrow.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            id: text_stationno
                            text: qsTr("text")
                            anchors.centerIn: parent
                        }
                    }

                    Text{
                        anchors.right: rect_stationno.left
                        anchors.rightMargin: 8
                        text: String.result_task_stationno_tips
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
    onResultDataChanged: {
        text_title.text = resultData.projectName
        var stageType = JSON.parse(String.stageType[resultData.stageType - 1]).name
        var typeName = String.result_task_type_room
        text_subtitle.text = resultData.blockName + "_" + resultData.unitName + "_"+ resultData.floorName + "_"+ resultData.roomName + "_"+ typeName + "_"+ stageType
        text_date.text = resultData.createdDate
        text_stationno.text = resultData.stationNo ? resultData.stationNo : ""
        if(resultData.status === 2){
            img_status.source = "../../images/measure_other/measure_complete.png"
        }
        else if(resultData.status === 3){
            img_status.source = "../../images/measure_other/measure_ic_calculation_failed.png"
        }else{
            img_status.source = "../../images/measure_other/measure_ic_progress.png"
        }
    }
}
