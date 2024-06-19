import QtQuick 2.0
import Modules 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

Item {
    property string titlestr: "一阶段"
    property color progresscolor:"#1FA3FF"
    property int finishRoomCount:0
    property int totalRoomCount:0

    property var titleWidth: 0
    property var footertitleWidth: 0
    property font font: Qt.font({ family: "Helvetica", pointSize: 12 })
    Component.onCompleted: {
        var tempText = Qt.createQmlObject('import QtQuick 2.0; Text { text: parent.titlestr; font: parent.font; visible: false }', this);
        var footertitleText = Qt.createQmlObject('import QtQuick 2.0; Text { text: "2/5"; font: parent.font; visible: false }', this);
        tempText.parent = this;
        footertitleText.parent = this;
        titleWidth = tempText.contentWidth;
        footertitleWidth = footertitleText.contentWidth;
        tempText.destroy();
        footertitleText.destroy();
    }

    Text{
        id: title
        text: titlestr
        elide: Qt.ElideRight
        wrapMode: Text.NoWrap
        width: titleWidth
        font: font
        anchors {
            left: parent.left
            leftMargin: 11
            verticalCenter: parent.verticalCenter
        }
    }


    TextEdit {
        id: footertitle
        text: finishRoomCount.toString() +"/" + totalRoomCount.toString()
        color: progresscolor
        wrapMode: Text.NoWrap
        font: font
        anchors {
            //left: progress.right
            leftMargin: 6
            right: parent.right
            rightMargin: 11
            verticalCenter: parent.verticalCenter
        }
    }

    Rectangle{
        id: progress
        height: 5
        //width: parent.width-11*2-titleWidth-6*2-footertitleWidth
        color: "#F5F5F5"
        radius: 2.5
        anchors {
            verticalCenter: parent.verticalCenter
            left: title.right
            right: footertitle.left
            rightMargin: 6
            leftMargin: 6
        }
        Rectangle{
            id: currentprogress
            height: 5
            width: parent.width * (finishRoomCount / totalRoomCount)
            color: progresscolor
            radius: 2.5
        }
    }
}
