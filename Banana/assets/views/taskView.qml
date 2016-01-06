import bb.cascades 1.3
import bb.system 1.2
import "../moment.js" as Moment
import "../inserttask.js" as Insert
Page {
    property variant commentimage: filepathname["data"]
    property variant v_var
    property variant v_assignee

    function isPhotoAvailable(userid) {
        return app.isPhotoAvailable(userid)
    }
    function selectionlistfollowers() {
        var allfollowers = app.getTaskFollowers(v_var);
        for (var i = 0; i < taskfollowerslist.dataModel.size(); i ++) {
            for (var j = 0; j < allfollowers.length; j ++) {
                if (allfollowers[j].id == taskfollowerslist.dataModel.value(i).id) {
                    taskfollowerslist.select([ i ])
                }
            }
        }
    }
    function searchupdate() {
        if (info.assignee) {

        }
        userslist.dataModel.clear()
        userslist.dataModel.append(app.getUsersBySearch(usersearch.text))
    }
    function searchfollowersupdate() {
        taskfollowerslist.dataModel.clear()
        taskfollowerslist.dataModel.append(app.getUsersBySearch(tasksearch.text, activeworkspace))
    }

    onCreationCompleted: {
        Qt.rendertask = rendertask
        Qt.isPhotoAvailable = isPhotoAvailable
        Qt.completeSubTask = completeSubTask
        Qt.commentimage = commentimage
        Qt.c_language = app.getCurrentLanguage()
        Qt.app = app;
        app.taskViewUpdate.connect(renderAgain)
        app.subTaskViewUpdate.connect(renderAgain)

    }
    onV_varChanged: {
        Qt.c_language = app.getCurrentLanguage()
        rendertask()
        loadstories()
        subtasks()
    }
    function renderAgain(id) {
        rendertask()
    }
    function rendertask() {
        console.log("hello this is render task functions")
        var data = app.getTasks(v_var)

        var info = data[0]
        taskname.text = info.name
        fav.visible = info.fav
        if (info.notes) {
            notescontainer.visible = true
            tasknote.text = info.notes
        } else {
            notescontainer.visible = false
        }
        if (info.due) {
            duedate.visible = true
            duedate.text = Moment.moment(info.due).locale(Qt.c_language).format("ll")
        } else {
            duedate.visible = true
            duedate.text = qsTr("No deadline")

        }
        if (info.assignee) {
            var userdata = app.getUserByID(info.assignee)
            var userinfo = userdata[0]
            task_assigned.text = userinfo.name
            console.log(JSON.stringify(userinfo))
            iamge.imageSource = isPhotoAvailable(userinfo.id) ? (commentimage + "/ahammedia/" + userinfo.id + ".png") : ("asset:///Images/BBicons/ic_contact.png")
            task_assigned.visible = true
        } else {
            task_assigned.text = qsTr("No assignee")
            task_assigned.visible = true
        }

        var projectslista = app.getTagsProjectList(v_var)
        var projectslistaa = app.getTagsProjectList(v_var)
        projectslist.text = "<html>"
        if (projectslista.length > 0) {
            procontainer.visible = true
            for (var i = 0; i < projectslistaa.length; i ++) {
                var themecolor = ui.palette.primary
                projectslist.text += "<span>" + projectslista[i].projectname + "</span><span style='color:" + Color.toHexString(themecolor) + "'>|</span>"
            }
        } else {
            procontainer.visible = false
        }
        projectslist.text += "</html>"

        var tags = []
        var tagsdata = app.getTagsByTaskId(v_var, activeworkspace)
        var taglista = app.getTagsByTaskId(v_var, activeworkspace)
        task_tags.text = "<html>"
        if (taglista.length > 0) {
            tagcontainer.visible = true
            for (var i = 0; i < taglista.length; i ++) {
                var themecolor = ui.palette.primary

                task_tags.text += "<span>" + "</span><span style='color:" + Color.toHexString(themecolor) + "'>|</span>" + taglista[i].name
            }
        } else {
            tagcontainer.visible = false
        }
        task_tags.text += "</html>"
        subtaskslist.dataModel.clear()
        subtaskslist.dataModel.append(app.getSubTasks(v_var))
        checksubtasks()
    }
    titleBar: TitleBar {
        kind: TitleBarKind.FreeForm
        kindProperties: FreeFormTitleBarKindProperties {
            content: Container {
                Container {

                    horizontalAlignment: HorizontalAlignment.Fill
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }

                    background: Color.create("#282828")
                    verticalAlignment: VerticalAlignment.Center
                    topPadding: 5
                    Container {

                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight

                        }
                        verticalAlignment: VerticalAlignment.Fill
                        leftPadding: 10
                        topPadding: 3
                        bottomPadding: 10
                        Container {

                            verticalAlignment: VerticalAlignment.Center

                            maxHeight: 70
                            maxWidth: 70
                            layout: AbsoluteLayout {

                            }
                            ImageView {
                                id: iamge
                                maxHeight: 68
                                maxWidth: 68

                            }
                            ImageView {
                                maxHeight: 70
                                maxWidth: 70
                                imageSource: "asset:///Images/120hexagonringgrey.png"

                            }

                        }

                        Container {

                            leftPadding: 15
                            verticalAlignment: VerticalAlignment.Center
                            Label {
                                textStyle.textAlign: TextAlign.Right
                                id: task_assigned
                            }
                        }
                    }
                    Container {

                        verticalAlignment: VerticalAlignment.Center
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        rightPadding: ui.du(3.0)
                        Label {
                            id: duedatelabel

                            text: qsTr("Due by :")
                        }
                        Label {

                            verticalAlignment: VerticalAlignment.Center
                            id: duedate
                        }
                    }

                }
            }
        }
    }
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill

        Container {
            leftPadding: ui.du(2)
            bottomPadding: ui.du(2)
            rightPadding: ui.du(2)
            topPadding: ui.du(2)
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                //taskname container
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                verticalAlignment: VerticalAlignment.Center
                CheckBox {
                    scaleX: .85
                    scaleY: .85
                    onCheckedChanged: {
                        if (checked) {
                            completeTask(true)
                            compltetoast.show()
                        } else {
                            completeTask(false)
                            notcompltetoast.show()
                        }
                    }
                }
                Label {
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    multiline: true
                    id: taskname
                    textStyle.fontSize: FontSize.Large
                    verticalAlignment: VerticalAlignment.Center
                }
                Container {
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: -1
                    }
                    background: Application.themeSupport.theme.colorTheme.primary
                    ImageView {
                        visible: false

                        id: fav
                        imageSource: "asset:///Images/BBicons/ic_heartblack.png"
                        maxHeight: 40
                        maxWidth: 40
                    }

                }

            }
            Container {
                Container {
                    id: notescontainer
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Center
                    Container {
                        layout: AbsoluteLayout {

                        }
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Center

                        Container {
                            horizontalAlignment: HorizontalAlignment.Fill
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight

                            }
                            verticalAlignment: VerticalAlignment.Center
                            Label {
                                opacity: 0.7
                                text: qsTr("Notes")
                                textStyle.fontSize: FontSize.Medium
                                textStyle.fontSizeValue: 10
                            }
                            Label {
                                verticalAlignment: VerticalAlignment.Center
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                                id: tasknote
                                textStyle.textAlign: TextAlign.Left
                                textStyle.fontSize: FontSize.XSmall
                                textStyle.fontFamily: "Tunga"
                                textStyle.fontStyle: FontStyle.Normal
                                multiline: true

                            }
                        }
                    }

                }

                Container {
                    id: procontainer

                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Center
                    visible: true
                    Container {
                        layout: AbsoluteLayout {

                        }
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Center

                        Container {
                            horizontalAlignment: HorizontalAlignment.Fill
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight

                            }
                            verticalAlignment: VerticalAlignment.Center
                            Label {
                                opacity: 0.7
                                text: qsTr("Projects")
                                textStyle.fontSize: FontSize.Medium
                                textStyle.fontSizeValue: 10

                            }
                            Label {
                                verticalAlignment: VerticalAlignment.Center
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                                id: projectslist
                                textStyle.textAlign: TextAlign.Left
                                textStyle.fontSize: FontSize.Small
                                textStyle.fontStyle: FontStyle.Normal
                                multiline: true
                            }
                        }
                    }

                }
                Container {
                    id: tagcontainer
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Center
                    Container {
                        layout: AbsoluteLayout {

                        }
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Center

                        Container {
                            horizontalAlignment: HorizontalAlignment.Fill
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight

                            }
                            verticalAlignment: VerticalAlignment.Center
                            Label {
                                opacity: 0.7
                                text: qsTr("Tags")
                                textStyle.fontSize: FontSize.Medium
                                textStyle.fontSizeValue: 10

                            }
                            Label {
                                verticalAlignment: VerticalAlignment.Center
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                                id: task_tags
                                textStyle.textAlign: TextAlign.Left
                                textStyle.color: Color.White
                                textStyle.fontSize: FontSize.Small
                                textStyle.fontFamily: "Tunga"
                                textStyle.fontStyle: FontStyle.Normal
                                multiline: true
                                textFormat: TextFormat.Html

                            }
                        }
                    }

                }
                SegmentedControl {
                    options: [
                        Option {
                            text: qsTr("Story")
                            value: "Story"

                        },
                        Option {
                            text: qsTr("SubTasks")
                            value: "SubTasks"
                        },
                        Option {
                            text: qsTr("Attached")
                            value: "Attachments"
                        }

                    ]
                    onSelectedOptionChanged: {
                        switch (selectedValue) {
                            case "Story":
                                {
                                    subtaskscontainer.visible = false
                                    storiescontainer.visible = true
                                    attachmentscontainer.visible = false

                                    break
                                }
                            case "SubTasks":
                                {
                                    storiescontainer.visible = false
                                    subtaskscontainer.visible = true
                                    attachmentscontainer.visible = false

                                    break
                                }
                            case "Attachments":
                                {
                                    storiescontainer.visible = false
                                    subtaskscontainer.visible = false
                                    attachmentscontainer.visible = true
                                    break
                                }
                        }
                    }
                }
                Container {
                    SegmentedControl {
                        options: [
                            Option {
                                text: qsTr("Comments")
                                value: "Story"
                            },
                            Option {
                                text: qsTr("Activity")
                                value: "Activity"
                            }
                        ]
                        onSelectedOptionChanged: {
                            switch (selectedValue) {
                                case "Activity":
                                    {
                                        activitycontainer.visible = true
                                        commentscontainer.visible = false
                                        break
                                    }
                                case "Story":
                                    {
                                        activitycontainer.visible = false
                                        commentscontainer.visible = true
                                        break
                                    }
                            }
                        }
                    }
                    id: storiescontainer
                    Container {
                        layout: DockLayout {

                        }
                        Container {
                            id: commentstab
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Center
                            Label {
                                text: qsTr("No comments") + Retranslate.onLanguageChanged
                                horizontalAlignment: HorizontalAlignment.Center
                                verticalAlignment: VerticalAlignment.Center
                                textStyle.color: ui.palette.primary
                                opacity: .5
                                textStyle.fontSize: FontSize.PointValue
                                textStyle.fontSizeValue: 8
                                layoutProperties: StackLayoutProperties {
                                }
                            }
                            Button {
                                onClicked: {
                                    commentbox.show()
                                }
                                preferredWidth: ui.du(1)

                                text: qsTr("Add Comment") + Retranslate.onLanguageChanged
                                horizontalAlignment: HorizontalAlignment.Center
                                verticalAlignment: VerticalAlignment.Center
                                appearance: ControlAppearance.Default

                            }
                        }
                        id: commentscontainer
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        ListView {
                            visible: false
                            id: storieslist
                            onTouch: {
                                var begin;
                                var end;
                                //                                console.log(event.windowX,event.windowY)

                            }
                            dataModel: ArrayDataModel {
                            }

                            listItemComponents: [
                                ListItemComponent {
                                    type: ""
                                    Comment {
                                        imagefilepath: Qt.isPhotoAvailable(ListItemData.created_by.id) ? (Qt.commentimage + "/ahammedia/" + ListItemData.created_by.id + ".png") : ("asset:///Images/singlebananna.png")
                                        usertext: ListItemData.created_by.name
                                        commenttext: ListItemData.text
                                        commenttime: Moment.moment(ListItemData.created_at).locale(Qt.c_language).calendar()
                                    }
                                }
                            ]

                        }
                    }
                    Container {

                        visible: false
                        id: activitycontainer
                        ListView {

                            id: activitylist
                            dataModel: ArrayDataModel {
                            }
                            listItemComponents: [
                                ListItemComponent {
                                    type: ""
                                    Activity {
                                        imagefilepath: Qt.app.isPhotoAvailable(ListItemData.created_by.id) ? (Qt.commentimage + "/ahammedia/" + ListItemData.created_by.id + ".png") : ("asset:///Images/singlebananna.png")
                                        usertext: ListItemData.created_by.name
                                        commenttext: ListItemData.text
                                        commenttime: Moment.moment(ListItemData.created_at).locale(Qt.c_language).calendar()
                                    }
                                }
                            ]
                        }
                    }
                }

                Container {
                    layout: DockLayout {

                    }
                    Container {
                        id: subtasktab
                        horizontalAlignment: HorizontalAlignment.Center
                        verticalAlignment: VerticalAlignment.Fill
                        Label {
                            text: qsTr("No subtasks") + Retranslate.onLanguageChanged
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Center
                            textStyle.color: ui.palette.primary
                            opacity: .5
                            textStyle.fontSize: FontSize.PointValue
                            textStyle.fontSizeValue: 8
                            layoutProperties: StackLayoutProperties {
                            }
                        }
                        Button {
                            onClicked: {
                                navigationpane.push(newsubtask.createObject())

                            }
                            preferredWidth: ui.du(1)
                            text: qsTr("Add subtask") + Retranslate.onLanguageChanged
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Center
                            appearance: ControlAppearance.Default

                        }
                    }
                    id: subtaskscontainer
                    visible: false
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    ListView {
                        id: subtaskslist
                        visible: false
                        dataModel: ArrayDataModel {
                        }
                        onTriggered: {
                            var sub_page = subtaskpage.createObject();
                            sub_page.sub_task_id = dataModel.data(indexPath).id
                            navigationpane.push(sub_page)
                        }
                        listItemComponents: [
                            ListItemComponent {
                                type: ""
                                Subtask {
                                    imagefilepath: Qt.isPhotoAvailable(ListItemData.assignee) ? (Qt.commentimage + "/ahammedia/" + ListItemData.assignee + ".png") : ("asset:///Images/singlebanana.png")
                                    commenttext: ListItemData.name
                                    commenttime: ListItemData.due
                                    usertext: (Qt.app.getUserByID(ListItemData.assignee))[0].name
                                    complete: ListItemData.completed
                                    onCreationCompleted: {
                                        console.log(JSON.stringify(ListItemData))
                                    }
                                    onCompleteTask: {
                                        Qt.completeSubTask(ListItemData.id, true)
                                    }
                                    onUncompleteTask: {
                                        Qt.completeSubTask(ListItemData.id, false)
                                    }
                                    onOpenSubTask: {
                                        var sub_page = subtaskpage.createObject();
                                        sub_page.sub_task_id = ListItemData.id
                                        navigationpane.push(sub_page)
                                    }
                                }
                            }
                        ]
                    }
                }
                Container {
                    id: attachmentscontainer
                    visible: false
                    layout: GridLayout {

                    }

                    Container {
                        id: attachtab
                        horizontalAlignment: HorizontalAlignment.Center
                        Label {
                            visible: (attachmentslist.dataModel.size() < 1)
                            text: qsTr("No attachments") + Retranslate.onLanguageChanged
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Center
                            textStyle.color: ui.palette.primary
                            opacity: .5
                            textStyle.fontSize: FontSize.PointValue
                            textStyle.fontSizeValue: 8
                            layoutProperties: StackLayoutProperties {
                            }
                        }
                        Button {
                            onClicked: {
                                commentbox.show()
                            }
                            preferredWidth: ui.du(1)

                            text: qsTr("Attach File") + Retranslate.onLanguageChanged
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Center
                            appearance: ControlAppearance.Default

                        }
                    }
                    ListView {
                        layout: GridListLayout {

                        }
                        id: attachmentslist
                        dataModel: ArrayDataModel {
                            onItemAdded: {
                                attachmentslist.visible = true
                                attachtab.visible = false
                            }
                        }
                        onTriggered: {
                            var data = dataModel.value(indexPath)
                            var ite = data.text.split("asset_id=")
                            getattachments(ite[1])
                        }
                        onCreationCompleted: {
                            if (dataModel.size() >= 1) {
                                attachmentslist.visible = true
                                attachtab.visible = false
                            } else {
                                attachmentslist.visible = false
                                attachtab.visible = true
                            }
                        }
                        listItemComponents: [

                            ListItemComponent {
                                type: ""
                                Attachment {
                                    file: ListItemData.name
                                    usertext: ListItemData.created_by.name
                                    commenttime: Moment.moment(ListItemData.created_at).locale(Qt.c_language).calendar()
                                }
                            }
                        ]
                    }
                }
            }

        }
    }
    actions: [
        ActionItem {
            title: qsTr("Edit Task")
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "asset:///Images/BBicons/ic_edit.png"
            onTriggered: {
                var editTask = task_edit.createObject();
                navigationpane.push(editTask)
            }
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.Edit
                }
            ]

        },
        ActionItem {
            title: qsTr("Add Comment")
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "asset:///Images/BBicons/ic_compose.png"
            onTriggered: {
                commentbox.show()
            }
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                }
            ]
        },
        ActionItem {

            title: qsTr("Favorite")
            ActionBar.placement: ActionBarPlacement.InOverflow
            imageSource: "asset:///Images/BBicons/ic_heart.png"
            onTriggered: {
                favTask()
            }
        },
        ActionItem {
            title: qsTr("Add SubTask")
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "asset:///Images/BBicons/ic_add.png"
            onTriggered: {
                navigationpane.push(newsubtask.createObject())
            }
        },
        ActionItem {
            title: qsTr("Followers")
            ActionBar.placement: ActionBarPlacement.InOverflow
            imageSource: "asset:///Images/BBicons/ic_add_to_contacts.png"
            onTriggered: {
                task_followers_sheet.open()
            }
        },
        /* ActionItem {
         * title: "Task Completed"
         * imageSource: "asset:///Images/BBicons/ic_done.png"
         * onTriggered: {
         * completeTaskDilog.show()
         * }
         },*/
        ActionItem {
            title: qsTr("Refresh")
            imageSource: "asset:///Images/BBicons/ic_reload.png"
            onTriggered: {
                refreshtask()
            }
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.Reply
                }
            ]
        },
        DeleteActionItem {
            onTriggered: {
                deleteTaskDilog.show()
            }
        }
    ]
    attachedObjects: [
        ComponentDefinition {
            id: newsubtask
            source: "asset:///new/newSubTask.qml"
        }/*,

        ComponentDefinition {
            id: taskfollowers
            source: "asset:///followers/TaskFollowers.qml"
        }*/,
        ComponentDefinition {
            id: subtaskpage
            source: "asset:///edit/EditSubTask.qml"
        },
        SystemPrompt {
            id: commentbox
            title: qsTr("Enter Comment")
            rememberMeChecked: false
            includeRememberMe: false
            confirmButton.enabled: true
            cancelButton.enabled: true
            inputField.emptyText: qsTr("Comment")
            onFinished: {
                if (result == SystemUiResult.ConfirmButtonSelection) {
                    storiescomment(commentbox.inputFieldTextEntry())
                }
            }
        },
        SystemDialog {
            id: completeTaskDilog
            title: qsTr("Task Completed")
            body: qsTr("Are you sure you completed this task")
            confirmButton.enabled: true
            cancelButton.enabled: true
            onFinished: {
                if (result == SystemUiResult.ConfirmButtonSelection) {
                    completeTask(true)

                }

            }
        },
        SystemDialog {
            id: deleteTaskDilog
            title: qsTr("Delete Task")
            body: qsTr("Do you want to Delete this task?")
            confirmButton.enabled: true
            confirmButton.label: qsTr("Yes")
            cancelButton.enabled: true
            onFinished: {
                if (result == SystemUiResult.ConfirmButtonSelection) {
                    deleteTask()
                    deletetoast.show()
                }

            }
        },
        SystemToast {
            id: deletetoast
            body: qsTr("Task deleted")
        },
        SystemToast {
            id: compltetoast
            body: qsTr("Marked as completed")
        },
        SystemToast {
            id: notcompltetoast
            body: qsTr("Marked as not completed")
        },
        ComponentDefinition {
            id: task_edit
            source: "asset:///edit/EditTask.qml"
        },
        Sheet {
            id: task_followers_sheet
            onOpened: {
                searchfollowersupdate()
                selectionlistfollowers()
            }

            Page {
                function onSave() {

                }
                titleBar: TitleBar {
                    visibility: ChromeVisibility.Visible
                    title: qsTr("Followers")
                    dismissAction: ActionItem {
                        title: qsTr("Done")
                        onTriggered: {
                            task_followers_sheet.close()
                            followers_toast.show()
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
                        id: tasksearch
                        onTextChanging: {
                            searchfollowersupdate()
                            selectionlistfollowers()
                        }
                    }
                    ListView {
                        id: taskfollowerslist
                        dataModel: ArrayDataModel {
                        }

                        onTriggered: {
                            toggleSelection(indexPath)
                            var data = dataModel.data(indexPath);
                            if (isSelected(indexPath)) {
                                updatefollowers(data.id, true)
                            } else {
                                updatefollowers(data.id, false)
                            }
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
                        id: followers_toast
                        body: qsTr("Saving Followers")
                    }
                ]
            }
            onClosed: {

            }
        }
    ]
    actionBarVisibility: ChromeVisibility.Default
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.Default
    actionBarFollowKeyboardPolicy: ActionBarFollowKeyboardPolicy.Default
    resizeBehavior: PageResizeBehavior.None
    function checkcomments() {
        if (storieslist.dataModel.size() > 0) {
            storieslist.visible = true
            commentstab.visible = false
        } else {
            storieslist.visible = false
            commentstab.visible = true
        }
    }
    function checksubtasks() {
        if (subtaskslist.dataModel.size() > 0) {
            subtaskslist.visible = true
            subtasktab.visible = false
        } else {
            subtaskslist.visible = false
            subtasktab.visible = true
        }
    }
    function refreshtask() {
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks/" + v_var
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var input = JSON.parse(doc.responseText)
                    justinfo(input)
                    loadstories()
                    subtasks()
                    rendertask()

                } else {
                    console.log("STATUS:" + doc.status + " \nHEADERS: " + doc.getAllResponseHeaders() + "\n BODY: " + doc.responseText);
                }
            }
        }
        doc.open("get", url);
        doc.setRequestHeader("Authorization", "Basic " + token);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send();
    }
    function loadstories() {
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks/" + v_var + "/stories"
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var data = JSON.parse(doc.responseText)
                    storieslist.dataModel.clear()
                    activitylist.dataModel.clear()
                    attachmentslist.dataModel.clear()
                    for (var i = 0; i < data.data.length; i ++) {

                        if (data.data[i].type == "comment") {
                            storieslist.dataModel.append(data.data[i])
                        }
                        if (data.data[i].type == "system") {
                            if (data.data[i].text.indexOf("attached") >= 0) {
                                var ite = data.data[i]
                                var id = ite.text.split("asset_id=")
                                ite.id = id[1]
                                attachmentslist.dataModel.append(ite)

                            } else {
                                activitylist.dataModel.append(data.data[i])

                            }
                        }
                        if (i == data.data.length - 1) {

                        }
                    }
                    if (attachmentslist.dataModel.size() > 0) {
                        console.log("Attachemnst startd")
                        
                        getattachmentsmeta(v_var)
                    }
                    checkcomments()
                } else {
                    console.log("STATUS:" + doc.status + " \nHEADERS: " + doc.getAllResponseHeaders() + "\n BODY: " + doc.responseText);
                }
            }
        }
        doc.open("get", url);
        doc.setRequestHeader("Authorization", "Basic " + token);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send();
    }
    function subtasks() {
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks/" + v_var + "/subtasks"
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var data = JSON.parse(doc.responseText)
                    for (var i = 0; i < data.data.length; i ++) {
                        var task = data.data[i];

                        app.insertTempTask(task.id, true)
                        if (i == data.data.length - 1) {
                            grabtaskmeta()
                        }
                    }
                    if (data.data.length == 0) {
                        grabtaskmeta()
                    }
                } else {
                    console.log("STATUS:" + doc.status + " \nHEADERS: " + doc.getAllResponseHeaders() + "\n BODY: " + doc.responseText);
                }
            }
        }
        doc.open("get", url);
        doc.setRequestHeader("Authorization", "Basic " + token);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send();
    }
    function grabtaskmeta() {
        var temproj = app.getTempTaskId()
        if (temproj) {
            insertSubtasks(temproj)
        } else {
            subtaskslist.dataModel.clear()
            subtaskslist.dataModel.append(app.getSubTasks(v_var))
        }
    }
    function insertSubtasks(temproj) {
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks/" + temproj
        console.log("getting sub tasks" + url)
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var input = JSON.parse(doc.responseText)
                    justinfo(input)
                    app.insertTempTask(temproj, false)
                    app.insertSubTasks(input.data.parent.id, input.data.id)
                    grabtaskmeta()

                } else {
                    console.log("STATUS:" + doc.status + " \nHEADERS: " + doc.getAllResponseHeaders() + "\n BODY: " + doc.responseText);
                }
            }
        }
        doc.open("get", url);
        doc.setRequestHeader("Authorization", "Basic " + token);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send();
    }
    function completeTask(type) {
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks/" + v_var
        var param = {
            completed: type
        }
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var input = JSON.parse(doc.responseText)
                    justinfo(input)
                    app.projectViewUpdate(activeproject)
                    app.flushSubTasks(v_var)
                    rendertask()
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
    function favTask() {
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks/" + v_var
        var param = {
            hearted: !fav.visible
        }
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var input = JSON.parse(doc.responseText)
                    justinfo(input)
                    
                    rendertask()
                    app.projectViewUpdate(activeproject)

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
    function deleteTask() {
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks/" + v_var
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    app.deleteTask(v_var)
                    navigationpane.pop()
                } else {
                    console.log("STATUS:" + doc.status + " \nHEADERS: " + doc.getAllResponseHeaders() + "\n BODY: " + doc.responseText);
                }
            }
        }
        doc.open("DELETE", url);
        doc.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        doc.setRequestHeader("Authorization", "Basic " + token);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.setRequestHeader("User-Agent", "Banana-BB10");
        doc.send();
    }
    function storiescomment(data) {
        var doc = new XMLHttpRequest();
        var param = {
            text: data
        }
        var url = endpoint + "tasks/" + v_var + "/stories"
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 201) {
                    var data = JSON.parse(doc.responseText)
                    storieslist.dataModel.append(data.data)
                    checkcomments()
                } else {
                    console.log("STATUS:" + doc.status + " \nHEADERS: " + doc.getAllResponseHeaders() + "\n BODY: " + doc.responseText);
                }
            }
        }
        doc.open("post", url);
        doc.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        doc.setRequestHeader("Authorization", "Basic " + token);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send(serialize(param));
    }
    function updatefollowers(id, check) {
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks/" + v_var
        if (check == true) {
            url += "/addFollowers"
        } else {
            url += "/removeFollowers"
        }
        var followers = "followers[0]=" + id
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var input = JSON.parse(doc.responseText)
                    justinfo(input)
                    selectionlistfollowers()
                    rendertask()
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

    function getattachmentsmeta(ida) {
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks/" + ida + "/attachments"
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var data = JSON.parse(doc.responseText)
                    console.log(doc.responseText)
                    for (var i = 0; i < attachmentslist.dataModel.size(); i ++) {
                        for (var j = 0; j < data.data.length; j ++) {
                            var ite = data.data[j]
                            if (attachmentslist.dataModel.value(i).id == ite.id) {
                                var newitem = attachmentslist.dataModel.value(i)
                                newitem.name = ite.name
                                attachmentslist.dataModel.replace(i, newitem)
                            }
                        }

                    }
                } else {
                    console.log("STATUS:" + doc.status + " \nHEADERS: " + doc.getAllResponseHeaders() + "\n BODY: " + doc.responseText);
                }
            }
        }
        doc.open("get", url);
        doc.setRequestHeader("Authorization", "Basic " + token);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send();
    }
    function getattachments(ida) {
        var doc = new XMLHttpRequest();
        var url = endpoint + "attachments/" + ida
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var data = JSON.parse(doc.responseText)

                } else {
                    console.log("STATUS:" + doc.status + " \nHEADERS: " + doc.getAllResponseHeaders() + "\n BODY: " + doc.responseText);
                }
            }
        }
        doc.open("get", url);
        doc.setRequestHeader("Authorization", "Basic " + token);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send();
    }
    function completeSubTask(subid, boo) {
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks/" + subid
        var param = {
            completed: boo
        }
        console.log(JSON.stringify(param))
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var input = JSON.parse(doc.responseText).data
                    if (input) {
                        justinfo(input)
                        app.insertTask(insert);
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
    function justinfo(input) {
        Insert.insert(input)
    }
}
