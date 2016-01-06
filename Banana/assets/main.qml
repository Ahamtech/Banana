import bb.cascades 1.3
import "moment.js" as Moment
import "ajaxmee.js" as Ajaxmee
import "inserttask.js" as Insert
import bb.system 1.2

TabbedPane {
    property int refreshfinished: 0
    signal refresh
    function isPhotoAvailable(userid) {
        return app.isPhotoAvailable(userid)
    }
    onRefresh: {
        if (tabbedPane.activeTab.title == "Banana") {
            refreshWorkspaces()
        } else {
            refreshProjects()
        }
    }
    onRefreshfinishedChanged: {
        refreshicon.enabled = true
        tabbedPane.activeTab.enabled = true
        rotateanimate1.stop()
        datacontainer.enabled = true
        datacontainer.opacity = 1
        loadingcontainer.visible = false
    }

    attachedObjects: [
        ComponentDefinition {
            id: mytaskspage

            source: "asset:///myTasks.qml"
        },
        Screenshot {
            id: screenshot
        },
        ComponentDefinition {
            id: settings
            source: "asset:///settings/mainSettings.qml"
        },
        Sheet {
            id: mainSheet
            onOpened: {
                app.getEmails();
            }
            Page {
                titleBar: TitleBar {
                    title: "Main Sheet"
                    acceptAction: ActionItem {
                        title: "save"
                    }
                    dismissAction: ActionItem {
                        title: "Close"
                        onTriggered: {
                            mainSheet.close()
                        }
                    }
                }
                Container {
                    layout: StackLayout {

                    }
                    DropDown {
                        id: drop1
                    }
                    DropDown {
                        id: drop2
                    }
                    TextArea {
                        id: txtarea
                    }
                }
            }
        }

    ]
    property variant token
    property variant activeworkspace
    property variant activeproject
    property variant endpoint: "https://app.asana.com/api/1.0/"
    property variant c_language: app.getCurrentLanguage()
    property variant username
    showTabsOnActionBar: false
    sidebarState: SidebarState.VisibleFull
    id: tabbedPane
    onCreationCompleted: {
        Qt.app = app
        var info = app.getSettings("themecolor")
        console.log(JSON.stringify(info))
        if (info[0]) {
            Application.themeSupport.setVisualStyle(info[0]["value"])
            var clr1 = app.getSettings("color1")
            var clr2 = app.getSettings("color2")
            console.log(JSON.stringify(clr1, clr2))
            Application.themeSupport.setPrimaryColor(Color.create(clr1[0]["value"]), Color.create(clr2[0]["value"]))
        }
        Qt.c_language = c_language
        var temptoken = app.getToken()
        token = app.covertToBase64(temptoken)
        initworkspace()
        titlebarmain.text = (app.getValueByType("name"))[0].value
        tabbedPane.activeTabChanged.connect(active)
        app.projectupdated.connect(qemittest)
        app.projectDeleted.connect(qemittest)
        app.taskViewUpdate.connect(qemittest)
        Application.resetCover()
        Application.setCover(maincover)
        refreshicon.enabled = false
        rotateanimate1.play()
        refresh()
    }
    Menu.definition: [
        MenuDefinition {
            actions: [
                ActionItem {
                    title: qsTr("About Us")
                    imageSource: "asset:///Images/BBicons/ic_info.png"
                    onTriggered: {
                        navigationpane.push(team_info.createObject())
                    }
                },
                ActionItem {
                    title: qsTr("Settings")
                    imageSource: "asset:///Images/BBicons/ic_settings.png"
                    onTriggered: {
                        navigationpane.push(settings.createObject())
                    }
                },
                ActionItem {
                    title: qsTr("Review")
                    imageSource: "asset:///Images/BBicons/ic_compose.png"
                    attachedObjects: [
                        Invocation {
                            id: invoke
                            query: InvokeQuery {
                                invokeTargetId: "sys.appworld"
                                uri: "appworld://content/59950357"
                            }
                        }
                    ]
                    onTriggered: {
                        invoke.trigger("bb.action.OPEN")
                    }
                },
                ActionItem {
                    title: qsTr("Help")
                    imageSource: "asset:///Images/BBicons/ic_help.png"
                    onTriggered: {
                        help.trigger("bb.action.OPEN")
                    }
                    attachedObjects: [
                        Invocation {
                            id: help
                            query: InvokeQuery {
                                invokeTargetId: "sys.browser"
                                uri: "https://ahamtech.in/banana/help"
                            }
                        }
                    ]
                }
            ]
        }
    ]
    function initworkspace() {
        var itemd = app.getWorkSpacesList()
        for (var i = 0; i < itemd.length; i ++) {
            var c = "import bb.cascades 1.3; Tab{}";
            var tab = Qt.createQmlObject(c, tabbedPane);
            tab.title = itemd[i].name
            tab.imageSource = "asset:///Images/BBicons/ic_view_list.png"
            console.log(itemd[i].id + " : " + itemd[i].name)
            var projects = app.getProjectsCountInWorkSpace(itemd[i].id)
            tab.description = projects + qsTr(" projects")
            tabbedPane.add(tab);
        }
    }
    function refreshWorkspaces() {
        tabbedPane.activeTab = tabbedPane.at(0)
        deleteTabs()
        lastupdate()
        getUsers()
        workspacesync()
    }
    function deleteTabs() {
        var tabcount = tabbedPane.count()
        for (var i = 0; i < tabcount - 1; i ++) {
            var tab = tabbedPane.at(1)
            if (tab.title != "Banana") {
                tabbedPane.remove(tab)
            }
        }
    }
    function qemittest() {
        active()
        projectslistviwerefresh()
    }
    function active() {
        if (tabbedPane.activeTab.title == "Banana") {
            banana.visible = true
            activework.visible = false
            titlebarmain.text = (app.getValueByType("name"))[0].value
            addingnewprojectaction.enabled = false
            addingmytaskstab.enabled = false
            mytaskmainview.dataModel.clear()
            mytaskmainview.dataModel.append(app.getTodaysTasks(Moment.moment().format("YYYY-MM-DD"), "me", (app.getValueByType("id"))[0].value))
            if (mytaskmainview.dataModel.size() > 0) {
                mytaskmainview.visible = true
            } else {
                no_text_id.text = qsTr("Grab A Banana - No tasks for today :)")
                mytaskmainview.visible = false
            }
            mytaskmainview.dataModel.clear()
            mytaskmainview.dataModel.append(app.getTodaysTasks(Moment.moment().format("YYYY-MM-DD"), "all", ""))
            if (! mytaskmainview.dataModel.size() > 0) {
                mytaskmainview.visible = false
                no_text_id.text = qsTr("Bananas for Everyone - No tasks for today ;)")
            } else {
                mytaskmainview.visible = true
            }

        } else {
            activeworkspace = app.getWorkSpaceId(tabbedPane.activeTab.title)
            banana.visible = false
            activework.visible = true
            console.log(tabbedPane.activeTab.title)
            titlebarmain.text = tabbedPane.activeTab.title
            addingnewprojectaction.enabled = true
            addingmytaskstab.enabled = true
            tabbedPane.activeTab.description = app.getProjectsCountInWorkSpace(activeworkspace) + qsTr(" Projects")

        }
        activetaskmainview.dataModel.clear()
        activetaskmainview.dataModel.append(app.getTodaysTasks(Moment.moment().format("YYYY-MM-DD"), "all", ""))
    }
    function projectslistviwerefresh() {
        projectslist.dataModel.clear()
        projectslist.dataModel.append(app.getProjectsById(activeworkspace))
        if (projectslist.dataModel.size() > 0) {
            projectslist.visible = true
            list_empty.visible = false
        } else {
            projectslist.visible = false
            list_empty.visible = true
        }
    }
    onActiveworkspaceChanged: {
        projectslistviwerefresh()
    }
    Tab {
        title: qsTr("Banana") + Retranslate.onLocaleOrLanguageChanged
        imageSource: "asset:///icon.png"
    }
    activePane: NavigationPane {
        id: navigationpane
        Page {
            onPeekedAtChanged: {
                projectslist.secretPeek = peekedAt
            }
            attachedObjects: [
                ComponentDefinition {
                    id: team_info
                    source: "asset:///settings/aboutus.qml"
                },
                Tab {
                    id: tabb
                },
                MultiCover {
                    id: maincover

                    ApplicationViewCover {
                        id: appViewCover
                        // Use this cover when a small cover is required
                        MultiCover.level: CoverDetailLevel.Medium
                    }
                    SceneCover {
                        MultiCover.level: CoverDetailLevel.High

                        content: Container {
                            verticalAlignment: VerticalAlignment.Fill
                            horizontalAlignment: HorizontalAlignment.Fill
                            ListView {
                                id: activetaskmainview
                                dataModel: ArrayDataModel {
                                }
                                onVisibleChanged: {
                                    list_data_visibility.visible = ! visible
                                }
                                listItemComponents: [
                                    ListItemComponent {
                                        type: ""
                                        Screencover {
                                            projectname: ListItemData.name
                                            assigneename: (Qt.app.getUserByID(ListItemData.assignee))[0].name
//                                            workspacename: (Qt.app.getWorkSpace(ListItemData.workid))[0].name
                                        }
                                    }
                                ]
                            }
                        }
                    }
                },
                ComponentDefinition {
                    id: projectviewpage
                    source: "asset:///views/projectView.qml"
                },
                ComponentDefinition {
                    id: addprojectpage
                    source: "asset:///new/newProject.qml"
                }
            ]
            titleBar: TitleBar {

                kind: TitleBarKind.FreeForm
                kindProperties: FreeFormTitleBarKindProperties {
                    Container {
                        layout: DockLayout {

                        }
                        Container {

                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 1
                            }
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight

                            }
                            verticalAlignment: VerticalAlignment.Fill
                            leftPadding: 10
                            topPadding: 7
                            bottomPadding: 10
                            Container {

                                verticalAlignment: VerticalAlignment.Center
                                gestureHandlers: TapHandler {
                                    onTapped: {
                                        mysheet.open()
                                    }
                                }
                                maxHeight: 70
                                maxWidth: 70
                                layout: AbsoluteLayout {

                                }
                                ImageView {
                                    maxHeight: 68
                                    maxWidth: 68
                                    imageSource: isPhotoAvailable(app.getValueByType("id")[0].value) ? (filepathname.data + "/ahammedia/" + app.getValueByType("id")[0].value + ".png") : ("asset:///Images/BBicons/ic_contact.png")

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
                                    id: titlebarmain
                                }
                            }
                        }

                        Container {
                            horizontalAlignment: HorizontalAlignment.Right
                            verticalAlignment: VerticalAlignment.Center
                            animations: [
                                RotateTransition {

                                    id: rotateanimate1
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
                                id: refreshicon

                                verticalAlignment: VerticalAlignment.Center

                                maxHeight: 70
                                maxWidth: 70
                                horizontalAlignment: HorizontalAlignment.Right
                                imageSource: "asset:///Images/BBicons/ic_reload.png"

                                gestureHandlers: [
                                    TapHandler {
                                        onTapped: {
                                            if (! rotateanimate1.isPlaying()) {
                                                loadtext.text = "Data under Synch"
                                                refreshicon.enabled = false
                                                rotateanimate1.play()
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
                Container {
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    layout: AbsoluteLayout {

                    }
                    visible: false
                    id: loadingcontainer
                    Label {
                        id: loadtext
                        text: "Data is under Synch"
                    }
                }
                Container {
                    id: datacontainer
                    Container {
                        visible: true
                        id: banana
                        horizontalAlignment: HorizontalAlignment.Fill
                        topPadding: ui.du(2.0)
                        Container {
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }

                            topPadding: 0
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Fill
                            Container {
                                horizontalAlignment: HorizontalAlignment.Fill
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 3.3
                                }
                                topPadding: 0
                                Container {
                                    horizontalAlignment: HorizontalAlignment.Center
                                    Label {
                                        topPadding: 0
                                        text: app.getTableSize("workspace")
                                        textStyle.color: ui.palette.primary
                                        horizontalAlignment: HorizontalAlignment.Center
                                        textStyle.textAlign: TextAlign.Center
                                        textStyle.fontSize: FontSize.PointValue
                                        textStyle.fontSizeValue: 10
                                    }
                                }
                                Container {
                                    horizontalAlignment: HorizontalAlignment.Center
                                    Label {
                                        topPadding: 0
                                        text: qsTr("Workspaces")
                                        horizontalAlignment: HorizontalAlignment.Center
                                        textStyle.textAlign: TextAlign.Center
                                    }
                                }
                            }

                            Container {
                                horizontalAlignment: HorizontalAlignment.Fill
                                layout: StackLayout {

                                }
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 3.3
                                }
                                topPadding: 0
                                Container {
                                    horizontalAlignment: HorizontalAlignment.Center
                                    Label {
                                        topPadding: 0
                                        text: app.getTableSize("projects")
                                        textStyle.color: ui.palette.primary
                                        horizontalAlignment: HorizontalAlignment.Center
                                        textStyle.textAlign: TextAlign.Center
                                        textStyle.fontSize: FontSize.PointValue
                                        textStyle.fontSizeValue: 10
                                    }
                                }
                                Container {
                                    horizontalAlignment: HorizontalAlignment.Center
                                    Label {
                                        topPadding: 0
                                        text: qsTr("Projects")
                                        horizontalAlignment: HorizontalAlignment.Center
                                        textStyle.textAlign: TextAlign.Center
                                    }
                                }
                            }
                            Container {
                                horizontalAlignment: HorizontalAlignment.Fill
                                layout: StackLayout {

                                }
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 3.3
                                }
                                topPadding: 0
                                Container {
                                    horizontalAlignment: HorizontalAlignment.Center
                                    Label {
                                        topPadding: 0
                                        text: app.getMyTasksCount((app.getValueByType("id"))[0].value)
                                        textStyle.color: ui.palette.primary
                                        horizontalAlignment: HorizontalAlignment.Center
                                        textStyle.textAlign: TextAlign.Center
                                        textStyle.fontSize: FontSize.PointValue
                                        textStyle.fontSizeValue: 10
                                    }
                                }
                                Container {
                                    horizontalAlignment: HorizontalAlignment.Center
                                    Label {
                                        topPadding: 0
                                        text: qsTr("Tasks")
                                        horizontalAlignment: HorizontalAlignment.Center
                                        textStyle.textAlign: TextAlign.Center
                                    }
                                }
                            }
                        }
                        Label {
                            opacity: 0.7
                            text: qsTr("Today's Tasks")
                            horizontalAlignment: HorizontalAlignment.Center
                            textStyle.fontSize: FontSize.PointValue
                            textStyle.fontSizeValue: 10

                        }
                        SegmentedControl {
                            Option {
                                text: qsTr("My Tasks") + Retranslate.onLanguageChanged
                                value: "me"
                            }
                            Option {
                                text: qsTr("Everybody's Tasks") + Retranslate.onLanguageChanged
                                value: "all"
                            }
                            onSelectedOptionChanged: {
                                switch (selectedValue) {
                                    case "me":
                                        {
                                            mytaskmainview.dataModel.clear()
                                            mytaskmainview.dataModel.append(app.getTodaysTasks(Moment.moment().format("YYYY-MM-DD"), "me", (app.getValueByType("id"))[0].value))
                                            if (mytaskmainview.dataModel.size() > 0) {
                                                mytaskmainview.visible = true
                                            } else {
                                                no_text_id.text = qsTr("Grab A Banana - No tasks for today :)")

                                                mytaskmainview.visible = false
                                                no_image_id.imageSource = "asset:///Images/singlebananna.png"
                                            }
                                            break
                                        }
                                    case "all":
                                        {

                                            mytaskmainview.dataModel.clear()
                                            mytaskmainview.dataModel.append(app.getTodaysTasks(Moment.moment().format("YYYY-MM-DD"), "all", ""))
                                            if (! mytaskmainview.dataModel.size() > 0) {
                                                mytaskmainview.visible = false
                                                no_image_id.imageSource = "asset:///Images/bunchbanana.png"
                                                no_text_id.text = qsTr("Bananas for Everyone - No tasks for today ;)")
                                            } else {
                                                mytaskmainview.visible = true
                                            }

                                        }
                                }
                                }
                        }
                        ListView {
                            id: mytaskmainview
                            dataModel: ArrayDataModel {
                                onItemAdded: {
                                    mytaskmainview.visible = true
                                }
                            }
                            onVisibleChanged: {
                                list_data_visibility.visible = ! visible
                            }
                            listItemComponents: [
                                ListItemComponent {
                                    type: ""
                                    CustomStandardMytasks {
                                        projectname: ListItemData.name
                                        assigneename: (Qt.app.getUserByID(ListItemData.assignee))[0].name
                                        workspacename: (Qt.app.getWorkSpace(ListItemData.workid))[0].name
                                        //                                        onCreationCompleted: {
                                        //                                            var projectslista = Qt.app.getTagsProjectList(ListItemData.id)
                                        //                                            var projectslistaa = Qt.app.getTagsProjectList(ListItemData.id)
                                        //                                            var projectslist_text = "<html>"
                                        //                                            if (projectslista.length > 0) {
                                        //                                                console.log("projects length is greater than 0")
                                        //                                                for (var i = 0; i < projectslistaa.length; i ++) {
                                        //                                                    var themecolor = ui.palette.primary
                                        //                                                    projectslist_text += "<span>" + projectslista[i].projectname + "</span><span style='color:" + Color.toHexString(themecolor) + "'>|</span>"
                                        //                                                }
                                        //                                            }
                                        //                                            projectslist_text += "</html>"
                                        //                                            console.log("this is nothing " + projectslist_text)
                                        //                                            projects = projectslist_text
                                        //                                        }
                                    }
                                }
                            ]
                            onCreationCompleted: {
                                mytaskmainview.dataModel.clear()
                                mytaskmainview.dataModel.append(app.getTodaysTasks(Moment.moment().format("YYYY-MM-DD"), "me", (app.getValueByType("id"))[0].value))
                                if (dataModel.size() < 1) {
                                    visible = false
                                }
                            }
                        }
                        Container {
                            id: list_data_visibility
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Center
                            visible: (! mytaskmainview.visible)
                            layout: StackLayout {

                            }
                            Container {
                                horizontalAlignment: HorizontalAlignment.Center
                                ImageView {
                                    id: no_image_id
                                    imageSource: "asset:///Images/singlebananna.png"
                                }
                            }
                            Container {
                                Label {
                                    id: no_text_id
                                    text: qsTr("Grab A Banana - No tasks for today :)")
                                    textStyle.color: ui.palette.primary
                                    opacity: .5
                                    textStyle.fontSize: FontSize.PointValue
                                    textStyle.fontSizeValue: 8

                                }
                            }
                        }
                    }
                    Container {
                        id: activework
                        visible: false

                        ListView {
                            onVisibleChanged: {
                                if (visible) {
                                    list_empty.visible = false
                                } else {
                                    list_empty.visible = true
                                }
                            }

                            id: projectslist
                            property bool secretPeek: false
                            onCreationCompleted: {
                                if (projectslist.dataModel.size() > 0) {
                                    projectslist.visible = false
                                    list_empty = true
                                } else {
                                    projectslist.visible = true
                                    list_empty = false
                                }
                            }
                            dataModel: ArrayDataModel {
                                onItemAdded: {
                                    if (projectslist.dataModel.size() > 0) {
                                        projectslist.visible = false
                                        list_empty = true
                                    } else {
                                        projectslist.visible = true
                                        list_empty = false
                                    }
                                }
                            }
                            onTriggered: {
                                activeproject = projectslist.dataModel.value(indexPath).id
                                navigationpane.push(projectviewpage.createObject())
                            }
                            function lang() {
                                return app.getCurrentLanguage()
                            }
                            listItemComponents: [
                                ListItemComponent {
                                    type: ""
                                    CustomListProject {
                                        color: ListItemData.color ? Color.create("#" + ListItemData.color) : Color.Black
                                        projectname: ListItemData.name
                                        updated: Moment.moment.unix(ListItemData.modified).locale(Qt.c_language).calendar()
                                    }
                                }
                            ]
                        }
                        Container {
                            id: list_empty
                            visible: false

                            Container {
                                TextArea {
                                    backgroundVisible: false
                                    textStyle.textAlign: TextAlign.Center
                                    horizontalAlignment: HorizontalAlignment.Center
                                    verticalAlignment: VerticalAlignment.Center
                                    text: qsTr("No Projects Available")
                                    textStyle.color: ui.palette.primary
                                    opacity: .5
                                    textStyle.fontSize: FontSize.PointValue
                                    textStyle.fontSizeValue: 10

                                }
                            }
                        }
                    }

                }
            }
            actions: [
                ActionItem {
                    title: qsTr("My Tasks")
                    enabled: false
                    id: addingmytaskstab
                    ActionBar.placement: ActionBarPlacement.OnBar
                    imageSource: "asset:///Images/BBicons/ic_view_details_dk.png"
                    onTriggered: {
                        navigationpane.push(mytaskspage.createObject())
                    }
                    shortcuts: [
                        SystemShortcut {
                            type: SystemShortcuts.NextSection
                            onTriggered: {
                                navigationpane.push(mytaskspage.createObject())
                            }
                        }
                    ]
                },
                ActionItem {
                    id: addingnewprojectaction
                    enabled: false
                    title: qsTr("Add Project")
                    ActionBar.placement: ActionBarPlacement.Signature
                    imageSource: "asset:///Images/BBicons/ic_add.png"
                    onTriggered: {
                        navigationpane.push(addprojectpage.createObject())
                    }
                    shortcuts: [
                        SystemShortcut {
                            type: SystemShortcuts.CreateNew
                            onTriggered: {
                                navigationpane.push(addprojectpage.createObject())
                            }
                        }
                    ]
                }
            ]
            actionBarVisibility: ChromeVisibility.Visible
            actionBarAutoHideBehavior: ActionBarAutoHideBehavior.Disabled
        }
    }

    function refreshProjects() {
        var doc = new XMLHttpRequest();
        var url = endpoint + "workspaces/" + activeworkspace + "/projects"
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var data = JSON.parse(doc.responseText)
                    for (var i = 0; i < projectslist.dataModel.size(); i ++) {
                        app.flushProject(projectslist.dataModel.value(i).id)
                    }
                    for (var i = 0; i < data.data.length; i ++) {
                        newProjectMeta(data.data[i].id)
                        if (i == data.data.length - 1) {
                            rotateanimate1.stop()
                            refreshicon.imageSource = "asset:///Images/BBicons/ic_reload.png"
                            projectslistviwerefresh()
                        }
                    }
                    refreshfinished ++;
                } else {
                    loadtext.text = "Synch Failed"
                    refreshfinished ++
                    console.log("STATUS:" + doc.status + " \nHEADERS: " + doc.getAllResponseHeaders() + "\n BODY: " + doc.responseText);
                }
            }
        }
        doc.open("get", url);
        doc.setRequestHeader("Authorization", "Basic " + token);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send();
    }
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
    function newProjectMeta(id) {
        var doc = new XMLHttpRequest();
        var url = endpoint + "projects/" + id
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
                    console.log(JSON.stringify(insert))
                    for (var i = 0; i < info.followers.length; i ++) {
                        app.insertProjectFollowers(info.followers[i].id, info.id)
                    }
                    for (var i = 0; i < info.followers.length; i ++) {

                        app.insertProjectMembers(info.followers[i].id, info.id)
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
    function workspacesync() {
        var doc = new XMLHttpRequest();
        var url = endpoint + "workspaces"
        //lambda
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var data = JSON.parse(doc.responseText)
                    app.cleanWorkspace()
                    for (var i = 0; i < data.data.length; i ++) {
                        var workspace = data.data[i];
                        app.insertWorkspace(workspace.id, workspace.name)
                        if (i == data.data.length - 1) {
                            rotateanimate1.stop()
                            refreshicon.imageSource = "asset:///Images/BBicons/ic_reload.png"
                            initworkspace()
                        }
                    }
                    refreshfinished ++;
                    console.log(refreshfinished + "refreshing the valuee")
                } else {
                    refreshfinished ++
                    loadtext.text = "Failed Synch"
                    console.log("STATUS:" + doc.status + " \nHEADERS: " + doc.getAllResponseHeaders() + "\n BODY: " + doc.responseText);
                }

            }
        }
        doc.open("get", url);
        doc.setRequestHeader("Authorization", "Basic " + token);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send();
    }
    function lastupdate() {
        var allproj = app.getAllProjects()
        for (var i = 0; i < allproj.length; i ++) {
            getsynckey(allproj[i].id)
            if (allproj.length - 1 == i) {
                grabtaskmeta()
            }
        }
    }
    function getsynckey(projid) {
        var doc = new XMLHttpRequest();
        var into = app.getProject(projid)
        var syncid = into[0].lastupdate
        var url = endpoint + "events?resource=" + projid + "&sync=" + syncid
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
                    app.projectLastUpdate(projid, data.sync)
                }
            }
            if (doc.readyState === 3) {
                if (doc.status === 412) {
                    var input = JSON.parse(doc.responseText)
                    app.projectLastUpdate(projid, input.sync)
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
            taskmeta(temproj)
        } else {
            console.log("Refresh Finished rendering iINt")
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
    function getUsers() {
        var doc = new XMLHttpRequest();
        var url = endpoint + "users?opt_fields=name,email,photo,workspaces"
        //lambda
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var data = JSON.parse(doc.responseText).data
                    app.dropTable("user2workspace")
                    var me = (app.getValueByType("id"))[0].value

                    for (var i = 0; i < data.length; i ++) {
                        var info = data[i]
                        app.insertUsers(info.id, info.name, info.email)
                        if (info.photo) {
                            app.getImage(info.photo["image_128x128"], info.id + ".png")
                        }
                        for (var j = 0; j < info.workspaces.length; j ++) {
                            app.insertUsers2Work(info.id, info.workspaces[j].id)
                        }
                        if (me == info.id) {
                            console.log("kok " + JSON.stringify(me))
                            app.insertSettings("name", info.name)
                            app.insertSettings("email", info.email)
                        }
                    }
                } else {
                    console.log(url)
                    console.log("STATUS:" + doc.status + " \nHEADERS: " + doc.getAllResponseHeaders() + "\n BODY: " + doc.responseText);
                }
            }
        }
        doc.open("get", url);
        doc.setRequestHeader("Authorization", "Basic " + token);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send();
    }
    shortcuts: [
        Shortcut {
            key: "q"
            onTriggered: {
                console.log("q triggered")
                screenshot.captureDisplay()
            }
        }
    ]

}
