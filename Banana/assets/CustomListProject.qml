import bb.cascades 1.3

Container {
    property alias projectname:project_name.text
    property alias updated:project_time.text
    property alias color:color_bar.background
    Container {
        layout: StackLayout {
            orientation: LayoutOrientation.TopToBottom

        }
        horizontalAlignment: HorizontalAlignment.Fill

        minHeight: 100

        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight

            }
            horizontalAlignment: HorizontalAlignment.Fill
            Container {
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight

                }
                horizontalAlignment: HorizontalAlignment.Fill

                Container {
                    id: color_bar
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: -1
                    }
                    minHeight: 100
                    preferredWidth: 10
                }
                Container {
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    verticalAlignment: VerticalAlignment.Center
                    leftPadding: 20
                    Label {
                        id:project_name
                        textStyle.fontSize: FontSize.Large
                    }

                }
                Container {
                    rightPadding: 10
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: -1
                    }
                    verticalAlignment: VerticalAlignment.Center
                    Label {
                        id: project_time
                        textStyle.fontSize: FontSize.Small
                        textStyle.color: Color.LightGray

                    }
                }
            }

        }
        Container {
            opacity: .8
            background: Application.themeSupport.theme.colorTheme.primary
            preferredHeight: 1
            horizontalAlignment: HorizontalAlignment.Fill
        }
    }
}
