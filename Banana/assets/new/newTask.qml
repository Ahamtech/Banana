import bb.cascades 1.4
import bb.system 1.2
import "../moment.js" as Moment
import "../inserttask.js" as Insert
Page {
    property variant assignvar
    titleBar: TitleBar {
        title: qsTr("Add New Task")

    }
    onCreationCompleted: {
        //        getAllProjects()
    }
    function searchupdate() {

        userslist.dataModel.clear()
        userslist.dataModel.append(app.getUsersBySearch(usersearch.text, activeworkspace))
    }
    function getAllProjects() {

        var projectdata = []
        projectdata = app.getProjectsById(activeworkspace)
        for (var i = 0; i < projectdata.length; i ++) {

            var p_option = optiondef.createObject();
            p_option.text = projectdata[i].name
            p_option.value = projectdata[i].id
            project_options.add(p_option)
            if (activeproject) {
                if (activeproject == projectdata[i].id) {
                    project_options.selectedOption = p_option
                }
            }
        }
    }
    attachedObjects: [
        SystemToast {
            id: toast
        },
        ActivityIndicator {
            id: savetask
        },
        ComponentDefinition {
            id: optiondef
            Option {

            }
        },
        Sheet {
            id: duedate
            onOpened: {
                searchupdate()
            }
            Page {
                titleBar: TitleBar {
                    visibility: ChromeVisibility.Visible
                    title: qsTr("Add Due Date")
                    dismissAction: ActionItem {
                        title: qsTr("Cancel")
                        onTriggered: {
                            duedate.close()
                        }
                    }
                    acceptAction: ActionItem {
                        title: qsTr("Save")
                        onTriggered: {
                            task_duedate.text = task_datepicker.value.getFullYear() + "-" + (task_datepicker.value.getMonth()) + "-" + task_datepicker.value.getDate()
                            duedate.close()
                        }
                    }
                }

                Container {
                    layout: StackLayout {

                    }
                    leftPadding: ui.du(3.0)
                    rightPadding: ui.du(3.0)
                    bottomPadding: ui.du(3.0)
                    topPadding: ui.du(3.0)
                    DateTimePicker {
                        id: task_datepicker
                        title: qsTr("Set Due Date")
                        mode: DateTimePickerMode.Date
                        expanded: true
                    }
                }
            }
        },
        Sheet {
            id: mysheet
            onOpened: {
                searchupdate()
            }
            Page {
                onCreationCompleted: {

                }
                titleBar: TitleBar {
                    id: titlebaar
                    visibility: ChromeVisibility.Visible
                    title: qsTr("Assign Task")
                    dismissAction: ActionItem {
                        title: qsTr("Cancel")
                        onTriggered: {
                            mysheet.close()
                        }
                    }
                }
                Container {
                    layout: StackLayout {

                    }
                    leftPadding: ui.du(3.0)
                    rightPadding: ui.du(3.0)
                    bottomPadding: ui.du(3.0)
                    topPadding: ui.du(3.0)
                    Label {
                        id: taskholder
                        text: task_assigner.text
                    }
                    TextField {
                        id: usersearch
                        onTextChanging: {
                            searchupdate()
                        }
                    }
                    ListView {
                        id: userslist
                        dataModel: ArrayDataModel {

                        }
                        onTriggered: {
                            clearSelection()
                            select(indexPath)
                            var data = dataModel.data(indexPath);
                            task_assigner.text = data.name
                            assignvar = data.id
                            mysheet.close()

                        }
                        listItemComponents: [
                            ListItemComponent {
                                type: ""
                                StandardListItem {
                                    title: ListItemData.name
                                    status: ListItemData.email
                                }
                            }
                        ]
                    }
                }
            }
        }
    ]
    Container {
        Container {
            id: mainrole
            Container {
                topPadding: 10
                rightPadding: 10
                leftPadding: 10
                horizontalAlignment: HorizontalAlignment.Center
                //                DropDown {
                //                    id: project_options
                //                    title: qsTr("Select Project")
                //
                //                }
            }
            Container {
                topPadding: 10
                rightPadding: 10
                leftPadding: 10
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Label {
                    id: tasktitlelabel
                    text: qsTr("Task Name")
                    verticalAlignment: VerticalAlignment.Center
                    textStyle.fontSize: FontSize.Medium

                }
                TextArea {
                    id: tasktitle
                    backgroundVisible: false
                    hintText: qsTr("Enter Text")
                    input.submitKey: SubmitKey.Next
                    input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                    textStyle.textAlign: TextAlign.Right

                }
            }
            Container {
                topPadding: 10
                rightPadding: 10
                leftPadding: 10
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Label {
                    id: taskdesclabel
                    text: qsTr("Description")
                    verticalAlignment: VerticalAlignment.Center
                    textStyle.fontSize: FontSize.Medium

                }
                TextArea {
                    id: taskdesc
                    textStyle.textAlign: TextAlign.Right

                    backgroundVisible: false
                    hintText: qsTr("Enter Text")
                    autoSize.maxLineCount: 4
                    input.submitKey: SubmitKey.Next
                    input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next

                }
            }
            Container {

                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Label {
                    id: task_assigner_label
                    gestureHandlers: TapHandler {
                        onTapped: {
                            task_assigner_cancel.visible = true
                            mysheet.open()
                        }
                    }
                    textStyle.fontSize: FontSize.Medium
                    textStyle.textAlign: TextAlign.Right
                    verticalAlignment: VerticalAlignment.Center
                    text: qsTr("Assign To")
                }
                TextArea {
                    id: task_assigner
                    backgroundVisible: false
                    editable: false
                    textStyle.fontSize: FontSize.Medium
                    textStyle.textAlign: TextAlign.Right
                    verticalAlignment: VerticalAlignment.Center
                    gestureHandlers: TapHandler {
                        onTapped: {
                            mysheet.open()
                        }
                    }
                }
                Button {
                    id: task_assigner_cancel
                    verticalAlignment: VerticalAlignment.Center
                    preferredWidth: ui.du(1)
                    imageSource: "asset:///Images/BBicons/ic_clear.png"
                    onClicked: {
                        assignvar.text = null
                        task_assigner.text = ""
                    }
                }
            }
            Container {

                topPadding: ui.du(3)
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Label {
                    id: task_duedate_label
                    gestureHandlers: TapHandler {
                        onTapped: {
                            duedate.open()
                        }
                    }
                    verticalAlignment: VerticalAlignment.Center
                    textStyle.fontSize: FontSize.Medium
                    text: qsTr("Due Date")
                }
                TextArea {
                    id: task_duedate
                    editable: false
                    backgroundVisible: false
                    textStyle.fontSize: FontSize.Medium
                    textStyle.textAlign: TextAlign.Right
                    gestureHandlers: [
                        TapHandler {
                            onTapped: {
                                duedate.open()
                            }
                        }
                    ]
                }
                Button {
                    id: task_duedate_cancel
                    verticalAlignment: VerticalAlignment.Center
                    preferredWidth: ui.du(1)
                    imageSource: "asset:///Images/BBicons/ic_clear.png"
                    onClicked: {
                        task_duedate.text = ""

                    }
                }
            }
        }
        Container {
            visible: false
            id: add_task_indicator
            horizontalAlignment: HorizontalAlignment.Center
            layout: DockLayout {

            }
            ActivityIndicator {
                maxHeight: 300
                horizontalAlignment: HorizontalAlignment.Center
                running: true

            }
            onVisibleChanged: {
                if (visible) {
                    mainrole.enabled = false
                }
            }
        }

    }
    actions: [
        ActionItem {
            title: qsTr("Add Task")
            imageSource: "asset:///Images/BBicons/ic_done.png"
            ActionBar.placement: ActionBarPlacement.Signature
            onTriggered: {
                if (tasktitle.text.length > 0) {
                    createNewTask()
                    add_task_indicator.visible = true

                } else {
                    toast.body = qsTr("please enter the task title")
                    toast.show()
                }
            }

        }
    ]

    function serialize(obj, prefix) {
        var str = [];
        for (var p in obj) {
            var k = prefix ? prefix + "[" + p + "]" : p, v = obj[p];
            str.push(typeof v == "object" ? serialize(v, k) : encodeURIComponent(k) + "=" + encodeURIComponent(v));
        }
        return str.join("&");
    }
    function createNewTask() {

        var param = {
            "workspace": activeworkspace,
            "projects": activeproject,
            "name": tasktitle.text
        }
        if (taskdesc.text.length > 0) {
            param.notes = taskdesc.text
        }
        if (task_duedate.text.length > 0) {
            param.due_on = task_datepicker.value.toISOString()
        }
        if (task_assigner.text.length > 0) {
            param.assignee = assignvar
        }
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks"
        var params = serialize(param)
        url += "?"
        url += params
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 201) {
                    Insert.insert(JSON.parse(doc.responseText))
                    var inter = JSON.parse(doc.responseText).data
                    app.taskViewSendwUpdate(inter.id)
                    navigationpane.pop()
                } else {
                    console.log("STATUS:" + doc.status + " \nHEADERS: " + doc.getAllResponseHeaders() + "\n BODY: " + doc.responseText);
                }
            }
        }
        doc.open("POST", url);
        doc.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        doc.setRequestHeader("Authorization", "Basic " + token);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send();

    }

}
