import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

Rectangle{
    width: parent.width
    height: 50

    property var model
    property double lineviewY: 49
    property alias celltitle: celltitle
    property alias cellLineView: cellLineView

    Text {
        id: celltitle
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 15
        font.pixelSize: 15
        height: font.pixelSize + 15*2
        color: "#3C3C3C"
        text: qsTr(model.name)
    }
    Rectangle {
        id: cellLineView
        y: lineviewY
        width: parent.width
        height: 1
        color: "#80EAEAEA"
    }
}





