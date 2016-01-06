import bb.cascades 1.4
NavigationPane {
    Page {

        property variant v_var

        titleBar: TitleBar {
            title: "Task Name"
        }
        Container {
            Container {
                topPadding: 15
                horizontalAlignment: HorizontalAlignment.Center
                TextArea {
                    preferredWidth: ui.du(70)
                    //add ID of the task here
                    editable: false
                }
            }
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight

                }
                leftPadding: 30
                Label {
                    text: qsTr("Created By")
                    textStyle.fontSize: FontSize.Medium
                    verticalAlignment: VerticalAlignment.Center

                }
                TextArea {
                    preferredWidth: ui.du(50)
                    //add ID of the person who created the task
                    editable: false
                }
            }
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight

                }
                leftPadding: 30
                Label {
                    text: qsTr("Assigned to")
                    textStyle.fontSize: FontSize.Medium
                    verticalAlignment: VerticalAlignment.Center

                }
                TextArea {
                    preferredWidth: ui.du(50)

                    //add ID of the person who is assigned
                    editable: false
                }
            }

        }
        actions: [
            ActionItem {
                title: qsTr("Add Comment")
                ActionBar.placement: ActionBarPlacement.Signature
                imageSource: "asset:///Images/BBicons/ic_compose.png"
                onTriggered: {

                }
            }
        ]
    }
}