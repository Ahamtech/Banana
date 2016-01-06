import bb.cascades 1.3
import "../moment.js" as Moment
Page {
    attachedObjects: [
        ComponentDefinition {
            id: taskView
            source: "asset:///views/taskView.qml"
        }
    ]
    onCreationCompleted: {
        Qt.app = app
        Qt.c_language = app.getCurrentLanguage()
        var id = app.getValueByType("id")
        taskslist.dataModel.clear()
        taskslist.dataModel.append(app.getTasksByWorkspace(activeworkspace, id[0].value))
    }
    titleBar: TitleBar {
        kind: TitleBarKind.FreeForm
        kindProperties: FreeFormTitleBarKindProperties {
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                leftPadding: 10
                rightPadding: 10
                Label {
                    text: "My Tasks"
                    textStyle {
                        color: Color.White
                    }
                    verticalAlignment: VerticalAlignment.Center
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                }
//                ToggleButton {
//                    id: toggleExpanded
//                    opacity: 0.7
//                    verticalAlignment: VerticalAlignment.Center
//                }
            }
//            expandableArea {
//                content: RadioGroup {
//                    Option {
//                        id: option1
//                        text: "option 1"
//                        selected: true
//                    }
//                    Option {
//                        id: option2
//                        text: "option 2"
//                    }
//                    Option {
//                        id: option3
//                        text: "option 3"
//                    }
//                    Option {
//                        id: option24
//                        text: "option 2"
//                    }
//                    Option {
//                        id: option43
//                        text: "option 3"
//                    }
//                }
//                indicatorVisibility: TitleBarExpandableAreaIndicatorVisibility.Hidden
//                expanded: toggleExpanded.checked
//                onExpandedChanged: {
//                    toggleExpanded.checked = expanded
//                }
//            }
        }
    }
    Container {

        ListView {
            id: taskslist
            dataModel: ArrayDataModel {

            }
            onTriggered: {
                var t_view = taskView.createObject()
                t_view.v_var = dataModel.data(indexPath).id
                navigationpane.push(t_view)
            }
            listItemComponents: [
                ListItemComponent {
                    type: ""
                    StandardListItem {
                        title: ListItemData.name
                        status: if(ListItemData.due){Moment.moment(ListItemData.due ).locale(Qt.c_language).calendar()}
                        description: ListItemData.name
                        onCreationCompleted: {
                            var projectslista = Qt.app.getTagsProjectList(ListItemData.id)
                            var projectslistaa = Qt.app.getTagsProjectList(ListItemData.id)
                            var projectslist_text = "<html>"
                            if (projectslista.length > 0) {
                                console.log("projects length is greater than 0")
                                for (var i = 0; i < projectslistaa.length; i ++) {
                                    var themecolor = ui.palette.primary
                                    projectslist_text += "<span>" + projectslista[i].projectname + "</span><span style='color:" + Color.toHexString(themecolor) + "'>|</span>"
                                }
                            }
                            projectslist_text += "</html>"
                            console.log("this is nothing " + projectslist_text)
                            description = projectslist_text
                        }
                    }
                }
            ]
        }

    }
}
