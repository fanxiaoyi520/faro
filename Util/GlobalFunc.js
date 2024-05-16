


function getStageTypeStr(modelData){
    switch(modelData.stageType){
    case GlobalEnum.MMStageType.One:
        return "一阶段"
    case GlobalEnum.MMStageType.Two:
        return "二阶段"
    case GlobalEnum.MMStageType.Three:
        return "三阶段"
    case GlobalEnum.MMStageType.Four:
        return "四阶段"
    case GlobalEnum.MMStageType.Five:
        return "五阶段"
    default: break
    }

}

function getStageTypeColor(modelData){
    switch(modelData.stageType){
    case GlobalEnum.MMStageType.One:
        return "#1FA3FF"
    case GlobalEnum.MMStageType.Two:
        return "#FE9623"
    case GlobalEnum.MMStageType.Three:
        return "#44D7B6"
    case GlobalEnum.MMStageType.Four:
        return "#32C5FF"
    case GlobalEnum.MMStageType.Five:
        return "#38BE76"
    default: break
    }
}

function setStatusImageSource(modelData){

//    if (modelData && modelData.reduceItem) {
//        var status = modelData.reduceItem.status;
//        switch (modelData.reduceItem.status){
//        case GlobalEnum.MMProjectStatus.NotTurnedOn:
//            return "../../images/measure_other/measure_ic_not_created@2x.png"
//        case GlobalEnum.MMProjectStatus.InProgress:
//            return "../../images/measure_other/measure_ic_progress@2x.png"
//        case GlobalEnum.MMProjectStatus.Completed:
//            return "../../images/measure_other/measure_complete@2x.png"
//        case GlobalEnum.MMProjectStatus.Close:
//            return "../../images/measure_other/measure_ic_calculation_failed@2x.png"
//        default: break
//        }
//    } else {
//        return "../../images/measure_other/measure_ic_not_created@2x.png"
//    }
return "../../images/measure_other/measure_ic_not_created@2x.png"
}

function setStatusStr(modelData){

    if (modelData && modelData.reduceItem) {
        var status = modelData.reduceItem.status;
        switch (modelData.reduceItem.status){
        case GlobalEnum.MMProjectStatus.NotTurnedOn:
            return "未开启"
        case GlobalEnum.MMProjectStatus.InProgress:
            return "进行中"
        case GlobalEnum.MMProjectStatus.Completed:
            return "已完成"
        case GlobalEnum.MMProjectStatus.Close:
            return "已关闭"
        default: break
        }
    } else {
        return "未开启"
    }
}
