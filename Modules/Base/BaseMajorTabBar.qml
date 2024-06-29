import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

TabBar {

    ListModel{
        id: listModel
        ListElement {
            title: qsTr("房间实测")
            imageNormalStr: "../../images/tabbar_slices/tabbar_home_normal.png"
            imageSelStr: "../../images/tabbar_slices/tabbar_home_sel.png"
        }

        ListElement {
            title: qsTr("测量结果")
            imageNormalStr: "../../images/tabbar_slices/tabbar_result_normal.png"
            imageSelStr: "../../images/tabbar_slices/tabbar_result_sel.png"
        }

        ListElement {
            title: qsTr("上传文件")
            imageNormalStr: "../../images/tabbar_slices/tabbar_home_normal.png"
            imageSelStr: "../../images/tabbar_slices/tabbar_home_sel.png"
        }

        ListElement {
            title: qsTr("系统设置")
            imageNormalStr: "../../images/tabbar_slices/tabbar_setup_normal.png"
            imageSelStr: "../../images/tabbar_slices/tabbar_setup_sel.png"
        }
    }

    signal tabBarAction(int currentIndex)
    id: bar
    width: parent.width
    anchors.bottom: parent.bottom
    height: 79
    background: Rectangle{
        color: "#FFFFFF"
    }
    layer.enabled: true
    layer.effect: DropShadow{
        horizontalOffset: 0
        verticalOffset: -2.5
        radius: 8
        color: "#0A000000"
    }

    onCurrentItemChanged: {
        console.log("tabbar item current selected index: "+currentIndex)

    }

    Repeater {
        model: listModel

        TabButton {
            id: control
            anchors.top: parent.top
            width: bar.width / listModel.count
            height: parent.height
            contentItem: Rectangle{
                anchors.fill: parent
                Image{
                    source: currentIndex === index ? model.imageSelStr : model.imageNormalStr
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 27;height: 27
                    anchors.top: parent.top
                    anchors.topMargin: 6
                }
                Text {
                    width: parent.width
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 30
                    text: model.title
                    color: currentIndex === index ? "#333333" : "#999999"
                    font: control.font
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            background: Rectangle {
                color: "transparent"
            }
            onClicked: tabBarAction(currentIndex)
        }
    }
}

