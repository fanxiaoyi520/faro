import QtQuick 2.0

Rectangle {
    id: noDataView
    property var textStr: "暂无数据"
    Image{
        id: img
        source: "../../images/home_page_slices/nodata_tips@2x.png"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: 250
        height: 175
        Text{
            text: qsTr(textStr)
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5.5
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
