import QtQuick 2.0
import Modules 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

StackView{
    id: resultstack
    initialItem: resultview
    Component {
        id: resultview
        Rectangle{
            anchors.fill: parent
            BaseNavigationBar{
                id: navigationBar
                title: qsTr("测量结果")
            }
        }
    }
}
