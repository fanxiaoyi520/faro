import QtQuick 2.0
import Modules 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

GridView {
    property var list: []
    id: grid
    cellWidth:parent.width / 3
    cellHeight: 175
    model: list
    delegate: HomeGridItemView{
        height: grid.cellHeight
        width: grid.cellWidth
        modelData:list[index]
    }
}
