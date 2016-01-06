import bb.cascades 1.4

Page {
    onCreationCompleted: {
        projectfollowers.dataModel.clear()
        projectfollowers.dataModel.append(app.getProjectFollowers(activeproject))
    }
    titleBar: TitleBar {
        title: qsTr("Project Members")

    }
    Container {
        ListView {
            id: projectfollowers
            dataModel: ArrayDataModel {
                
            }
            listItemComponents: [
                ListItemComponent {
                    type:  "" 
                    StandardListItem {
                        title: ListItemData.name
                        description: ListItemData.email
                    }                               
                }
            ]
        }
    }
}
