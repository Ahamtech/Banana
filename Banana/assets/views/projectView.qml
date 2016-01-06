import bb.cascades 1.3
import "../moment.js" as Moment
import "../inserttask.js" as Insert
Page {
    property int refreshfinished: 0
    signal refresh
    signal edit
    property variant mediapath: filepathname["data"]
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

    onRefreshfinishedChanged: {
        refreshicon.enabled = true
        rotateanimate.stop()
    }
    onRefresh: {
        newProjectMeta()
    }
    onEdit: {
        navigationpane.push(projedit.createObject())
    }
    function searchfollowersupdate() {
        taskfollowerslist.dataModel.clear()
        taskfollowerslist.dataModel.append(app.getUsersBySearch(tasksearch.text))
    }
    onCreationCompleted: {
        Qt.app = app
        Qt.mediapath = mediapath
        Qt.completeTask = completeTask
        Qt.c_language = app.getCurrentLanguage()
        renderInit()
        app.projectupdated.connect(qemittest)
        app.projectDeleted.connect(deleted)
        app.taskViewUpdate.connect(qemittest)
    }
    function qemittest(data) {
        renderInit()
        search.dataModel.clear()
        search.dataModel.append(app.searchByProjectID(activeproject, ""))
    }
    function deleted(data) {
        if (activeproject == data)
            navigationpane.pop()
    }
    function renderInit() {
        refreshicon.enabled = true
        rotateanimate.stop()
        refreshicon.imageSource = "asset:///Images/BBicons/ic_reload.png"
        var sectionsdata = app.getSectionsByProjects(activeproject)
        selectionitems.removeAll()
        var option_object = section_option.createObject();
        option_object.text = "All"
        option_object.value = "All"
        selectionitems.add(option_object)
        var option_object_none = section_option.createObject();
        for (var i = 0; i < sectionsdata.length; i ++) {
            var optionobject = section_option.createObject();
            optionobject.text = sectionsdata[i].name
            optionobject.value = sectionsdata[i].value
            optionobject.objectName = sectionsdata[i].name
            selectionitems.add(optionobject)
        }
        var data = app.getProject(activeproject)
        var info = data[0]
        projectitle.text = info.name
        taskslist.dataModel.clear()
        taskslist.dataModel.insertList(app.getTasksModel(activeproject))
    }
    titleBar: TitleBar {
        id: customtitle

        kind: TitleBarKind.FreeForm
        kindProperties: FreeFormTitleBarKindProperties {

            Container {
                layout: DockLayout {

                }
                Label {

                    id: projectitle
                    horizontalAlignment: HorizontalAlignment.Left
                    verticalAlignment: VerticalAlignment.Center
                    textStyle.fontSize: FontSize.Large

                    gestureHandlers: TapHandler {
                        onTapped: {
                            edit()
                        }
                    }
                }

                Container {
                    horizontalAlignment: HorizontalAlignment.Right
                    verticalAlignment: VerticalAlignment.Center
                    animations: [
                        RotateTransition {

                            id: rotateanimate
                            toAngleZ: 360
                            fromAngleZ: 0
                            delay: 0
                            duration: 1000
                            easingCurve: StockCurve.ElasticIn
                            repeatCount: AnimationRepeatCount.Forever
                            onStopped: {
                                refreshicon.rotationZ = 0
                            }
                        }

                    ]
                    ImageView {
                        maxHeight: 70
                        maxWidth: 70
                        imageSource: "asset:///Images/BBicons/ic_reload.png"

                        gestureHandlers: [
                            TapHandler {
                                onTapped: {
                                    if (! rotateanimate.isPlaying()) {
                                        refreshicon.enabled = false
                                        rotateanimate.play()
                                        refresh()
                                    }
                                }
                            }
                        ]

                    }

                }
            }
        }
    }
    Container {
        id: datacontainer
        Container {
            rightPadding: ui.du(2.0)
            leftPadding: ui.du(2.0)
            topPadding: ui.du(1.0)
            DropDown {
                id: selectionitems

                title: qsTr("Select Section")
                expanded: false
                onExpandedChanged: {
                    if (selectedOption.value == "All") {
                        taskslist.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth)
                        return
                    }
                    var sectionname = selectedOption.text
                    var listindexpath = [];
                    listindexpath = taskslist.dataModel.find({
                            "sectionname": sectionname
                        })
                    taskslist.scrollToItem([ listindexpath[0] ])
                }
            }
        }
        ListView {
            layout: FlowListLayout {
                headerMode: ListHeaderMode.Sticky
            }
            gestureHandlers: PinchHandler {

            }
            snapMode: SnapMode.LeadingEdge
            attachedObjects: [
                ListScrollStateHandler {
                    id: handler

                }
            ]
            flickMode: FlickMode.Momentum

            id: taskslist
            dataModel: GroupDataModel {
                id: tasksmodel
                sortingKeys: [ "sectionname" ]
                grouping: ItemGrouping.ByFullValue
            }
            onTriggered: {
                var t_view = taskviewpage.createObject()
                var selectedItem = dataModel.data(indexPath);
                if (indexPath.length > 1) {
                    t_view.v_var = selectedItem["tasks.id"]
                    t_view.v_assignee = selectedItem["tasks.assignee"]
                    navigationpane.push(t_view)
                }
            }
            listItemComponents: [
                ListItemComponent {
                    type: "header"
                    CustomListItem {
                        horizontalAlignment: HorizontalAlignment.Fill
                        maxHeight: 70
                        verticalAlignment: VerticalAlignment.Fill
                        dividerVisible: false
                        CustomSectionHeader {
                            head: ListItemData
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            background: Color.Black
                            layout: DockLayout {

                            }
                            clipContentToBounds: false
                            implicitLayoutAnimationsEnabled: false
                        }
                    }
                },
                ListItemComponent {
                    type: "item"
                    CustomListTask {

                        fav: ListItemData["tasks.fav"]
                        taskname: ListItemData.taskname
                        tasktime: if (ListItemData["tasks.due"]) {
                            Moment.moment(ListItemData["tasks.due"]).locale(Qt.c_language).format("ll")
                        }
                        taskassigne: (Qt.app.getUserByID(ListItemData["tasks.assignee"]))[0].name
                        onComplete: {
                            Qt.completeTask(ListItemData["tasks.id"], true)
                        }
                        onIncomplete: {
                            Qt.completeTask(ListItemData["tasks.id"], false)
                        }
                    }

                }
            ]

        }
        Container {
            visible: false
            id: searchcontainer
            Container {
                verticalAlignment: VerticalAlignment.Center

                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Container {
                    TextField {
                        id: searchbox
                        hintText: qsTr("Search Tasks")
                        onTextChanging: {
                            search.dataModel.clear()
                            search.dataModel.append(app.searchByProjectID(activeproject, text))
                        }

                    }
                }
                Container {
                    verticalAlignment: VerticalAlignment.Top
                    ImageView {
                        imageSource: "asset:///Images/BBicons/ic_clears.png"
                        verticalAlignment: VerticalAlignment.Center

                        scaleX: .7
                        scaleY: .7
                        gestureHandlers: TapHandler {
                            onTapped: {
                                searchbox.text = ""
                                searchcontainer.visible = false
                                selectionitems.visible = true
                                taskslist.visible = true
                            }
                        }

                    }
                }
            }

            ListView {
                id: search
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
                        CustomListTask {
                            fav: ListItemData["fav"]
                            taskname: ListItemData.name
                            tasktime: if (ListItemData["due"]) {
                                Moment.moment(ListItemData["due"]).locale(Qt.c_language).format("ll")
                            }
                            taskassigne: (Qt.app.getUserByID(ListItemData["assignee"]))[0].name
                        }
                    }
                ]
            }
        }

    }
    actions: [

        ActionItem {
            title: qsTr("Search")
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "asset:///Images/BBicons/ic_search.png"
            onTriggered: {
                taskslist.visible = false
                selectionitems.visible = false
                searchcontainer.visible = true
                searchbox.requestFocus()
            }
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.Search
                }
            ]
        },
        ActionItem {
            title: qsTr("Add Task")
            ActionBar.placement: ActionBarPlacement.Signature
            imageSource: "asset:///Images/BBicons/ic_add.png"
            onTriggered: {
                navigationpane.push(addtaskpage.createObject())
            }
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                }
            ]
        },
        ActionItem {
            title: qsTr("My Tasks")
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "asset:///Images/BBicons/ic_view_details_dk.png"
            onTriggered: {
                navigationpane.push(mytasks.createObject())
            }
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.Forward
                }
            ]
        },
        ActionItem {
            title: qsTr("Members")
            ActionBar.placement: ActionBarPlacement.InOverflow
            imageSource: "asset:///Images/Team-Members-Icon.png"
            onTriggered: {
                navigationpane.push(projectfollowers.createObject())
            }
        },
        ActionItem {
            title: qsTr("Edit Project")
            imageSource: "asset:///Images/BBicons/ic_edit_list.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                navigationpane.push(projedit.createObject())
            }
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.Edit
                }
            ]
        },
        ActionItem {
            title: qsTr("Flush Project Cache And Sync")
            imageSource: "asset:///Images/BBicons/ic_sync.png"
            onTriggered: {
                app.flushProjectTasks(activeproject)
                renderInit()
                refreshicon.enabled = false
                rotateanimate.play()
                tasks()
            }
        }
    ]
    attachedObjects: [
        ComponentDefinition {
            id: section_option
            Option {

            }
        },
        Sheet {
            id: project_followers_sheet
            onOpened: {
                searchfollowersupdate()
                selectionlistfollowers()
            }

            Page {
                function onSave() {

                }
                titleBar: TitleBar {
                    visibility: ChromeVisibility.Visible
                    title: qsTr("Project Followers")
                    dismissAction: ActionItem {
                        title: qsTr("Cancel")
                        onTriggered: {
                            project_followers_sheet.close()
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
                        id: projectsearch
                        onTextChanging: {
                            searchfollowersupdate()
                            selectionlistfollowers()
                        }
                    }
                    ListView {
                        id: projectfollowerslist
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
            }
        },
        ComponentDefinition {
            id: projectfollowers
            source: "asset:///followers/ProjectFollowers.qml"
        },
        ComponentDefinition {
            id: taskviewpage
            source: "asset:///views/taskView.qml"
        },
        ComponentDefinition {
            id: projedit
            source: "asset:///edit/project.qml"
        },
        ComponentDefinition {
            id: addtaskpage
            source: "asset:///new/newTask.qml"
        },
        ComponentDefinition {
            id: mytasks
            source: "asset:///views/mytasks.qml"
        }
    ]
    function getcolor(id) {
        var col = {
            "dark-pink": "b13f94",
            "dark-green": "427e53",
            "dark-blue": "3c68bb",
            "dark-red": "c73f27",
            "dark-teal": "008eaa",
            "dark-brown": "906461",
            "dark-orange": "e17000",
            "dark-purple": "6743b3",
            "dark-warm-gray": "493c3d",
            "light-pink": "f4b6db",
            "light-green": "c9db9c",
            "light-blue": "b6c3db",
            "light-red": "b6c3db",
            "light-teal": "aad1eb",
            "light-yellow": "ffeda4",
            "light-orange": "facdaa",
            "light-purple": "dacae0",
            "light-warm-gray": "cec5c6"
        }
        return col[id]
    }
    function newProjectMeta() {
        var doc = new XMLHttpRequest();
        var url = endpoint + "projects/" + activeproject
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var info = JSON.parse(doc.responseText).data
                    var insert = {
                    }
                    insert["id"] = info.id
                    insert["name"] = info.name
                    insert["workspace"] = info.workspace.id
                    insert.created = Moment.moment(info["created_at"]).unix()
                    insert.modified = Moment.moment(info["modified_at"]).unix()
                    insert["notes"] = info.notes
                    insert["archive"] = info.archived
                    insert["color"] = getcolor(info.color)
                    app.insertProjects(insert)
                    app.flushProjectFollowers(info.id)
                    for (var i = 0; i < info.followers.length; i ++) {
                        app.insertProjectFollowers(info.followers[i].id, info.id)
                    }
                    for (var i = 0; i < info.followers.length; i ++) {
                        app.insertProjectMembers(info.followers[i].id, info.id)
                    }
                    updateproject()

                } else {
                    console.log("\n BODY: " + doc.responseText);
                }
            }
        }
        doc.open("get", url);
        doc.setRequestHeader("Authorization", "Basic " + token);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send();
    }
    function updateproject() {
        var doc = new XMLHttpRequest();
        var into = app.getProject(activeproject)
        var syncid = into[0].lastupdate
        var url = endpoint + "events?resource=" + activeproject + "&sync=" + syncid
        console.log(url)
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var data = JSON.parse(doc.responseText)
                    console.log(doc.responseText)
                    var v_ids = []
                    for (var i = 0; i < data.data.length; i ++) {
                        var task = data.data[i];
                        if (data.data[i].type == "task") {

                            if (v_ids.indexOf(task.resource.id) < 0) {
                                v_ids.push(task.resource.id)
                            }
                        }
                    }
                    for (var i = 0; i < v_ids.length; i ++) {
                        app.insertTempTask(v_ids[i], true)
                    }
                    app.projectLastUpdate(activeproject, data.sync)
                    grabtaskmeta()

                } else {
                    console.log("project update")
                    console.log("STATUS:" + doc.status + " \nHEADERS: " + doc.getAllResponseHeaders() + "\n BODY: " + doc.responseText);
                }
            }
            if (doc.readyState == 3) {
                if (doc.status == 412) {
                    var input = JSON.parse(doc.responseText)
                    app.projectLastUpdate(activeproject, input.sync)
                    updateproject()
                }
            }
        }
        doc.open("get", url);
        doc.setRequestHeader("Authorization", "Basic " + token);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send();
    }
    function tasks() {
        var doc = new XMLHttpRequest();
        var url = endpoint + "projects/" + activeproject + "/tasks" //lambda
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
            console.log(JSON.stringify(temproj))
            taskmeta(temproj)
        } else {
            console.log("Refresh Finished rendering iINt")
            renderInit()
        }
    }
    function taskmeta(id) {
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks/" + id
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var input = JSON.parse(doc.responseText)
                    Insert.insert(input)
                    app.insertTempTask(id, false)
                    grabtaskmeta()
                } else {
                    app.insertTempTask(id, false)
                    grabtaskmeta()
                    console.log("STATUS:" + doc.status + " \nHEADERS: " + doc.getAllResponseHeaders() + "\n BODY: " + doc.responseText);
                }
            }
        }
        doc.open("get", url);
        doc.setRequestHeader("Authorization", "Basic " + token);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send();
    }
    function serialize(obj, prefix) {
        var str = [];
        for (var p in obj) {
            var k = prefix ? prefix + "[" + p + "]" : p, v = obj[p];
            str.push(typeof v == "object" ? serialize(v, k) : encodeURIComponent(k) + "=" + encodeURIComponent(v));
        }
        return str.join("&");
    }
    function completeTask(sendid, type) {
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks/" + sendid
        var param = {
            completed: type
        }
        console.log(url)
        console.log(JSON.stringify(param))
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var input = JSON.parse(doc.responseText)
                    Insert.insert(input)
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
    function updatefollowers(id, check) {
        var doc = new XMLHttpRequest();
        var url = endpoint + "projects/" + v_var
        if (check == true) {
            url += "/addFollowers"
        } else {
            url += "/removeFollowers"
        }
        var followers = "followers[0]=" + id
        console.log(JSON.stringify(followers), url)
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var input = JSON.parse(doc.responseText)
                    Insert.insert(input)
                    app.insertTempTask(id, false)
                    selectionlistfollowers()
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
    shortcuts: [
        SystemShortcut {
            type: SystemShortcuts.Reply
            onTriggered: {
                newProjectMeta()
            }
        }
    ]
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
}
