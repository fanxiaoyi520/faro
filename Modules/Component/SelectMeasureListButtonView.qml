import QtQuick 2.0

ListView {
    id: listView
    property var list: []
    width: parent.width
    height: 31
    orientation: Qt.Horizontal
    spacing: 20
    currentIndex: 0
    anchors.left: parent.left
    anchors.leftMargin: 20
    anchors.right: parent.right
    anchors.rightMargin: 20
    clip: true
    model: list
    delegate: delegateItem
    signal clickSelectAction(int index,var model)
    Component {
        id: delegateItem
        Rectangle{
            width: contentItem.implicitWidth + 25
            height: listView.height
            color: listView.currentIndex === index ? "#1890FF" : "#FFFFFF"
            radius: 15
            border.color: "#3C3C3C"
            border.width: 1
            Text {
                id: contentItem
                text: modelData
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                elide: Text.ElideRight
                color: listView.currentIndex === index ? "#FFFFFF" : "#3C3C3C"
                font.weight: listView.currentIndex === index ? Font.Bold : Font.Normal
                font.pixelSize: 15
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    listView.currentIndex = index
                    clickSelectAction(index,list[index])
                }
            }
        }
    }
}
