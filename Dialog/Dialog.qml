import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

Popup {
    property var list: []
    property int currentIndex: 0
    property var titleStr: "选择租户"
    signal confirmOptionsAction(var model)
    onListChanged: {
        console.log("List has changed:", list.length)
    }

    id: popup
    y: parent.height - (160 + 3 * 55)
    width: parent.width
    height: 160 + 3 * 55
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    background: Rectangle{
        radius: 25
        color: "#FFFFFF"
        Rectangle {
            id: coverRect
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 25
            color: "#FFFFFF"
            border.color: "transparent"
        }
    }
    padding: 0
    ColumnLayout{
        anchors.fill: parent
        clip: true
        Text {
            id: title
            text: titleStr
            font.pointSize: 18
            Layout.topMargin: 17.5
            Layout.alignment: Qt.AlignHCenter
            width: parent.width * 0.8
            color: "#2C2C2C"
        }

        Rectangle {
            id: bottomLine
            Layout.fillWidth: true
            Layout.topMargin: 17.5
            height: 1
            color: "#80EAEAEA"
        }

        ListView{
            clip: true
            id: listview
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: 3*55
            model: list
            delegate: listviewDelegate
            onCurrentIndexChanged: {
                currentIndex = currentIndex;
            }
        }

        Component{
            id: listviewDelegate
            Item {
                width: listview.width
                height: 54
                Row {
                    spacing: 15
                    anchors.fill: parent
                    anchors.left: parent.left
                    anchors.leftMargin: 30
                    anchors.right: parent.right
                    anchors.rightMargin: 30
                    Item {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width * 0.7

                        Text {
                            text: JSON.parse(modelData).name
                            color: "#3C3C3C"
                            elide: Qt.ElideRight
                            anchors.left: parent.left
                            anchors.leftMargin: 5
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 15
                        }
                    }

                    Item{
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 30
                        Image {
                            id: selimage
                            anchors.verticalCenter: parent.verticalCenter
                            source: "../images/login_sel.png"
                            width: 23
                            height: 23
                            visible: currentIndex === index
                        }
                    }
                }

                Rectangle {
                    id: bottomLine
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: "#80EAEAEA"
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        currentIndex = index;
                    }
                }
            }
        }

        Item {
            id: buttonsContainer
            Layout.fillWidth: true
            height: 100

            Button{
                id: cancelbtn
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 38.5
                anchors.left: parent.left
                anchors.leftMargin: 60
                width: (parent.width-60*2-24)/2
                height: 41
                text: qsTr("取消")
                highlighted: true
                background: Rectangle{
                    id: cancelbtnrect
                    color: "#F5F5F7"
                    radius: 20.5
                }
                contentItem: Text {
                    text: cancelbtn.text
                    color: "#333333"
                    anchors.centerIn: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.capitalization: Font.MixedCase
                    font.pixelSize: 15
                }
                onClicked: cancelAction()
            }

            Button{
                id: surebtn
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 38.5
                anchors.right: parent.right
                anchors.rightMargin: 60
                width: (parent.width-60*2-24)/2
                height: 41
                text: qsTr("确定")
                highlighted: true
                background: Rectangle{
                    id: surebtnrect
                    color: "#1890FF"
                    radius: 20.5
                }
                contentItem: Text {
                    text: surebtn.text
                    color: "#FFFFFF"
                    anchors.centerIn: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.capitalization: Font.MixedCase
                    font.pixelSize: 18
                }
                onClicked: sureAction()
            }
        }
    }

    function cancelAction(){
        popup.close()
    }

    function sureAction(){
        popup.close()
        console.log("sure clicked and currentIndex: " + currentIndex)
        confirmOptionsAction(JSON.parse(list[currentIndex]))
    }
}

