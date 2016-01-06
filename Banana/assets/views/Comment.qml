import bb.cascades 1.3

Container {
    property alias imagefilepath: taskimagepath.imageSource
    property alias commenttext: comment.text
    property alias usertext: username.text
    property alias commenttime: datatime.text
    Container {
        background: Color.Black
        horizontalAlignment: HorizontalAlignment.Fill
        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight

            }
            Container {

                minWidth: 5
                maxWidth: 5
                background: Application.themeSupport.theme.colorTheme.primary
                preferredWidth: 3
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                rightMargin: ui.du(1.0)
            }

            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.TopToBottom

                }
                 topPadding: ui.du(1.0)

                bottomPadding: ui.du(1.0)
                Container {
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight

                    }
                    Container {
                        layout: AbsoluteLayout {

                        }
                        verticalAlignment: VerticalAlignment.Top

                        /*maxHeight: 100
                         maxWidth: 100*/
                        Container {
                            topPadding: 5
                            preferredHeight: 80
                            preferredWidth: 80
                            ImageView {
                                id: taskimagepath
                            }
                        }
                        Container {
                            topPadding: 5
                            preferredHeight: 80
                            preferredWidth: 80
                            ImageView {
                                imageSource: "asset:///Images/120hexagon.png"
                            }
                        }

                    }

                    Container {
                        background: Color.Black
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                        layout: StackLayout {
                            orientation: LayoutOrientation.TopToBottom

                        }
                        leftPadding: 10
                        Container {
                            topPadding: 1
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight

                            }
                            Label {
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                                id: username
                                textStyle.color: Color.create("#EEE1E1")
                                textStyle.fontSize: FontSize.Small
                                textStyle.fontFamily: "Calibri"
                                textStyle.fontStyle: FontStyle.Normal

                            }
                            Container {
                                background: Color.Black
                                rightPadding: 5
                                layout: StackLayout {
                                    orientation: LayoutOrientation.LeftToRight

                                }
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: -1
                                }
                                Container {
                                    layout: StackLayout {
                                        orientation: LayoutOrientation.LeftToRight

                                    }
                                    topPadding: 5
                                    ImageView {

                                        objectName: "date - time"
                                        imageSource: "asset:///Images/date.png"
                                        preferredHeight: 30
                                        preferredWidth: 30
                                    }
                                    Label {
                                        id: datatime
                                        textStyle.color: Color.create("#EEE1E1")
                                        textStyle.fontSize: FontSize.XXSmall
                                        textStyle.fontSizeValue: 4.8
                                        textStyle.fontFamily: "Calibri"
                                        textStyle.fontStyle: FontStyle.Normal

                                    }
                                }

                            }
                        }

                        Container {
                            background: Color.Black
                            Label {
                                id: comment
                                textFormat: TextFormat.Plain
                                multiline: true

                            }
                        }

                    }

                }

            }
        }

        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            minHeight: 1
            background: Application.themeSupport.theme.colorTheme.primary
        }

    }
}
