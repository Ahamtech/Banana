import bb.cascades 1.3

Container {
    layout: StackLayout {
        orientation: LayoutOrientation.TopToBottom
    }

    property alias file: filename.text
    property alias commenttime: timer.text
    property alias usertext: user.text
    background: Color.create("#4bbfbfbf")
    rightPadding: 10.0
    topPadding: 10
    bottomPadding: 10
    leftPadding: 10
    maxHeight: 250
    Container {
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
        }
        Container {
            Label {
                text: ""
                id: user
                textStyle.fontSize: FontSize.Small
            }
        }
        Container {
            Label {
                id: timer
                textStyle.fontSize: FontSize.XXSmall

            }
        }
        Container {
            Label {
                id: filename
                multiline: true

            }
        }

    }
    Container {
        layoutProperties: StackLayoutProperties {
            spaceQuota: -1
        }
        verticalAlignment: VerticalAlignment.Bottom
        horizontalAlignment: HorizontalAlignment.Fill
        minHeight: 6
        maxHeight: 6
        background: ui.palette.primary
    }

}
