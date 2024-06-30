import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.5
import Dialog 1.0
import Api 1.0
import Http 1.0
import QtEnumClass 1.0
import "../String_Zh_Cn.js" as Settings
Rectangle{
    signal completeLogin()
    property alias loginbtn: loginbtn
    property var tenant_id: "1"
    property string loginName: Settings.normal_mode
    property int currentRow: 0

    Toast {id: toastPopup}
    Http {id: http}
    LoginDialog{
        id: dialog
        onConfirmOptionsAction: {
            console.log("dialog selected data: " + JSON.stringify(model))
            hub.open()
            getLoginToken(model.id)
        }
    }
    Hub{id: hub}

    //登录模式
    LoginModeSelectionDialog {
        id: loginModeDialog
        titleStr: qsTr(Settings.login_mode)
        list: Settings.loginMode
        onConfirmOptionsAction: loginModelSelection(model)
    }

    Rectangle{
        id: loginModeBtn
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 12
        height: 34
        width: parent.width *  0.25
        radius: 17
        color: "#F7F7F7"
        z: 10
        Text{
            id: subtext
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr(loginName)
            color: "#666666"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                loginModeDialog.list = Settings.loginMode
                loginModeDialog.open()
            }
        }
    }

    Rectangle{
        width: 640
        height: 400
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Image {
            id: logoimage
            source: "../images/login_logo.png"
            width: 222;height: 81.5
            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
        }


        LoginTextField {
            id: accountfield
            anchors.top: logoimage.bottom
            anchors.topMargin: 57
            inputfield.focus: true
            Keys.onBacktabPressed: passwordfield
            inputfield.placeholderText: qsTr("请输入账号")
            leftimage.source: "../images/login_user.png"
            rightimage.source: "../images/login_close.png"
            focus: true
            inputfield.maximumLength: 11
            inputfield.inputMethodHints: Qt.ImhDigits | Qt.ImhFormattedNumbersOnly
            inputfield.validator: RegExpValidator {
                regExp: /^[A-Za-z0-9]+$/
            }
        }

        LoginTextField {
            id: passwordfield
            anchors.top: accountfield.bottom
            anchors.topMargin: 24
            inputfield.focus: true
            inputfield.placeholderText: qsTr("请输入密码")
            Keys.onBacktabPressed: accountfield
            leftimage.source: "../images/login_lock.png"
            rightimage.source: "../images/login_close.png"
            inputfield.validator: RegExpValidator {
                regExp: /[a-zA-Z0-9-]+/
            }
            inputfield.echoMode: TextInput.Password
        }

        Button{
            id: loginbtn
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            width: 320
            height: 53
            text: qsTr("登录")
            font.capitalization: Font.MixedCase
            font.pixelSize: 18
            highlighted: true
            palette.buttonText: "#FFFFFF"
            background: Rectangle{
                id: btnrect
                color: "#1890FF"
                radius: 12
            }
            layer.enabled: true
            layer.effect: DropShadow{
                horizontalOffset: 0
                verticalOffset: 12
                radius: 50
                color: "#1A1890FF"
            }
            onClicked: login()
        }
    }

    Timer {
        id:timer_logintoken
        interval: 200
        onTriggered: {
            hub.close()
            getUserDetail()
        }
    }

    Timer {
        id:timer_userdetail
        property var tenant_id
        interval: 200
        onTriggered: {
            getById(tenant_id)
        }
    }

    function login(){
        if(accountfield.inputfield.text === '') {
            toastPopup.text = "手机号不能为空"
            return
        }
        if(passwordfield.inputfield.text === '') {
            toastPopup.text = "密码不能为空"
            return
        }

        get()
    }

    //MARK: Func
    function loginModelSelection(model) {
        loginName = model.name
        currentRow = model.index
        if (model.index === 0) {
            settingsManager.setValue(settingsManager.LoginMode,QtEnumClass.Ordinary)
        } else {
            settingsManager.setValue(settingsManager.LoginMode,QtEnumClass.Major)
        }
        console.log("aaaaaaaaaa: "+        settingsManager.getValue(settingsManager.LoginMode)
)
    }

    //MARK: Net
    function get(){
        function onReply(reply){
            console.log(reply)
            http.onReplySucSignal.disconnect(onReply)
            http.replyFailSignal.disconnect(onFail)
            var response = JSON.parse(reply)
            if (response.data.length > 1) {
                dialog.list = response.data
                dialog.open()
            } else if(response.data.length === 1){
                var tenantModel = response.data[0]
                getLoginToken(tenantModel.id)
            } else {
                getLoginToken("1")
            }
        }

        function onFail(reply,code){
            console.log(reply,code)
             http.onReplySucSignal.disconnect(onReply)
            http.replyFailSignal.disconnect(onFail)
        }

        http.onReplySucSignal.connect(onReply)
        http.replyFailSignal.connect(onFail)
        http.get(Api.admin_tenant_queryTenantByUserName,{"username":accountfield.inputfield.text})
    }

    function getLoginToken(tenantId){
        function onLoginTokenReply(reply){
            console.log("LoginTokenReply: "+reply)
            console.log("reply length: "+reply.length)
            var paseLongToString = substringToComma(reply , reply.indexOf("user_id"))
            var newPaseLongToString = paseLongToString.replace(paseLongToString.substring(9,paseLongToString.length),"\"" + paseLongToString.substring(9,paseLongToString.length) + "\"")
            reply = reply.replace(paseLongToString,newPaseLongToString)
            console.log("paseLongToString" + paseLongToString)
            console.log("LoginTokenReply: "+ reply)
            http.replyFailSignal.disconnect(onFail)
            http.onReplySucSignal.disconnect(onLoginTokenReply)
            var user1 = JSON.parse(reply)
            user1.account = accountfield.inputfield.text
            user1.loginMode = 0
            user1.tenant_id = tenant_id.toString()
            console.log("user_id = " + user1.user_id)
            console.log("loginToken setUser = " + JSON.stringify(user1))
            settingsManager.setValue(settingsManager.user,JSON.stringify(user1))
            completeLogin()
//            timer_logintoken.start()
        }

        function onFail(reply,code){
            hub.close()
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            http.onReplySucSignal.disconnect(onLoginTokenReply)
            toastPopup.text = "手机号或密码错误"
        }

        function substringToComma(str, index) {
            if (index < 0 || index >= str.length) {
                throw new Error("Index out of bounds");
            }
            let endIndex = str.indexOf(",", index);
            if (endIndex === -1) {
                endIndex = str.length;
            }
            return str.substring(index, endIndex);
        }

        tenant_id = tenantId
        console.log("tenant_id: "+tenant_id)
        http.onReplySucSignal.connect(onLoginTokenReply)
        http.replyFailSignal.connect(onFail)
        http.loginPost(Api.auth_oauth_token,{"username":accountfield.inputfield.text,"password":passwordfield.inputfield.text},
                       {"Tenant-id":tenant_id})
    }

    function getUserDetail(){
        function onUserReply(reply){
            console.log("getUserDetail: "+reply)
            http.replyFailSignal.disconnect(onFail)
             http.onReplySucSignal.disconnect(onUserReply)
            var response = JSON.parse(reply)
            var user = JSON.parse(settingsManager.getValue(settingsManager.user))
            user.userinfo = JSON.stringify(response.data)
            settingsManager.setValue(settingsManager.user,JSON.stringify(user))
            timer_userdetail.tenant_id = user.tenant_id
            timer_userdetail.start()
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
             http.onReplySucSignal.disconnect(onUserReply)
        }

        var user = JSON.parse(settingsManager.getValue(settingsManager.user))
        console.log("userid: " + user.user_id)
        http.onReplySucSignal.connect(onUserReply)
        http.replyFailSignal.connect(onFail)
        http.get(Api.admin_user_details+"/"+user.user_id)
    }

    function getById(tenant_id){
        function onByIdReply(reply){
            http.replyFailSignal.disconnect(onFail)
            http.onReplySucSignal.disconnect(onByIdReply)
            var response = JSON.parse(reply)
            var user = JSON.parse(settingsManager.getValue(settingsManager.user))
            user.company = response.data.name
            settingsManager.setValue(settingsManager.user,JSON.stringify(user))
            console.log("complete user data: "+settingsManager.getValue(settingsManager.user))
            completeLogin()
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            http.onReplySucSignal.disconnect(onByIdReply)
        }

//        var user = JSON.parse(settingsManager.getValue(settingsManager.user))
//        console.log("userid: " + user.user_id)
        http.onReplySucSignal.connect(onByIdReply)
        http.replyFailSignal.connect(onFail)
        console.log("user.userinfo.tenantId: "+ tenant_id)
        http.get(Api.admin_tenant_details+"/"+tenant_id)
    }
}

