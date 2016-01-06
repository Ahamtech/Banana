import bb.cascades 1.3

TitleBar {
    signal refresh
    signal edit
    property alias titlename: projectname.text
    kind: TitleBarKind.FreeForm
    kindProperties: FreeFormTitleBarKindProperties {
        Container {
            layout: DockLayout {
            
            }
            Label {
                id: projectname
                text: qsTr("Project Name")
                horizontalAlignment: HorizontalAlignment.Left
                verticalAlignment: VerticalAlignment.Center
                textStyle.fontSize: FontSize.Large
                gestureHandlers: [
                    TapHandler {
                        onTapped: {
                            edit()
                        }
                    }
                ]
            }
            
            ImageView {
                
                horizontalAlignment: HorizontalAlignment.Right
                imageSource: "asset:///Images/"
                gestureHandlers: [
                    TapHandler {
                        onTapped: {
                            refresh()
                        }
                    }
                ]
            
            }
        }
    }
}

