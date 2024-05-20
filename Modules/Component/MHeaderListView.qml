import QtQuick 2.0

ListView {
    id: listView
    property var list: []
    width: parent.width
    height: 31
    orientation: Qt.Horizontal
    spacing: 30
    currentIndex: 0
    anchors.left: parent.left
    anchors.leftMargin: 20
    anchors.right: parent.right
    anchors.rightMargin: 20
    clip: true
    model: list
    delegate: delegateItem
    signal clickSwitchAction(int index,var model)
    Component {
        id: delegateItem
        Rectangle{
            width: contentItem.implicitWidth + 2
            height: listView.height
            Text {
                id: contentItem
                text: modelData.roomName
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                elide: Text.ElideRight
                color: "#292929"
                font.weight: listView.currentIndex === index ? Font.Bold : Font.Normal
                font.pixelSize: 15
            }

            Rectangle {
                id: underline
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
                color: "#1890FF"
                visible: listView.currentIndex === index ? true : false
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    listView.currentIndex = index
                    clickSwitchAction(index,list[index])
                }
            }
        }
    }
}
