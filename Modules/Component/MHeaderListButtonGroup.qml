import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Rectangle {
    property variant list: []//default data
    property int selectedButtonIndex: 0
    signal selectedButtonAction(int index,var itemData)
    height: 31
    width: parent.width * 0.6
    RowLayout {
        id: buttonLayout
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        height: parent.height
        Repeater {
            model: list
            Button {
                id: stateButton
                implicitWidth: parent.width / list.length
                implicitHeight: parent.height
                background: Rectangle{
                    color: "transparent"
                }
                Text {
                    id: btntext
                    text: typeof modelData === "string" ? qsTr(modelData) : modelData.unitName
                    anchors.centerIn: parent.Center
                    color: "#292929"
                    font.pixelSize: 15
                    font.weight: selectedButtonIndex === index? Font.Bold : Font.Normal
                }
                Rectangle{
                    color: "#1890FF"
                    width: btntext.width
                    anchors.bottom: parent.bottom
                    height: 1
                    visible: selectedButtonIndex === index ? true : false
                }
                onClicked: {
                    setSelectedButton(index)
                }
            }
        }
    }

    function setSelectedButton(index) {
        if (index >= 0 && index < list.length) {
            selectedButtonIndex = index;
            selectedButtonAction(selectedButtonIndex,list[selectedButtonIndex])
        }
    }
}
