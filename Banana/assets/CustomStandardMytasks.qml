import bb.cascades 1.3

Container {
    property alias projectname: project_name.text
    property alias assigneename: assignee_name.text
    property alias workspacename: worksapce_name.text
    property alias projects: projex_name.text

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
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                leftPadding: 10
                Label {
                    id: project_name
                    textStyle.fontSize: FontSize.Large
                }

            }

        }
        Container {
            leftPadding: 10
            verticalAlignment: VerticalAlignment.Center
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            horizontalAlignment: HorizontalAlignment.Fill
            Container {
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 2
                }
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                horizontalAlignment: HorizontalAlignment.Fill
                Container {
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 0.1
                    }
                    horizontalAlignment: HorizontalAlignment.Right
                    Label {
                        horizontalAlignment: HorizontalAlignment.Left
                        verticalAlignment: VerticalAlignment.Center
                        id: worksapce_name
                        //workspce id hr
                        textStyle.fontSize: FontSize.XSmall
                    }
                }

                Container {
                    
                    horizontalAlignment: HorizontalAlignment.Center
                    Label {
                        verticalAlignment: VerticalAlignment.Center
                        text: "> "
                        textStyle.fontSize: FontSize.XSmall
                        textStyle.color: ui.palette.primary

                    }
                }
                Container {
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 0.2
                    }
                    Label {
                        id: projex_name
                        verticalAlignment: VerticalAlignment.Center
                        //Descripyion id hr
                        textStyle.fontSize: FontSize.XSmall
                    }
                }

            }
            Container {
                verticalAlignment: VerticalAlignment.Center

                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                leftPadding: 10
                horizontalAlignment: HorizontalAlignment.Right
                Label {
                    id: assignee_name
                    horizontalAlignment: HorizontalAlignment.Right
                    verticalAlignment: VerticalAlignment.Center
                    //assigned person id hwre id here
                    opacity: 0.7
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
