import bb.cascades 1.4

Container {
    property alias imagefilepath: taskimagepath.imageSource
    property alias emailtext: usermail.text
    property alias usertext: username.text
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        Container {
            verticalAlignment: VerticalAlignment.Center
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            Container {
                layout: AbsoluteLayout {

                }
                verticalAlignment: VerticalAlignment.Top

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
                leftPadding: 10
                verticalAlignment: VerticalAlignment.Center
                Label {
                    id: username

                }
            }

        }
        Container {
            verticalAlignment: VerticalAlignment.Center
            layoutProperties: StackLayoutProperties {
                spaceQuota: -1
            }
            Label {
                id: usermail

                textStyle.color: Color.create("#EEE1E1")
                textStyle.fontSize: FontSize.XXSmall
                textStyle.fontSizeValue: 4.8
                textStyle.fontFamily: "Calibri"
                textStyle.fontStyle: FontStyle.Normal
            }
        }
    }
    Container {
        background: ui.palette.primary
        minHeight: 3
        horizontalAlignment: HorizontalAlignment.Fill
    }
}
