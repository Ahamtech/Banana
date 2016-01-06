import bb.cascades 1.3
import bb.system 1.2
import "../moment.js" as Moment
Page {
    property variant sub_task_id
    property variant info
    property variant selectedlist: []
    property variant assignvar
    function searchupdate() {
        userslist.dataModel.clear()
        userslist.dataModel.append(app.getUsersBySearch(usersearch.text,activeworkspace))
    }
    onCreationCompleted: {
        Qt.isPhotoAvailable = isPhotoAvailable
        Qt.filepathname = filepathname.data
        
    }
    function isPhotoAvailable(id){
        return app.isPhotoAvailable(id);
    }
    function searchtagupdate() {
        taglist.dataModel.clear()
        taglist.dataModel.append(app.getTagsBySearch(tagsearch.text))
        refreshList(selectedlist)
    }
    function selectionlisttag(alltags) {
        for (var i = 0; i < taglist.dataModel.size(); i ++) {
            for (var j = 0; j < alltags.length; j ++) {
                if (alltags[j].id == taglist.dataModel.value(i).id) {
                    taglist.select([ i ])
                }
            }
        }
    }
    function refreshList(alltags) {
        for (var i = 0; i < taglist.dataModel.size(); i ++) {
            for (var j = 0; j < alltags.length; j ++) {
                if (alltags[j] == taglist.dataModel.value(i).id) {
                    taglist.select([ i ])
                }
            }
        }
    }
    attachedObjects: [
        SystemToast {
            id: savsub
            body: qsTr("Saving ...")
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
                    title: qsTr("Assign Subtask")
                    dismissAction: ActionItem {
                        title: qsTr("Back")
                        onTriggered: {
                            mysheet.close()
                        }
                    }
                    acceptAction: ActionItem {
                        title: qsTr("Save")
                        //enabled: false
                        onTriggered: {
                            var v_path = userslist.selected()
                            var v_data = userslist.dataModel.data(v_path)
                            var v_id = v_data.id
                            assign(v_id)
                            savassign.show()
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
                            console.log("this is the console")

                            select(indexPath)
                            var data = dataModel.data(indexPath);
                            task_assigner.text = data.name
                            assignvar = data.id
                        }
                        listItemComponents: [
                            ListItemComponent {
                                type: ""
                                StandardListItem {
                                    imageSource: isPhotoAvailable(ListItemData.id) ? filepathname.data + "/ahammedia/" + ListItemData.id + ".png" : "asset/Images/singlebanana.png"
                                    title: ListItemData.name
                                    status: ListItemData.email
                                }
                            }
                        ]
                    }
                }
                attachedObjects: [
                    SystemToast {
                        id: savassign
                        body: qsTr("Saving ...")
                    }
                ]
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
                            saveDueDate(true)
                            savdue.show()
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
                        expanded: true
                        mode: DateTimePickerMode.Date
                    }
                }
                attachedObjects: [
                    SystemToast {
                        id: savdue
                        body: qsTr("Saving ...")
                    }
                ]
            }
        }
    ]
    onSub_task_idChanged: {
        app.subTaskViewUpdate.connect(render)
        render()
    }
    function render() {
        var data = app.getTasks(sub_task_id)
        info = data[0]
        if (info.due != null || info.due != "") {
            var dt = info.due
            var darray = []
            darray = dt.split("-")
            task_datepicker.value = new Date(darray[0], darray[1] - 1, darray[2])
        }
        task_name.text = info.name
        if (info.assignee) {
            var d = app.getUserByID(info.assignee)
            task_assigner.text = d[0].name
            task_assigner_cancel.imageSource = "asset:///Images/BBicons/ic_clear.png"
        } else {
            task_assigner_cancel.imageSource = "asset:///Images/BBicons/ic_add.png"
        }
        if (info.due) {
            task_duedate.text = info.due
            task_duedate_cancel.imageSource = "asset:///Images/BBicons/ic_clear.png"
        } else {
            task_duedate_cancel.imageSource = "asset:///Images/BBicons/ic_add.png"
        }
    }
    titleBar: TitleBar {
        title: qsTr("Edit Subtask")
    }
    ScrollView {

        Container {

            Container {
                topPadding: ui.du(3)
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Label {
                    textStyle.fontSize: FontSize.Medium
                    textStyle.textAlign: TextAlign.Right
                    verticalAlignment: VerticalAlignment.Center
                    text: qsTr("Subtask ")
                }
                TextArea {
                    onFocusedChanged: {
                        if(!focused){
                            if (task_name.text.length > 0)
                                saveNote()
                            savsub.show()
                        
                        }
                    }
                    textStyle.textAlign: TextAlign.Right
                    horizontalAlignment: HorizontalAlignment.Fill
                    backgroundVisible: false
                    id: task_name
                    hintText: qsTr("Enter Text")
                    input.submitKey: SubmitKey.Next
                    input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                    autoSize.maxLineCount: 10

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
                                    task_assigner_label.text = qsTr("Assign To")
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
                                var imagestring = imageSource.toString();
                                if (imagestring.indexOf("add") >= 0) {
                                    mysheet.open()
                                }
                                if (imagestring.indexOf("clear") >= 0) {
                                    task_assigner.text = ""
                                    task_assigner_label.text = qsTr("Assign task")
                                    task_assigner_cancel.imageSource = "asset:///Images/BBicons/ic_add.png"
                                    assign("")
                                }
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
                        var imagestring = imageSource.toString();
                        if (imagestring.indexOf("add") >= 0) {
                            duedate.open()
                        
                        }
                        if (imagestring.indexOf("clear") >= 0) {
                            task_duedate.text = ""
                            task_duedate_cancel.imageSource = "asset:///Images/BBicons/ic_add.png"
                            task_duedate_label.text = qsTr("Set Due Date")
                            saveDueDate(false)
                        }
                    }
                }
            }
        }
    }
    actions: [
        ActionItem {
            title: qsTr("Save Task")
            imageSource: "asset:///Images/BBicons/ic_done.png"
            ActionBar.placement: ActionBarPlacement.Signature
            onTriggered: {
                if (task_name.text.length > 0)
                    saveNote()
                savsub.show()
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
    function saveNote() {
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks/" + sub_task_id
        var param = {
            name: task_name.text
        }
        console.log(JSON.stringify(param))
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var input = JSON.parse(doc.responseText).data
                    console.log(doc.responseText)
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
                        app.insertTask(insert);
                        app.subTaskViewSendwUpdate(sub_task_id)
                        duedate.close()
                    } else {
                        console.log(doc.responseText + doc.getAllResponseHeaders())
                    }
                } else {
                    console.log("STATUS:" + doc.status + " \nHEADERS: " + doc.getAllResponseHeaders() + "\n BODY: " + doc.responseText);
                }
            }
        }
        doc.open("PUT", url);
        doc.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        doc.setRequestHeader("Authorization", "Basic " + token);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.setRequestHeader("User-Agent", "Banana-BB10");
        doc.send(serialize(param));
    }
    function saveDueDate(check) {
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks/" + sub_task_id
        if (check == true) {
            var param = {
                due_on: task_datepicker.value.toISOString()
            }
        } else {
            var param = {
                due_on: "null"
            }
            app.removeTask(sub_task_id)
        }
        console.log(JSON.stringify(param))
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var input = JSON.parse(doc.responseText).data
                    console.log(doc.responseText)
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
                        app.insertTask(insert);
                        app.subTaskViewSendwUpdate(sub_task_id)
                        duedate.close()
                    } else {
                        console.log(doc.responseText + doc.getAllResponseHeaders())
                    }
                } else {
                    console.log("STATUS:" + doc.status + " \nHEADERS: " + doc.getAllResponseHeaders() + "\n BODY: " + doc.responseText);
                }
            }
        }
        doc.open("PUT", url);
        doc.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        doc.setRequestHeader("Authorization", "Basic " + token);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.setRequestHeader("User-Agent", "Banana-BB10");
        doc.send(serialize(param));
    }
    function assign(id) {
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks/" + sub_task_id
        var param = null
        var param = null
        if (id) {
            param = "assignee=" + id
        } else {
            param = "assignee=null"
            app.removeTask(sub_task_id)
        }
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
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
                        app.flushFollowers(input.id)
                        if (input.followers) {
                            var followers = input.followers
                            app.insertFollowers(input.id, followers)

                        }
                        app.flushMemberships(input.id)
                        if (input.memberships) {
                            for (var a = 0; a < input.memberships.length; a ++) {
                                var member = input.memberships[a]
                                app.insertProject2Task({
                                        'projectid': member.project.id,
                                        "taskid": id
                                    })

                                if (member.section) {
                                    app.insertSectionMeta(member.section.id, member.section.name, id, member.project.id)

                                }
                            }

                        }
                        app.flushTags(input.id)
                        if (input.tags) {
                            for (var a = 0; a < input.tags.length; a ++) {
                                app.insertTag(input.tags[a].id, input.tags[a].name, input.id)

                            }
                        }
                        app.insertTask(insert);
                        app.subTaskViewSendwUpdate(sub_task_id)
                    } else {
                        console.log(doc.responseText + doc.getAllResponseHeaders())
                    }
                    mysheet.close()

                } else {
                    console.log("STATUS:" + doc.status + " \nHEADERS: " + doc.getAllResponseHeaders() + "\n BODY: " + doc.responseText);
                }
            }
        }
        doc.open("PUT", url);
        doc.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        doc.setRequestHeader("Authorization", "Basic " + token);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.setRequestHeader("User-Agent", "Banana-BB10");
        doc.send(param);
    }
}
