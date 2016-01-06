import bb.cascades 1.3
import "../moment.js" as Moment
Page {
    titleBar: TitleBar {
        title: qsTr("My Tasks")
    }
    attachedObjects: [
        ComponentDefinition {
            id: taskviewpage
            source: "asset:///views/taskView.qml"
        }
    ]
    onCreationCompleted: {
        Qt.c_language = app.getCurrentLanguage()
        var id = app.getValueByType("id")
        taskslist.dataModel.clear()     
        taskslist.dataModel.append(app.getTasksByAssignee(id[0].value, activeproject))
        console.log(JSON.stringify(app.getTasksByAssignee(id[0].value, activeproject)))
        if (taskslist.dataModel.size() > 0) {
            notasks.visible = false
            taskslist.visible = true
        } else {
            notasks.visible = true
            taskslist.visible = false
        }

    }
    Container {
        layout: DockLayout {

        }
        Container {
            id: notasks
            verticalAlignment: VerticalAlignment.Center
            horizontalAlignment: HorizontalAlignment.Center
            Label {
                text: qsTr("No Tasks")
                textStyle.color: ui.palette.primary
                opacity: .5
                textStyle.fontSize: FontSize.PointValue
                textStyle.fontSizeValue: 10

            }
        }
        ListView {
            id: taskslist
            dataModel: ArrayDataModel {
            }
            onTriggered: {
                var t_view = taskviewpage.createObject()
                var selectedItem = dataModel.data(indexPath);
                t_view.v_var = selectedItem.id
                navigationpane.push(t_view)
            }
            listItemComponents: [
                ListItemComponent {
                    type: ""
                    StandardListItem {
                        title: ListItemData.name
                        status: if(ListItemData.due){Moment.moment(ListItemData.due).locale(Qt.c_language).calendar()}
                    }
                }
            ]
        }

    }
}
