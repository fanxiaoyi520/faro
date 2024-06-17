import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

Rectangle {
    property var cellModel
    property bool isControlLaunch1: false
    property bool isControlLaunch2: false
    property double cellExpandAddHeight: 80
    /**
     * select measure mode params
     * @masonry_mode    识别砌体
     * @xy_crop_dist    平面
     * @z_crop_dist     高度
     * @map_mode        测量下尺模式
     * @scanningMode    扫描密度
     */

    property int sub_masonry_mode: 0
    property int sub_xy_crop_dist: 6
    property int sub_z_crop_dist: 3
    property int sub_map_mode: 1
    property string sub_scanningMode: "1/20"
    property int sub_scanningIndex: 7

    id: basecellid
    width: parent.width
    height: getChangeHeight(cellModel.index)
    Loader{
        id: loaderComponent
        sourceComponent: distinguishCellTypes(model.index)
    }
    Component{
        id: cell1Component
        BaseModeCell{
            id: cell1
            width: basecellid.width
            height: 50
            model: cellModel
            Switch {
                id: poposwitch
                anchors.top: cell1.celltitle.top
                anchors.right: parent.right
                anchors.rightMargin: 24
                width: 32
                height: 22
                onCheckedChanged: switchAction(checked)
            }
        }
    }
    Component{
        id: cell2Component
        BaseModeCell{
            width: basecellid.width
            height: 50
            model: cellModel
            TextField{
                id: input
                height: 30
                anchors.right: parent.right
                anchors.rightMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width * 0.15
                text: cellModel.index === 1 ? sub_xy_crop_dist : sub_z_crop_dist
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.capitalization: Font.MixedCase
                font.pixelSize: 15
                background: Rectangle{
                    radius: 10
                    color: "transparent"
                    border.color: "#80EAEAEA"
                }
                validator: IntValidator { id: intValidator;bottom: 1; top: 50}

                onTextChanged: {
                    var text = this.text;
                    var intValue = parseInt(text, 10)

                    if (!isNaN(intValue) && intValue >= 1 && intValue <= 50) {
                        // 值有效，不需要做任何事
                    } else {
                        if (isNaN(intValue) || intValue < 1) {
                            //this.text = "1";
                        } else if (intValue > 50) {
                            this.text = "50";
                        }
                    }
                    onInputTextChanged(cellModel.index,this.text)
                }
            }
        }
    }
    Component{
        id: cell3Component
        BaseModeCell{
            id: cell3
            width: basecellid.width
            height: getChangeHeight(cellModel.index)
            model: cellModel
            lineviewY: getChangeHeight(cellModel.index)-1
            Image {
                id: arrowimg
                source: isControlLaunch1 ? "../../images/home_page_slices/home_measure_up_arrow@2x.png" : "../../images/home_page_slices/home_measure_right_arrow@2x.png"
                width: isControlLaunch1 ? 12.5 : 7
                height: isControlLaunch1 ? 7 : 12.5
                anchors.right: parent.right
                anchors.rightMargin: 24
                anchors.top: cell3.celltitle.top
            }
            SelectMeasureListButtonView{
                id: selectMeasureListButtonView
                list: ["精简","标准","详细","全部"]
                anchors.top: cell3.celltitle.bottom
                anchors.topMargin: 12
                visible: isControlLaunch1 ? true : false
                selectIndex: sub_map_mode
                onClickSelectAction: measureTheBottomRulerMode(index,model)
            }
        }
    }
    Component{
        id: cell4Component
        BaseModeCell{
            id: cell4
            width: basecellid.width
            height: getChangeHeight(cellModel.index)
            model: cellModel
            lineviewY: getChangeHeight(cellModel.index)-1
            Image {
                id: arrowimg
                source: isControlLaunch2 ? "../../images/home_page_slices/home_measure_up_arrow@2x.png" : "../../images/home_page_slices/home_measure_right_arrow@2x.png"
                width: isControlLaunch2 ? 12.5 : 7
                height: isControlLaunch2 ? 7 : 12.5
                anchors.right: parent.right
                anchors.rightMargin: 24
                anchors.top: cell4.celltitle.top
            }
            SelectMeasureListButtonView{
                id: selectMeasureListButtonView
                list: ["1/1","1/2","1/4","1/5","1/8","1/10","1/16","1/20","1/32"]
                anchors.top: cell4.celltitle.bottom
                anchors.topMargin: 12
                visible: isControlLaunch2 ? true : false
                selectIndex: sub_scanningIndex-1
                onClickSelectAction: scanningDensity(index,model)
            }
        }
    }
    MouseArea{
        anchors.fill: parent
        propagateComposedEvents: true
        z: -1
        onClicked: {
            handleCellClick(index)
        }
    }

    function handleCellClick(index){
        console.log("current selected cell: "+index)
        if(index === 3) {
            isControlLaunch1 = !isControlLaunch1
            return
        }
        if(index === 4) {
            isControlLaunch2 = !isControlLaunch2
            return
        }
        return
    }

    function getChangeHeight(index){
        if (index === 3 && isControlLaunch1 === true){
            return 50+cellExpandAddHeight
        }
        if (index === 4 && isControlLaunch2 === true){
            return 50+cellExpandAddHeight
        }
        return 50
    }

    function distinguishCellTypes(index){
        console.log("select measure type cell index: "+index)
        if(index < 1) {
            return cell1Component
        } else if (index <= 2){
            return cell2Component
        }else if (index === 3) {
            return cell3Component
        } else {
            return cell4Component
        }
    }

    function switchAction(checked){
        parent_switchAction(checked)
    }

    function measureTheBottomRulerMode(index,model){
        parent_measureTheBottomRulerMode(index,model)
    }

    function onInputTextChanged(index,text){
        parent_onInputTextChanged(index,text)
    }

    function scanningDensity(index,model){
        parent_scanningDensity(index,model)
    }
}






