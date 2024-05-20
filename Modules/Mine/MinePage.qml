import QtQuick 2.0
import Modules 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "../../String_Zh_Cn.js" as SettingString

StackView{
    id: minestack
    initialItem: mineview
    Component {
        id: mineview
        Rectangle{
            id:root
            anchors.fill: parent
            color: "white"
            BaseNavigationBar{
                id: navigationBar
                title: qsTr("系统设置")
                isVisibleBackBtn: false
            }

            ScrollView{
                id:scrollview
                anchors.top: navigationBar.bottom
                anchors.topMargin: 4
                width: parent.width
                height: root.height - navigationBar.height + 4

                Column{
                    id:column
                    width: parent.width
                    Repeater{
                        model: SettingString.setting_lists.length
                        delegate:SettingItem{
                            settingInfo: JSON.parse(SettingString.setting_lists[index])
                            iconPath : ""
                            onItemClick : function(){
                                console.log("click item :" + index)
                                //TODO 每个item不同的事件
                            }
                            showDive: index != SettingString.setting_lists.length - 1
                        }
                    }
                }

                Rectangle{
                    anchors.top: column.bottom
                    width: parent.width
                    height: scrollview.height - column.height
                    color: "#f3f3f3"

                    Rectangle{
                        id:rect_logout
                        anchors.top: parent.top
                        anchors.topMargin: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 120
                        height: 32
                        color: "white"
                        border.color: "#999999"
                        border.width: 0.5
                        radius: 10

                        Text{
                            anchors.centerIn: parent
                            text: SettingString.setting_logout
                        }

                        MouseArea{
                            anchors.fill: parent
                            onPressed: {
                                rect_logout.color = "cyan"
                            }
                            onReleased: {
                                rect_logout.color = "white"
                            }
                        }
                    }
                }
            }
        }
    }
}
