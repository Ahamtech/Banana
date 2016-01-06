import bb.cascades 1.4
import bb.system 1.2

Page {
    function createcolor(data) {
        return Color.create(data)
    }
    titleBar: TitleBar {
        title: qsTr("Settings")

    }
    Container {

        Header {
            title: qsTr("Display") + Retranslate.onLanguageChanged
        }
        Container {
            leftPadding: ui.du(3)
            topPadding: 20.0
            horizontalAlignment: HorizontalAlignment.Fill
            bottomPadding: 10

            DropDown {
                id: primaryDropDown
                title: qsTr("Primary colour") + Retranslate.onLanguageChanged
                Option {
                    text: qsTr("Red") + Retranslate.onLanguageChanged
                    value: "redtheme"

                }
                Option {
                    text: qsTr("Green") + Retranslate.onLanguageChanged
                    value: "greentheme"

                }
                Option {
                    text: qsTr("Yellow") + Retranslate.onLanguageChanged
                    value: "yellowtheme"

                }
                Option {
                    text: qsTr("Blue") + Retranslate.onLanguageChanged
                    value: "bluetheme"

                }
                Option {
                    text: qsTr("Grey") + Retranslate.onLanguageChanged
                    value: "greytheme"

                }
                onSelectedValueChanged: {
                    var prim = primaryDropDown.selectedValue
                    console.log(prim)
                    var themecolor = {
                        "redtheme": {
                            base: "#cc3333",
                            primary: "#ff3333"
                        },
                        "greytheme": {
                            base: "#e6e6e6",
                            primary: "#f0f0f0"
                        },
                        "bluetheme": {
                            base: "#087099",
                            primary: "#0092cc"
                        },
                        "yellowtheme": {
                            base: "#b7b327",
                            primary: "#dcd427"
                        },
                        "greentheme": {
                            base: "#5c7829",
                            primary: "#779933"
                        }
                    }
                    Application.themeSupport.setPrimaryColor(createcolor(themecolor[prim].base), createcolor(themecolor[prim].primary))
                    app.SaveSettings("color1", themecolor[prim].base)
                    app.SaveSettings("color2", themecolor[prim].primary)
                    app.SaveSettings("themecolor", prim.toString())
                }
            }
            Divider {

            }

        }
        //        Container {
        //            DropDown {
        //                title: "Sync interval"
        //                Option {
        //                    text: qsTr("3m") + Retranslate.onLanguageChanged
        //                    value: "redtheme"
        //                }
        //                Option {
        //                text: qsTr("5m") + Retranslate.onLanguageChanged
        //                value: "redtheme"
        //                }
        //                Option {
        //                    text: qsTr("10m") + Retranslate.onLanguageChanged
        //                    value: "redtheme"
        //                }
        //
        //            }
        //        }
        //        Header {
        //            title: qsTr("Help")
        //        }
        //        Container {
        //            leftPadding: ui.du(3)
        //            topPadding: 20.0
        //            horizontalAlignment: HorizontalAlignment.Fill
        //            bottomPadding: 10
        //            Label {
        //
        //                text: qsTr("<html><body><p>Notifications &amp; Sounds</p><span style='font-size:5;'>What sounds good?</span></body></html>") + Retranslate.onLanguageChanged
        //                textFormat: TextFormat.Html
        //                multiline: true
        //                textStyle.fontStyle: FontStyle.Italic
        //                textStyle.fontSize: FontSize.Medium
        //                textStyle.textAlign: TextAlign.Default
        //                horizontalAlignment: HorizontalAlignment.Fill
        //            }
        //        }
//        Header {
//            title: qsTr("Data Sync") + Retranslate.onLanguageChanged
//        }
//        Container {
//
//            leftPadding: ui.du(3)
//            topPadding: 20.0
//            horizontalAlignment: HorizontalAlignment.Fill
//            bottomPadding: 10
//
//            Label {
//
//                text: qsTr("<html><body><p>Flush Database and Resync my Data.</p><span style='font-size:5;'>Can't see all your tasks?</span></body></html>") + Retranslate.onLanguageChanged
//                textFormat: TextFormat.Html
//                multiline: true
//                attachedObjects: []
//
//                gestureHandlers: [
//                    TapHandler {
//                        onTapped: {
//                            flushandsync.show()
//
//                        }
//                    }
//                ]
//                textStyle.fontStyle: FontStyle.Italic
//                textStyle.fontSize: FontSize.Medium
//                textStyle.textAlign: TextAlign.Default
//                horizontalAlignment: HorizontalAlignment.Fill
//            }
//            Divider {
//
//            }
//        }
        Container {
            horizontalAlignment: HorizontalAlignment.Center
            topPadding: 10
            Button {
                preferredWidth: ui.du(20)
                text: qsTr("LOGOUT") + Retranslate.onLanguageChanged
                bottomPadding: ui.du(20)
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                appearance: ControlAppearance.Primary
                onClicked: {
                    deleteTaskDilog.show()
                }
            }
        }
    }
    attachedObjects: [
        SystemDialog {
            id: deleteTaskDilog
            title: qsTr("Logout")
            body: qsTr("Do you want to logout?")
            confirmButton.enabled: true
            confirmButton.label: qsTr("Yes")
            cancelButton.enabled: true
            cancelButton.label: qsTr("No")

            onFinished: {
                if (result == SystemUiResult.ConfirmButtonSelection) {
                    app.logout()
                }

            }
        },
        SystemDialog {
            id: flushandsync
            title: qsTr("Data Sync")
            body: qsTr("Do you want to re-sync data")
            confirmButton.enabled: true
            confirmButton.label: qsTr("Yes")
            cancelButton.enabled: true
            cancelButton.label: qsTr("No")
            onFinished: {
                if (result == SystemUiResult.ConfirmButtonSelection) {
                    var token = app.getToken()
                    app.flushandResync(token)
                }
            }
        },
        SystemToast {
            id: deletetoast
            body: qsTr("Task deleted")
        }
    ]
}
