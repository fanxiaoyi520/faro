import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12
import "../../String_Zh_Cn.js" as SettingString

Popup {
    property var list
    property int currentIndex: 0
    property var titleStr: SettingString.more
    signal confirmOptionsAction(var model)
    onListChanged: {
        console.log("List has changed:", list.length)
    }

    id: popup
    y: parent.height - (110 + 3 * 55)
    width: parent.width
    height: 110 + 3 * 55

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
    Rectangle{
        anchors.fill: parent
        clip: true
        color: "transparent"
        Text {
            id: title
            text: titleStr
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 17
            font.pointSize: 18
            color: "#2C2C2C"
            font.weight: Font.Bold
        }
        Image {
            id: closeimg
            source: "../../images/home_page_slices/home_more_close@2x.png"
            width: 17;height: 17
            anchors.right: parent.right
            anchors.rightMargin: 34
            anchors.verticalCenter: title.verticalCenter
            MouseArea{
                anchors.fill: parent
                onClicked: closeAction()
            }
        }
        Rectangle {
            id: bottomLine
            anchors.top: title.bottom
            anchors.topMargin: 17
            width: parent.width
            height: 1
            color: "#80EAEAEA"
        }
        ListView{
            clip: true
            id: listview
            anchors.top: bottomLine.bottom
            width: parent.width
            height: 3*55
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
                Image {
                    id: img
                    source: JSON.parse(modelData).imagePath
                    width: 20;height: 20
                    anchors.left: parent.left
                    anchors.leftMargin: 34
                    anchors.verticalCenter: parent.verticalCenter
                    ColorOverlay{
                        anchors.fill: parent
                        color: getColor(modelData)
                        source: parent
                    }
                }
                Image {
                    id: arrowimg
                    source: "../../images/home_page_slices/home_more_arrow.png"
                    width: 7;height: 12.5
                    anchors.right: parent.right
                    anchors.rightMargin: 34
                    anchors.verticalCenter: parent.verticalCenter
                    visible: JSON.parse(modelData).index === 2
                }
                Item {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: img.right
                    anchors.leftMargin: 5
                    anchors.right: arrowimg.left
                    anchors.rightMargin: 5
                    Text {
                        text: JSON.parse(modelData).name
                        color: getColor(modelData)
                        elide: Qt.ElideRight
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        anchors.verticalCenter: parent.verticalCenter
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
                        if (getColor(modelData) === "#3C3C3C"){
                            confirmOptionsAction(JSON.parse(list[currentIndex]))
                        }
                    }
                }
            }
        }
    }

    function getColor(modelData){
        console.log("status: "+ JSON.parse(modelData).status)
        console.log("index: "+ JSON.parse(modelData).index)
        console.log("filteringStatus: "+ JSON.parse(modelData).filteringStatus)
        if (JSON.parse(modelData).status === 0
                && JSON.parse(modelData).index !== 2) {
            if (JSON.parse(modelData).index === 1
                    && JSON.parse(modelData).filteringStatus === true) {
                return "#3C3C3C"
            } else {
                return "#C5C5C5"
            }
        } else {
            return "#3C3C3C"
        }
    }

    function closeAction(){
        popup.close()
    }
}

