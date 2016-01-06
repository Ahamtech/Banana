import bb.cascades 1.4
import bb.device 1.4
Container {
   
    property int dev_width: display.pixelSize.width
    minWidth: dev_width
    attachedObjects: [
        DisplayInfo {
            id: display
        }
    ]
    property alias projectname: project_name.text
    property alias assigneename: assignee_name.text
    Container {
        
        minWidth: dev_width
        MultiCover.level: CoverDetailLevel.Medium
        horizontalAlignment: HorizontalAlignment.Fill

        verticalAlignment: VerticalAlignment.Fill
        layout: StackLayout {
            orientation: LayoutOrientation.TopToBottom
        }
        layoutProperties: [
            StackLayoutProperties {

            }
        ]
        Container {
            Label {
                horizontalAlignment: HorizontalAlignment.Fill
                id: project_name
                textStyle.fontSize: FontSize.PointValue
                textStyle.fontSizeValue: 7
                textStyle.fontStyle: Color.White
            }
        }

        Container {
            Label {
                horizontalAlignment: HorizontalAlignment.Fill
                id: assignee_name
                textStyle.fontSize: FontSize.PointValue
                textStyle.fontSizeValue: 5
                textStyle.fontStyle: Color.White
            }
        }
        Container {
            background: ui.palette.primary
            preferredHeight: 4
            horizontalAlignment: HorizontalAlignment.Fill

        }

    }
}