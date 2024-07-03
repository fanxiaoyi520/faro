import QtQuick 2.12
import "../../String_Zh_Cn.js" as String
import "../../Util/GlobalFunc.js" as GlobalFunc

Column{
    id:column_itemview
    property var datas: []
    property var uploadItemItem: []
    width: parent.width
    spacing: 0
    Text {
        id: text_project_name
        text: (datas.length > 0)? (GlobalFunc.isEmpty(JSON.parse(datas[0]).projectName) ? "" : JSON.parse(datas[0]).projectName) : ""
        font.pixelSize: 16
        font.bold: true
    }
    Rectangle{
        height: 8
        width: parent.width
    }

    Text {
        id: text_sub_name
        font.pixelSize: 16
        Component.onCompleted: {
            var dataItem = JSON.parse(datas[0])
            console.log("itemview datas = " + datas.length)
            console.log("itemview datas Index = " + index)
            console.log("itemview datas jsonString = " + JSON.stringify(datas[0]))
            if (GlobalFunc.isJson(datas[0])){
                var stageType = JSON.parse(String.stageType[JSON.parse(datas[0]).stageType - 1]).name
                var typeName = String.result_task_type_room
                text_sub_name.text = dataItem.blockName + "_" + dataItem.unitName + "_"+ dataItem.floorName + "_"+ dataItem.roomName + "_"+ typeName + "_"+ stageType
            }
        }
    }

    Rectangle{
        height: 8
        width: parent.width
    }

    Repeater{
        width: parent.width
        model: datas.length
        delegate: UploadItemItemView{
            id:uploaditemitem
            fileInfo : JSON.parse(datas[index])
            Component.onCompleted: {
                uploadItemItem.push(uploaditemitem)
            }
        }
    }
}
