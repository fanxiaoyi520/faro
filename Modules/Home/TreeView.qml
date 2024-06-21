import QtQuick 2.7
import QtQuick.Controls 2.7

//代码仅供参考，很多地方都不完善
//还有一些样式没有导出，可以根据需求自己定义
//因为ListView有回收策略，除非cacheBuffer设置很大，所以状态不能保存在delegate.item中
//需要用外部变量或者model来存储delegate.item的状态
Rectangle {
    id: control

    property string currentItem //当前选中item

    property int spacing: 25    //项之间距离
    property int indent: 16 * 2     //子项缩进距离,注意实际还有icon的距离
    property string onSrc: "qrc:/img/on.png"
    property string offSrc: "qrc:/img/off.png"
    property string checkedSrc: "qrc:/img/check.png"
    property string uncheckSrc: "qrc:/img/uncheck.png"

    property var checkedArray: [] //当前已勾选的items
    property bool autoExpand: false

    //背景
    color: "#FFFFFF"
    property alias model: list_view.model
    ListView {
        id: list_view
        anchors.fill: parent
        //anchors.margins: 10
        //model: //model由外部设置，通过解析json
        property string viewFlag: ""
        delegate: list_delegate
        clip: true
        onModelChanged: {
            console.log('model change')
            checkedArray=[]; //model切换的时候把之前的选中列表清空
        }
    }
    Component {
        id: list_delegate
        Row{
            id: list_itemgroup
            //spacing: 5
            property string parentFlag: ListView.view.viewFlag
            //以字符串来标记item
            //字符串内容为parent.itemFlag+model.index
            property string itemFlag: parentFlag+"-"+(model.index+1)

            //项内容：包含一行item和子项的listview
            Column {
                id: list_itemcol

                //这一项的内容，这里只加了一个text
                Row {
                    id: list_itemrow
                    width: control.width
                    height: item_text.contentHeight+control.spacing
                    //spacing: 5

                    Rectangle {
                        id: rect
                        property bool checked: isChecked(itemFlag)
                        height: item_text.contentHeight+control.spacing
                        width: parent.width
                        anchors.verticalCenter: parent.verticalCenter
                        color: (control.currentItem===itemFlag)
                               ?"#1A808080"
                               :"transparent"

                        Text {
                            id: item_text
                            anchors.left: parent.left
                            anchors.leftMargin: 30
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.name
                            font.pixelSize: 16
                            font.family: "Microsoft YaHei UI"
                            color: "#3C3C3C"
                        }

                        Canvas {
                            id: lineview
                            width: parent.width
                            height: 1
                            y:item_text.contentHeight+control.spacing-1
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

                        Image {
                            id: item_direction_image
                            source: item_sub.visible && item_repeater.count ? "../../images/home_page_slices/home_search_up.png" : "../../images/home_page_slices/home_search_down.png"
                            visible: modelData.children ? true : false
                            anchors{
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                                rightMargin: getImageRightMargin(itemFlag)
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                control.currentItem=itemFlag;
                                console.log("selected",itemFlag)
                                if(item_repeater.count){
                                    item_sub.visible=!item_sub.visible;
//                                    modelData.isExpand = !modelData.isExpand
                                }
                                if (!modelData.children) {
                                    sureSelectedSearchResult(modelData)
                                }
                                /**
                                rect.checked=!rect.checked;
                                if(rect.checked){
                                    check(itemFlag);
                                }else{
                                    uncheck(itemFlag);
                                }
                                var str="checked ";
                                for(var i in checkedArray)
                                    str+=String(checkedArray[i])+" ";
                                console.log(str)
                                */
                            }
                        }
                    }

                    Component.onCompleted: {
                        if(modelData.istitle){
                            item_titleicon.visible=true;
                        }else if(modelData.isoption){
                            item_optionicon.visible=true;
                        }
                    }
                }

                //放子项
                Column {
                    id: item_sub
                    //也可以像check一样用一个expand数组保存展开状态
                    visible: (modelData === undefined) ? modelData.isExpand : false
                    //上级左侧距离=小图标宽+x偏移
                    x: control.indent
                    width: parent.width-control.indent
                    Item {
                        width: 10
                        height: item_repeater.contentHeight
                        //需要加个item来撑开，如果用Repeator获取不到count
                        ListView {
                            id: item_repeater
                            anchors.fill: parent
                            delegate: list_delegate
                            model: modelData.children
                            property string viewFlag: itemFlag
                        }
                    }
                    Component.onCompleted: {
                        console.log("item expand = " + modelData.isExpand)
                        console.log("item expand = " + modelData.name)
                    }
                }
            }
        }//end list_itemgroup
    }//end list_delegate

    function getItemFlagLength(itemFlag){
        let arrayResult = itemFlag.split("-");
        let filteredArray = arrayResult.filter(function(element) {
            return element.trim() !== "";
        });
        return filteredArray.length
    }

    function getImageRightMargin(itemFlag){
        let length = getItemFlagLength(itemFlag)
        return 30 * length
    }

    //勾选时放入arr中
    function check(itemFlag){
        checkedArray.push(itemFlag);
    }

    //取消勾选时从arr移除
    function uncheck(itemFlag){
        var i = checkedArray.length;

        while (i--) {
            if (checkedArray[i] === itemFlag) {
                checkedArray.splice(i,1);
                break;
            }
        }
    }

    //判断是否check
    function isChecked(itemFlag){
        var i = checkedArray.length;

        while (i--) {
            if (checkedArray[i] === itemFlag) {
                return true;
            }
        }
        return false;
    }
}
