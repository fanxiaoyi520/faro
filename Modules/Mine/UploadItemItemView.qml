import QtQuick 2.0
import QtGraphicalEffects 1.0
import "../../String_Zh_Cn.js" as String

Rectangle{
    width: parent.width
    height: 48
    property var fileInfo

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

    Component.onCompleted: {
        if(fileInfo.isSelected){
             img_status.source = "../../images/mine/ic_selected.png"
        }
    }

    function isSelectChange(isSelected){
        img_status.source = (isSelected) ? "../../images/mine/ic_selected.png" : "../../images/mine/ic_unselected.png"
        if (!rect_root.selectList.includes(fileInfo) && isSelected) {
            rect_root.selectList.push(fileInfo)
        }
        if(!isSelected){
            rect_root.selectList.pop(fileInfo)
        }
        if(rect_root.selectList.length !== rect_root.totalSize && img_select_all.isSelect){
            img_select_all.isSelect = false
        }
        column_itemview.datas[index] = JSON.stringify(fileInfo)

//        console.log("select data = " + JSON.stringify(rect_root.selectList))
    }
}
