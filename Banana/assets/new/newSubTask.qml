import bb.cascades 1.3
import bb.system 1.2
import "../moment.js" as Moment
Page {
    property variant info
    property variant assignvar

    function searchupdate() {
        userslist.dataModel.clear()
        userslist.dataModel.append(app.getUsersBySearch(usersearch.text, activeworkspace))
    }
    attachedObjects: [
        SystemToast {
            id: toast

        },
        SystemPrompt {
            id: addnewtag
            title: qsTr("Enter tagname")
            rememberMeChecked: false
            includeRememberMe: false
            confirmButton.enabled: true
            cancelButton.enabled: true
            inputField.emptyText: qsTr("Add")
            onFinished: {
                if (result == SystemUiResult.ConfirmButtonSelection) {
                    addtag(addnewtag.inputFieldTextEntry())
                }
            }
        },
        Sheet {
            id: mysheet
            onOpened: {
                searchupdate()
            }
            Page {
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
            onClosed: {

            }
        },
        Sheet {
            id: duedate
            Page {
                titleBar: TitleBar {
                    visibility: ChromeVisibility.Visible
                    title: qsTr("Due Date")
                    dismissAction: ActionItem {
                        title: qsTr("Cancel")
                        onTriggered: {
                            duedate.close()
                        }
                    }
                    acceptAction: ActionItem {
                        title: qsTr("Save")
                        //enabled: false
                        onTriggered: {
                            task_duedate.text = task_datepicker.value.getFullYear() + "-" + (task_datepicker.value.getMonth() + 1) + "-" + task_datepicker.value.getDate()
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
        }
    ]
    titleBar: TitleBar {
        title: qsTr("New Sub Task")

    }
    Container {
        Container {
            horizontalAlignment: HorizontalAlignment.Center

            layout: DockLayout {

            }
            visible: false
            id: indicator
            ActivityIndicator {
                minHeight: 120
                horizontalAlignment: HorizontalAlignment.Center
                running: true

            }
        }
        Container {
            topPadding: ui.du(3)
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            Label {
                textStyle.fontSize: FontSize.Medium
                textStyle.textAlign: TextAlign.Right
                verticalAlignment: VerticalAlignment.Center
                text: qsTr("Subtask Name")
            }
            TextArea {
                textStyle.textAlign: TextAlign.Right
                horizontalAlignment: HorizontalAlignment.Fill
                backgroundVisible: false
                id: task_name
                hintText: qsTr("Enter Text")
                input.submitKey: SubmitKey.Next
                input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next

            }

        }

        Container {
            topPadding: ui.du(3)
            horizontalAlignment: HorizontalAlignment.Fill
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight

            }
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.TopToBottom
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
                ListView {
                    id: users
                    visible: false
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
                        onTapped:
                        {
                            duedate.open()
                        }
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
        Container {
            topPadding: ui.du(3)
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }

        }
    }
    actions: [
        ActionItem {
            title: qsTr("Save Task")
            imageSource: "asset:///Images/BBicons/ic_done.png"
            ActionBar.placement: ActionBarPlacement.Signature
            onTriggered: {
                if (task_name.text.length > 0) {
                    createSubTask()
                    indicator.visible = true

                } else {
                    toast.body = qsTr("Sub task name missing")
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
    function createSubTask() {
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks/" + v_var + "/subtasks"
        var param = {
            name: task_name.text
        }
        if (task_duedate.text.length > 0) {
            param.due_on = task_datepicker.value.toISOString()
        }
        if (task_assigner.text.length > 0) {
            param.assignee = assignvar
        }
        var params = serialize(param)
        url += "?"
        url += params
        console.log(JSON.stringify(param), url)
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 201) {
                    var input = JSON.parse(doc.responseText).data
                    if (input) {
                        var insert = {
                        };
                        insert["id"] = input.id;
                        insert.name = input.name;
                        insert.created = Moment.moment(input["created_at"]).unix() * 1000
                        insert.completeddate = Moment.moment(input["completed_at"]).unix() * 1000
                        insert.modified = Moment.moment(input["modified_at"]).unix() * 1000
                        insert.fav = input.hearted
                        insert.notes = input.notes
                        insert.due = input["due_on"]
                        insert.workid = input.workspace.id
                        insert.completed = input.completed
                        if (input.assignee && input["assignee_status"]) {
                            insert.assignee = input.assignee.id
                            insert.assigneestatus = input["assignee_status"]

                        } else if (input["assignee_status"]) {
                            insert.assigneestatus = input["assignee_status"]

                        } else if (input.assignee) {
                            insert.assignee = input.assignee.id
                        }
                        app.insertTask(insert);
                        app.insertSubTasks(input.parent.id, input.id)
                        grabtaskmeta()
                        Qt.rendertask()
                    } else {
                        toast.body = "error in network"
                        toast.show()
                        console.log(doc.responseText + doc.getAllResponseHeaders())
                    }
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
        doc.setRequestHeader("User-Agent", "Banana-BB10");
        doc.send();
    }

}
