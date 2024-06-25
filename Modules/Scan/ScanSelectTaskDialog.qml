import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12
import "../../String_Zh_Cn.js" as Settings

Popup {
    property var list: []
    property int currentIndex: 0
    property var titleStr: Settings.scan_select_task
    signal confirmOptionsAction(var model)
    onListChanged: {
        console.log("List has changed:" + list[0], list.length)
        var objList = []
        for(var i = 0;i < list.length;i++){
            if(typeof list[i] === "string"){
                objList.push(JSON.parse(list[i]))
            }
        }
        if(objList.length !== 0){
            list = objList
        }
    }

    id: popup
    y: parent.height - popup.height
    width: parent.width
    height: contentItem.implicitHeight
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
    contentItem:  ColumnLayout{
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
            id: my_listview
            Layout.fillWidth: true
            model: list
            delegate: listviewDelegate
            onCurrentIndexChanged: {
                currentIndex = currentIndex;
            }
            Component.onCompleted: {
                contentHeightChanged();
            }

            onContentHeightChanged: {
                my_listview.height = my_listview.contentHeight + 54 * 2;
                console.log("list height =" + my_listview.contentHeight)
            }
        }

        Component{
            id: listviewDelegate
            Item {
                width: my_listview.width
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
                        width: parent.width * 0.3

                        Text {
                            text: modelData.name
                            color: "#3C3C3C"
                            elide: Qt.ElideRight
                            anchors.left: parent.left
                            anchors.leftMargin: 5
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 15
                        }
                    }

                    Item{
                        id: arrowImageItem
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 30
                        Image {
                            id: selimage
                            anchors.verticalCenter: parent.verticalCenter
                            source: "../../images/home_page_slices/home_measure_right_arrow@2x.png"
                            width: 7
                            height: 12.5
                        }
                    }

                    Item {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width * 0.5
                        anchors.right: arrowImageItem.left
                        anchors.rightMargin: 5
                        Text {
                            text: modelData.content
                            color: "#C5C5C5"
                            elide: Qt.ElideRight
                            anchors.right: parent.right
                            anchors.rightMargin: 5
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 15
                            horizontalAlignment: Text.AlignRight
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
            Layout.topMargin: 16
            height: 57
            Button{
                id: surebtn
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 60
                anchors.left: parent.left
                anchors.leftMargin: 60
                height: 41
                text: qsTr(Settings.search_tasks)
                highlighted: true
                font.pixelSize: 16
                font.bold: true
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
                    font.pixelSize: 16
                    font.bold: true
                }
                onClicked: sureAction()
            }
        }
    }

    function sureAction(){
        popup.close()
        console.log("sure clicked and currentIndex: " + currentIndex)
        confirmOptionsAction(list[currentIndex])
    }
}

