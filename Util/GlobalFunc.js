
const MMProjectStatus = {
    NotTurnedOn: 0,
    InProgress: 1,
    Completed: 2,
    Close: 3,
};


const MMStageType = {
    One: 1,
    Two: 2,
    Three: 3,
    Four: 4,
    Five: 5
};

function getStageTypeStr(modelData){
    switch(modelData.stageType){
    case MMStageType.One:
        return "一阶段"
    case MMStageType.Two:
        return "二阶段"
    case MMStageType.Three:
        return "三阶段"
    case MMStageType.Four:
        return "四阶段"
    case MMStageType.Five:
        return "五阶段"
    default: break
    }

}

function getStageTypeColor(stageType){
    if (stageType) {
        switch(stageType){
        case MMStageType.One:
            return "#1FA3FF"
        case MMStageType.Two:
            return "#FE9623"
        case MMStageType.Three:
            return "#44D7B6"
        case MMStageType.Four:
            return "#32C5FF"
        case MMStageType.Five:
            return "#38BE76"
        default: break
        }
    } else {
        return "#1FA3FF"
    }
}

function setStatusImageSource(modelData){

    if (modelData) {
        var status = modelData.status;
        switch (modelData.status){
        case MMProjectStatus.NotTurnedOn:
            return "../../images/measure_other/measure_ic_not_created@2x.png"
        case MMProjectStatus.InProgress:
            return "../../images/measure_other/measure_ic_progress@2x.png"
        case MMProjectStatus.Completed:
            return "../../images/measure_other/measure_complete@2x.png"
        case MMProjectStatus.Close:
            return "../../images/measure_other/measure_ic_calculation_failed@2x.png"
        default: break
        }
    } else {
        return "../../images/measure_other/measure_ic_not_created@2x.png"
    }
}

function setStatusStr(modelData){

    if (modelData && modelData.reduceItem) {
        var status = modelData.reduceItem.status;
        switch (modelData.reduceItem.status){
        case MMProjectStatus.NotTurnedOn:
            return "未开启"
        case MMProjectStatus.InProgress:
            return "进行中"
        case MMProjectStatus.Completed:
            return "已完成"
        case MMProjectStatus.Close:
            return "已关闭"
        default: break
        }
    } else {
        return "未开启"
    }
}
