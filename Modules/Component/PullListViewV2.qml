import QtQuick 2.0
ListView {
    id: listView

    property bool headerVisible: false
    property bool footerVisible: false
    property bool headerHold: false
    property bool footerHold: false

    enum MoveDirection{
        NoMove,
        UpToDown,
        DownToUp
    }
    property int moveDirection: PullListViewV2.NoMove
    property real moveStartContentY: 0

    onHeaderVisibleChanged: if(!headerVisible) {headerHold = false}
    onFooterVisibleChanged: if(!footerVisible) {footerHold = false}
    onContentYChanged: {
        if(dragging || flicking)
        {
            moveDirection = (contentY - moveStartContentY < 0) ? PullListViewV2.UpToDown : PullListViewV2.DownToUp
//            console.log("onContentYChanged:",atYBeginning,moveDirection,headerVisible)
            switch(moveDirection){
            case PullListViewV2.UpToDown:{
                if(atYBeginning && !headerVisible && !footerVisible) {
                    headerVisible = true
                }
            }break;
            case PullListViewV2.DownToUp:{
                if(atYEnd && !headerVisible && !footerVisible) {
                    footerVisible = true
                }
            }break;
            default:break;
            }
        }
    }

    //鼠标或手指拖动驱动的界面滚动
    onDraggingChanged: dragging ? pullStart() : pullEnd()
    //鼠标滚动驱动的view滚动
    onFlickingChanged: flicking ? pullStart() : pullEnd()

    function pullStart(){
        console.log("pullStart")
        moveStartContentY = contentY
    }

    function pullEnd(){
//        console.log("pullEnd:",atYBeginning,moveDirection,headerVisible,contentY - moveStartContentY)

        switch(moveDirection){
        case PullListViewV2.UpToDown:{
            if(atYBeginning && headerVisible) {
                headerHold = true
            }else if(null !== headerItem){
                headerVisible = false
                headerHold = false
            }

        }break;
        case PullListViewV2.DownToUp:{
            if(atYEnd && footerVisible) {
                footerHold = true
            }else if(null !== footerItem){
                footerVisible = false
                footerHold = false
            }
        }break;
        default:break;
        }

        moveDirection = PullListViewV2.NoMove
    }
}

