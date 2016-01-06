import bb.cascades 1.4
import bb.system 1.2
import bb.device 1.4
import "moment.js" as Moment
Page {
    onCreationCompleted: {
        Application.setCover(logincover)
    }
    function returnImage() {
        console.log(JSON.stringify(hardware))
        switch (hardware.modelName) {
            case "Z10":
            case "Z30":
            case "P'9982":
                return "asset:///Images/login_images/login_z10.png"
                break
            case "Q10":
            case "Q5":
            case "Classic":
                return "asset:///Images/login_images/login_q10.png"
                break
            case "Passport":
                return "asset:///Images/login_images/login_passport.png"
                break
        }
    }
    property variant token
    property variant endpoint: "https://app.asana.com/api/1.0/"
    property int workspacecount: 0
    property int projectcount: 0
    property int taskcount: 0
    Container {
        layout: DockLayout {
        }
        verticalAlignment: VerticalAlignment.Fill
        Container {
            layout: AbsoluteLayout {
            }
            ImageView {
                imageSource: returnImage()
                scalingMethod: ScalingMethod.Fill
            }
        }
        Container {
            visible: true
            id: initial
            leftMargin: 20.0
            rightMargin: 20.0
            leftPadding: 20.0
            rightPadding: 20.0
            topMargin: 20.0
            topPadding: 50.0
            bottomPadding: 50.0
            layout: StackLayout {
            }
            verticalAlignment: VerticalAlignment.Center
            horizontalAlignment: HorizontalAlignment.Fill
            background: Color.create("#73ffff00")
            Label {
                text: qsTr("Banana")
                textStyle.fontStyle: FontStyle.Italic
                textStyle.fontSize: FontSize.XXLarge
                textStyle.fontWeight: FontWeight.Normal
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                textStyle.color: Color.Black
            }
            Label {
                text: qsTr("Asana Client for BlackBerry 10")
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                textStyle.color: Color.Black
                textStyle.fontStyle: FontStyle.Italic
            }
            Label {
                text: qsTr("You have to login using API KEY provided by ASANA")
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                textStyle.color: Color.Black
                textStyle.fontStyle: FontStyle.Italic
            }
            Label {
                text: qsTr("Go to Account Settings > APPS > API Key")
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                textStyle.color: Color.Black
                textStyle.fontStyle: FontStyle.Italic
            }
            Label {
                text: qsTr("Enter the API Key here to Login")
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                textStyle.color: Color.Black
                textStyle.fontStyle: FontStyle.Italic
            }
            Container {
                horizontalAlignment: HorizontalAlignment.Center
                background: Color.create("#76ffffff")
                TextField {
                    id: key
                    hintText: qsTr("Api Key")
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Center
                    maxWidth: ui.du(60)
                    topMargin: ui.du(10.0)
                    textStyle.color: Color.Black
                    clearButtonVisible: true
                    backgroundVisible: false
                    visible: true
                    textStyle.fontStyle: FontStyle.Italic
                }
            }
            ActivityIndicator {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                visible: false
                id: login_indicator
                
            }
            Button {
                
                preferredWidth: ui.du(20)
                text: qsTr("Login")
                onClicked: {
                    login_indicator.running=true
                    login_indicator.visible=true
                    var base = app.covertToBase64(key.text)
                    console.log(base, "------", key.text)
                    token = base
                    login()
                }
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                color: Color.create("#72ffff00")
            }
        }
    }
    function login() {
        var doc = new XMLHttpRequest();
        var url = endpoint + "users/me"
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var info = JSON.parse(doc.responseText).data
                    app.insertSettings("id", info.id)
                    app.insertSettings("name", info.name)
                    app.insertSettings("email", info.email)
                    app.authkeysuccess(key.text)
                    correct.show()
                    login_indicator.stop()
                } else {
                    error.show()
                    app.scrapData()
                }
            }
        }
        doc.open("get", url);
        doc.setRequestHeader("Authorization", "Basic " + token);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send();
    }
    attachedObjects: [
        SystemToast {
            id: error
            body: qsTr("Entered API key is wrong")
        },
        SystemToast {
            id: correct
            body: qsTr("Login succesful")
        },
        MultiCover {
            ApplicationViewCover {
                MultiCover.level: CoverDetailLevel.Medium
                id: appViewCover
            }
            SceneCover {
                id: logincover
                MultiCover.level: CoverDetailLevel.High
                content: Container {
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Center
                    layout: DockLayout {
                    }
                    background: Color.Yellow
                    Label {
                        horizontalAlignment: HorizontalAlignment.Center
                        verticalAlignment: VerticalAlignment.Center
                        text: qsTr("No User Signed In")
                        textStyle.color: Color.Black
                    }
                }
            }
        },
        HardwareInfo {
            id: hardware
        },
        DisplayInfo {
            id: displayInfo
        }
    ]
}
