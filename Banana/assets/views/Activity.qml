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
                layout: StackLayout {
                    orientation: LayoutOrientation.TopToBottom
                }
                Container {
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    Container {
                        layout: AbsoluteLayout {
                        }
                        verticalAlignment: VerticalAlignment.Top
                        rightMargin: 10.0
                        Container {
                            topPadding: 10
                            preferredHeight: 68
                            preferredWidth: 58
                            ImageView {
                                id: taskimagepath
                            }
                        }
                        Container {
                            topPadding: 10
                            preferredHeight: 70
                            preferredWidth: 60

                            ImageView {
                                imageSource: "asset:///Images/120hexagon.png"
                            }
                        }
                    }
                    Container {
                        minWidth: 5
                        maxWidth: 5
                        background: Application.themeSupport.theme.colorTheme.primary
                        preferredWidth: 3
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        leftPadding: 3.0
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
                        topPadding: 5.0
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
