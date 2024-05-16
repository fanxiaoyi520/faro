import QtQuick 2.0
import Modules 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

StackView{
    id: minestack
    initialItem: mineview
    Component {
        id: mineview
        Rectangle{
            anchors.fill: parent
            BaseNavigationBar{
                id: navigationBar
                title: qsTr("系统设置")
            }
        }
    }
}
