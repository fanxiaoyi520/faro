import QtQuick 2.0

Rectangle {
    id:root
    property var showDive: true
    property var settingInfo
    property var iconPath:""
    property var onItemClick: null
    width: parent.width
    height: 37
    color: "white"
    Rectangle{
        id:rect_setting_item
        width: parent.width
        height: 32
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        Image {
            id: img_type_icon
            source: settingInfo.icon_path
            anchors.left: parent.left
            width: 20
            height: 20
             anchors.verticalCenter:parent.verticalCenter
        }
        Text{
            text: settingInfo.icon_name
            anchors.leftMargin: 16
            anchors.left: img_type_icon.right
            anchors.verticalCenter:parent.verticalCenter
        }

        Image {
            source: "../../images/home_page_slices/select_building_arrow.png"
            anchors.right: parent.right
            anchors.rightMargin: 16
             anchors.verticalCenter:parent.verticalCenter
             width: 10
             height: 18
        }
        Rectangle{
            id : rect_dive
            width: parent.width
            height: 1
            anchors.top: img_type_icon.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 4
            color: "#efefef"
            visible: showDive
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
               if(onItemClick){
                   onItemClick();
               }
            }
        }
    }
}
