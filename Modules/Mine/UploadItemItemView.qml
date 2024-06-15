import QtQuick 2.0
import QtGraphicalEffects 1.0
import "../../String_Zh_Cn.js" as String

Rectangle{
    width: parent.width
    height: 48
    property var fileInfo
    property var selectAll: false

    Rectangle{
        anchors.fill: parent
        anchors.margins: 8
        radius: 8
        color: "#FFFFFF"
        layer.enabled: true
        layer.effect: DropShadow{
            horizontalOffset: 0
            verticalOffset: 5.5
            radius: 5.5
            color: "#0A000000"
        }

        Image {
            id: img_status
            width: 16
            height: 16
            source : "../../images/mine/ic_unselected.png"
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    fileInfo.isSelected = !fileInfo.isSelected
                    isSelectChange(fileInfo.isSelected)
                }
            }
        }

        Text {
            id: text_station_no
            anchors{
                left: img_status.right
                leftMargin: 16
                verticalCenter: parent.verticalCenter
            }

            text: qsTr(String.upload_station.replace("%d",fileInfo.taskNo))
        }

        Text {
            id: text_date
            text: qsTr(fileInfo.update_time)
            anchors{
                right: parent.right
                rightMargin: 16
                verticalCenter: parent.verticalCenter
            }
            color: "#666666"
        }

    }

    onSelectAllChanged: {
        console.log("fileInfo = " + JSON.stringify(fileInfo))
         fileInfo.isSelected = selectAll
         isSelectChange(fileInfo.isSelected)
    }

    function isSelectChange(isSelected){
        img_status.source = (isSelected) ? "../../images/mine/ic_selected.png" : "../../images/mine/ic_unselected.png"
        if (!rect_root.selectList.includes(fileInfo) && isSelected) {
            rect_root.selectList.push(fileInfo)
        }
        if(!isSelected){
            rect_root.selectList.pop(fileInfo)
        }
    }
}
