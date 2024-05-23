import QtQuick 2.0
import Modules 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "../../String_Zh_Cn.js" as SettingString

StackView{
    id: minestack
    property var mineStack: minestack
    initialItem: mineview
    Component {
        id: mineview
        Rectangle{
            id:root
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "white"
            TipsPopUp{
                id:mineTipsPop
                onConfirmAction: {
                    while (mineStack.depth > 1) {
                        mineStack.pop();
                    }
                    rootWindow.toggleView()
                    settingsManager.setValue(settingsManager.user,null)
                }
            }

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
                         property var loaded: false

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
                            onClicked: {
                                mineTipsPop.tipsContentStr = qsTr(SettingString.setting_logout_tips)
                                mineTipsPop.open()
                            }
                        }
                    }
                }
            }
        }
    }
}
