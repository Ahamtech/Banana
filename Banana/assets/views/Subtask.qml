import bb.cascades 1.3

Container {
    property alias imagefilepath: taskimagepath.imageSource
    property alias commenttext: subtast.text
    property alias usertext: username.text
    property alias commenttime: datatime.text
    property alias complete: checkbox.checked
    signal completeTask
    signal uncompleteTask
    signal openSubTask
    Container {
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }

        Container {
            minWidth: 5
            maxWidth: 5
            background: Application.themeSupport.theme.colorTheme.primary
            preferredWidth: 5
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
        }
        Container {
            topPadding: ui.du(2.0)

            Container {
                background: Color.Black
                horizontalAlignment: HorizontalAlignment.Fill
                Container {
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    leftPadding: 5
                    Container {
                        CheckBox {
                            scaleX: 0.75
                            scaleY: 0.75
                            id: checkbox
                            onCheckedChanged: {
                                if (checked) {
                                    completeTask()
                                } else {
                                    uncompleteTask()
                                }
                            }
                        }
                    }
                    Container {
                        leftPadding: 6
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        Container {
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 1
                            }
                            Label {
                                id: subtast
                                horizontalAlignment: HorizontalAlignment.Left
                                verticalAlignment: VerticalAlignment.Center
                                multiline: true
                            }
                        }
                        Container {

                            Label {
                                text: "ϟ"
                                textStyle.color: ui.palette.primary

                            }

                        }
                    }

                }
                Container {
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    topPadding: 2
                    Container {
                        layout: StackLayout {
                            orientation: LayoutOrientation.TopToBottom

                        }
                        /* topPadding: ui.du(2.0)
                         */
                        Container {
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            Container {
                                layout: AbsoluteLayout {
                                }
                                verticalAlignment: VerticalAlignment.Top
                                Container {
                                    maxWidth: 49
                                    maxHeight: 49
                                    ImageView {
                                        id: taskimagepath
                                    }
                                }
                                Container {
                                    maxHeight: 50
                                    maxWidth: 50
                                    ImageView {
                                        visible: username.text.length > 0
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
                                    leftPadding: 4
                                    verticalAlignment: VerticalAlignment.Center
                                    Label {
                                        layoutProperties: StackLayoutProperties {
                                            spaceQuota: 2
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
                                            orientation: LayoutOrientation.RightToLeft

                                        }
                                        layoutProperties: StackLayoutProperties {
                                            spaceQuota: 1
                                        }
                                        Container {
                                            layout: StackLayout {
                                                orientation: LayoutOrientation.RightToLeft
                                            }
                                            topPadding: 5
                                            Label {
                                                id: datatime
                                                textStyle.color: Color.create("#EEE1E1")
                                                textStyle.fontSize: FontSize.XSmall
                                                textStyle.fontSizeValue: 4.8
                                                textStyle.fontFamily: "Calibri"
                                                textStyle.fontStyle: FontStyle.Normal
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    minHeight: 1
                    background: Color.Gray
                }

            }
        }
    }
}
