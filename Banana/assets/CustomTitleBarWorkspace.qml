import bb.cascades 1.3

TitleBar {

    kind: TitleBarKind.FreeForm
    kindProperties: FreeFormTitleBarKindProperties {

        Container {
            //maxHeight: 80
            Container {

                topPadding: 6
                horizontalAlignment: HorizontalAlignment.Fill

                Container {
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    topPadding: 10
                    Container {
                        horizontalAlignment: HorizontalAlignment.Center
                        rightPadding: 7
                        verticalAlignment: VerticalAlignment.Center
                        Container {
                            verticalAlignment: VerticalAlignment.Center
                            
                            maxHeight: 50
                            maxWidth: 50
                            ImageView {
                                imageSource: "asset:///Images/bunchbanana.png"
                            }
                        }
                    
                    }
                    Label {
                        id: workspace
                        text: "Workspace Name"
                        horizontalAlignment: HorizontalAlignment.Center
                        textStyle.fontSize: FontSize.Large
                    }
                    gestureHandlers: TapHandler {
                        onTapped: {

                        }
                    }
                }
            }
        }
    }
}
