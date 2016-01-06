import bb.cascades 1.3

TitleBar {
    property alias assign: assigned.text
    property alias duedate: due.text

    kind: TitleBarKind.FreeForm
    kindProperties: FreeFormTitleBarKindProperties {
        Container {
            Container {
horizontalAlignment: HorizontalAlignment.Right
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                
                }
                Container {
                    Label {
                        text: "Due by :"
                        textStyle.fontSize: FontSize.XSmall
                    }
                }
                Container {
                    Label {
                        id: due
                        text: "21/02/2012"
                        textStyle.fontSize: FontSize.XSmall
                    
                    }
                }
            
            }
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Fill
                Container {
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: ui.du(6)
                    }
                    verticalAlignment: VerticalAlignment.Center
                    Label {
                        id: assigned
                        text: "Assigned to name"
                        multiline: true
                        textStyle.fontSize: FontSize.Medium
                    }
                }
               
            }
        }
    }
}