import bb.cascades 1.3
import bb.system 1.2
import "../moment.js" as Moment
import "../inserttask.js" as Insert
Page {
    property variant info
    property variant selectedlist: []
    property variant all_tags: app.getTagsByTaskId(v_var, activeworkspace)
    function isPhotoAvailable(id) {
        return app.isPhotoAvailable(id)
    }
    function searchupdate() {
        userslist.dataModel.clear()
        userslist.dataModel.append(app.getUsersBySearch(usersearch.text, activeworkspace))
    }
    function searchtagupdate() {
        taglist.dataModel.clear()
        taglist.dataModel.append(app.getTagsBySearch(tagsearch.text, activeworkspace))
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
            id: savetsk
            body: qsTr("Saving ...")
        },
        SystemPrompt {
            id: addnewtag
            title: qsTr("Add tag")
            rememberMeChecked: false
            includeRememberMe: false
            confirmButton.enabled: true
            cancelButton.enabled: true
            inputField.emptyText: qsTr("Enter text")
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
                            savassin.show()
                            taskeditorindicator.visible = true
                            taskeditorindicator.running = true
                            task_assigner_cancel.imageSource = "asset:///Images/BBicons/ic_clear.png"
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
            }
            attachedObjects: [
                SystemToast {
                    id: savassin
                    body: qsTr("Saving ...")
                }
            ]
            onClosed: {

            }
        },
        Sheet {
            id: tags
            onOpened: {
                searchtagupdate()
                selectionlisttag(all_tags)
                selectedlist = []
            }

            Page {
                function onSave() {
                    var selectionlist = taglist.selectionList()
                }
                titleBar: TitleBar {
                    visibility: ChromeVisibility.Visible
                    title: qsTr("Tags")
                    dismissAction: ActionItem {
                        title: qsTr("Done")
                        onTriggered: {
                            tags.close()
                            savtasks.show()
                        }
                    }
                    acceptAction: ActionItem {
                        title: qsTr("Add New Tag")
                        //enabled: false
                        onTriggered: {
                            addnewtag.show()
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
                        hintText: qsTr("Search Tag")
                        id: tagsearch
                        onTextChanging: {
                            searchtagupdate()
                            selectionlisttag(all_tags)
                            refreshList(selectedlist)
                        }
                    }
                    ListView {
                        id: taglist
                        dataModel: ArrayDataModel {
                        }

                        onTriggered: {
                            toggleSelection(indexPath)
                            var data = dataModel.data(indexPath);

                            task_assigner.text = data.name

                            var sslist = selectionList()
                            var arr = []
                            arr = selectedlist
                            for (var index = 0; index < sslist.length; index ++) {
                                var iid = dataModel.data(sslist[index]).id
                                if (arr.indexOf(iid) < 0) {
                                    arr.push(iid)
                                } else {
                                    if (! taglist.isSelected(indexPath)) {
                                        arr.splice(arr.indexOf(data.id), 1)
                                    }
                                }

                            }
                            if (! taglist.isSelected(indexPath)) {
                                edittags(data.id, false)
                            } else {
                                edittags(data.id, true)
                            }
                            selectedlist = arr
                            console.log("selectedlist lenght " + selectedlist.length)
                        }

                        onSelectionChanged: {

                        }
                        listItemComponents: [
                            ListItemComponent {
                                type: ""
                                StandardListItem {
                                    title: ListItemData.name
                                }
                            }
                        ]
                    }
                }
                attachedObjects: [
                    SystemToast {
                        id: savtasks
                        body: qsTr("Saving ...")
                    }
                ]
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
                        title: qsTr("Back")
                        onTriggered: {
                            duedate.close()
                        }
                    }
                    acceptAction: ActionItem {
                        title: qsTr("Save")
                        onTriggered: {
                            task_duedate.text = task_datepicker.value.getFullYear() + "-" + (task_datepicker.value.getMonth() + 1) + "-" + task_datepicker.value.getDate()
                            savdate.show()
                            saveDueDate(true)
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
                attachedObjects: [
                    SystemToast {
                        id: savdate
                        body: qsTr("Saving ...")
                    }
                ]
            }
        }
    ]

    onCreationCompleted: {
        render()
        app.taskViewUpdate.connect(renderAgain)
    }
    function renderAgain() {
        render()
    }
    function render() {
        var data = app.getTasks(v_var)
        console.log(JSON.stringify("task data" + data))
        info = data[0]
        if (info.due != null || info.due != "") {
            var dt = info.due
            var darray = []
            darray = dt.split("-")
            task_datepicker.value = new Date(darray[0], darray[1] - 1, darray[2])
        }
        task_name.text = info.name
        task_description.text = info.notes
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
        var lis_array = []
        var taglista = app.getTagsByTaskId(v_var, activeworkspace)
        tagslabel.text = ""
        for (var i = 0; i < taglista.length; i ++) {
            tagslabel.text += taglista[i].name + "| "
        }
    }
    titleBar: TitleBar {
        title: qsTr("Edit Task")

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
                    text: qsTr("Task Name")
                }
                TextArea {
                    onFocusedChanged: {
                        if (! focused) {
                            if (text.length > 0) {
                                saveNote()
/*                                savetsk.show()
*/                            }
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
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Label {
                    textStyle.fontSize: FontSize.Medium
                    textStyle.textAlign: TextAlign.Right
                    verticalAlignment: VerticalAlignment.Center
                    text: qsTr("Description")
                }
                TextArea {

                    textStyle.textAlign: TextAlign.Right
                    horizontalAlignment: HorizontalAlignment.Fill
                    backgroundVisible: false
                    id: task_description
                    hintText: qsTr("Enter Text")
                    input.submitKey: SubmitKey.Next
                    input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                    autoSize.maxLineCount: 10
                    onFocusedChanged: {
                        if (! focused) {
                            if (text.length > 0) {
                                saveNote()
          /*                      savetsk.show()*/
                            }
                        }
                    }
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
                                    task_assigner_label.text = qsTr("Assigned To")
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
                                console.log(imageSource.toString())
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
                    text: qsTr("Due by")
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
            Container {
                topPadding: ui.du(3)
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Label {
                    gestureHandlers: [
                        TapHandler {
                            onTapped: {
                                tags.open()
                            }
                        }
                    ]
                    verticalAlignment: VerticalAlignment.Center
                    textStyle.fontSize: FontSize.Medium
                    text: qsTr("Tags")
                }
                TextArea {
                    gestureHandlers: [
                        TapHandler {
                            onTapped: {
                                tags.open()
                            }
                        }
                    ]
                    backgroundVisible: false
                    editable: false
                    textStyle.textAlign: TextAlign.Right
                    id: tagslabel
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
                if (task_name.text.length > 0) {
                    saveNote()
                    savetsk.body = qsTr("saving...")
                    savetsk.show()
                } else {
                    savetsk.body = qsTr("task name is empty")
                    savetsk.show()
                }

            }
        }
    ]
    function justinfo(input) {
        Insert.insert(input)
        app.taskViewSendwUpdate(v_var)
    }
    function saveNote() {
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks/" + v_var
        var param = {
            name: task_name.text,
            notes: task_description.text
        }
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var input = JSON.parse(doc.responseText)
                    justinfo(input)
                    app.taskViewSendwUpdate(v_var)
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
    function serialize(obj, prefix) {
        var str = [];
        for (var p in obj) {
            var k = prefix ? prefix + "[" + p + "]" : p, v = obj[p];
            str.push(typeof v == "object" ? serialize(v, k) : encodeURIComponent(k) + "=" + encodeURIComponent(v));
        }
        return str.join("&");
    }
    function saveDueDate(check) {
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks/" + v_var
        if (check == true) {
            var param = {
                due_on: task_datepicker.value.toISOString()
            }
        } else {
            var param = {
                due_on: "null"
            }
            app.removeTask(v_var)
        }
        console.log(JSON.stringify(param))
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var input = JSON.parse(doc.responseText)
                    justinfo(input)
                    duedate.close()
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
        var url = endpoint + "tasks/" + v_var
        var param = null
        if (id) {
            param = "assignee=" + id
        } else {
            param = "assignee=null"
            app.removeTask(v_var)
        }

        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var input = JSON.parse(doc.responseText)
                    justinfo(input)
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
    function edittags(id, check) {
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks/" + v_var
        if (check == true) {
            url += "/addTag"
        } else {
            url += "/removeTag"
        }
        var followers = "tag=" + id
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var input = JSON.parse(doc.responseText).data
                    if (check == true) {
                        app.updateTaskTags(id, v_var, true)
                    } else {
                        app.updateTaskTags(id, v_var, false)
                    }
                    app.taskViewSendwUpdate(v_var)
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
        doc.send(followers);
    }
    function addtag(data) {
        var doc = new XMLHttpRequest();
        var param = "name=" + data
        var url = endpoint + "workspaces/" + activeworkspace + "/tags"
        console.log(param)
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 201) {
                    var data = JSON.parse(doc.responseText)
                    console.log(doc.responseText)
                    var info = data.data
                    app.insertTagMeta(info.id, info.name, activeworkspace)
                    searchtagupdate()
                    selectionlisttag(all_tags)
                    refreshList(selectedlist)
                } else {
                    console.log("STATUS:" + doc.status + " \nHEADERS: " + doc.getAllResponseHeaders() + "\n BODY: " + doc.responseText);
                }
            }
        }
        doc.open("post", url);
        doc.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        doc.setRequestHeader("Authorization", "Basic " + token);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send(param);
    }
}
