import QtQuick 2.0  
import QtQuick.Controls 2.12

Item {
    width: parent.width

    TextField {
        id: searchField
        anchors.fill: parent
        anchors {
            leftMargin: 16
            rightMargin: focus ? 72+16 : 16
            topMargin: 17
            bottomMargin: 12
        }
        leftPadding: searchIcon.width + 26
        Image {
            id: searchIcon
            source: "../../images/home_page_slices/measure_search.png"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 16
            width: 20
            height: 20
        }
        placeholderText: qsTr("输入城市公司、项目名可快速搜索")
        placeholderTextColor: "#999999"
        font.pointSize: 16
        color: "#3C3C3C"
        focus: false
        background: Rectangle {
            anchors.fill: parent
            color: "#F2F2F2"
            radius: 5
        }
        onTextChanged: {
            console.log("搜索内容:", text)
        }
    }

    Button {
        id: searchButton
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: searchField.right
        anchors.leftMargin: 6
        visible: searchField.focus ? true : false
        Text{
            color: "#1FA3FF"
            text: qsTr("取消")
            font.pixelSize: 16
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
        width: 60
        height: 30
        background: Rectangle{
            color: "transparent"
        }
        onClicked: {
            console.log("搜索按钮被点击，搜索内容:", searchField.text)
        }
    }
    Canvas {
        id: lineview
        width: parent.width
        height: 1
        y:72
        property color lineColor: "#80EAEAEA"
        property int lineWidth: 1

        onPaint: {
            var ctx = getContext("2d");
            ctx.strokeStyle = lineColor;
            ctx.lineWidth = lineWidth;
            ctx.beginPath();
            ctx.moveTo(0, 1);
            ctx.lineTo(parent.width, 1);
            ctx.stroke();
        }
    }
}
