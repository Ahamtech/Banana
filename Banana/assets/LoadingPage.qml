
import bb.cascades 1.4
import bb.platform 1.3
import bb.system 1.2
import bb.device 1.4
import "moment.js" as Moment
import "inserttask.js" as Insert
Page {
    
    property variant token
    property variant endpoint: "https://app.asana.com/api/1.0/"
    property int workspacecount: 0
    property int projectcount: 0
    property int taskcount: 0
    property variant workspaces
    property variant projectstemp: []
    property variant temptasksize: 0
    property variant tasksall: 0
    property variant tasksremaining: 0
    property variant count: 0
    property bool isbegin: false
    onCreationCompleted: {
        Application.resetCover()
        Application.setCover(loadingcover)
        var temptoken = app.getToken()
        token = app.covertToBase64(temptoken)
        getworkspace()
        projectstemp = new Array(0)
    }

    onCountChanged: {
        activeframe.text = "Loading tasks " + count + "/" + tasksall
        screencover.update()
        if(count==tasksall){
            notification.notify()
        }
       
    }
    Container {
        Container {
            topPadding: 10
            leftPadding: 20
            rightPadding: 20
            horizontalAlignment: HorizontalAlignment.Left
            verticalAlignment: VerticalAlignment.Center
            bottomPadding: 20
            Label {
                text: qsTr("Login is successful. We are SYNCING the database and it is going to take a while. It happens only once at the time of Login so Please be patient.") + Retranslate.onLanguageChanged
                multiline: true
                horizontalAlignment: HorizontalAlignment.Center
                textStyle.color: Color.Yellow
            }
        }
        Container {
            topPadding: 10
            leftPadding: 20
            rightPadding: 20
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            bottomPadding: 20
            Label {
                text: qsTr("☢DO NOT CLOSE THE APP☢") + Retranslate.onLanguageChanged
                multiline: true
                horizontalAlignment: HorizontalAlignment.Center
                textStyle.color: Color.Red
            }
        }
        Container {
            topPadding: 10
            leftPadding: 20
            rightPadding: 20
            horizontalAlignment: HorizontalAlignment.Left
            verticalAlignment: VerticalAlignment.Center
            bottomPadding: 20
            Label {
                text: qsTr("You do not need to wait for it, you can minimise and carry on with your work. We will notify you once the Syncing is done") + Retranslate.onLanguageChanged
                multiline: true
                horizontalAlignment: HorizontalAlignment.Center
                textStyle.color: Color.Yellow
            }
        }
        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            preferredHeight: 3
            background: Color.Gray
        }

        Container {

            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            id: conload

            layout: GridLayout {
                columnCount: 1

            }

            leftPadding: ui.du(1)
            rightPadding: ui.du(1)

            Container {
                layout: DockLayout {

                }

                Container {
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight

                    }
                    leftPadding: ui.du(1)
                    rightPadding: ui.du(1)
                    topPadding: 10
                    bottomPadding: 10
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Center
                    ActivityIndicator {
                        id: workspaceloader
                        running: true
                        onStopped: {
                            workspacecheck.checked = true
                        }
                    }
                    Container {
                        horizontalAlignment: HorizontalAlignment.Center
                        layout: GridLayout {
                            columnCount: 2

                        }
                        CheckBox {

                            id: workspacecheck
                            text: qsTr("Loading Workspaces")
                            checked: false
                            enabled: false
                        }

                    }

                }
            }
            Container {

                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                leftPadding: ui.du(1)
                rightPadding: ui.du(1)
                topPadding: 10
                bottomPadding: 10
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                ActivityIndicator {
                    id: projectloader
                    running: true
                    onStopped: {
                        procheck.checked = true
                    }
                }
                Container {
                    horizontalAlignment: HorizontalAlignment.Center
                    layout: GridLayout {
                        columnCount: 2

                    }
                    CheckBox {

                        id: procheck
                        text: qsTr("Loading Projects")
                        checked: false
                        enabled: false

                    }

                }
            }
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                leftPadding: ui.du(1)
                rightPadding: ui.du(1)
                topPadding: 10
                bottomPadding: 10

                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                ActivityIndicator {
                    id: usersloader
                    running: true
                    onStopped: {
                        usercheck.checked = true
                    }
                }
                Container {
                    horizontalAlignment: HorizontalAlignment.Center
                    layout: GridLayout {
                        columnCount: 2

                    }
                    CheckBox {

                        id: usercheck
                        text: qsTr("Loading Users")
                        checked: false
                        enabled: false

                    }

                }
            }
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                leftPadding: ui.du(1)
                rightPadding: ui.du(1)
                topPadding: 10
                bottomPadding: 10

                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                ActivityIndicator {
                    id: tasksloader
                    running: true
                    onStopped: {
                        taskscheck.checked = true
                    }
                }
                Container {
                    layout: GridLayout {
                        columnCount: 4

                    }

                    CheckBox {
                        text: isbegin ? qsTr("Loading Tasks ") + count + "/" + tasksall : qsTr("Loading Tasks ")
                        id: taskscheck
                        checked: false
                        enabled: false

                    }

                }
            }

        }
    }
    attachedObjects: [
        MultiCover {
            id: loadingcover

            ApplicationViewCover {
                // Use this cover when a small cover is required
                MultiCover.level: CoverDetailLevel.Medium
            }
            SceneCover {
                id: screencover
                MultiCover.level: CoverDetailLevel.High
                content: Container {
                    background: Color.Black
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Center
                    Label {
                        text: qsTr("☢DO NOT CLOSE THE APP☢") + Retranslate.onLanguageChanged
                        multiline: true
                        horizontalAlignment: HorizontalAlignment.Center
                        textStyle.color: Color.Red
                    }
                    Label {

                        id: activeframe
                        text: qsTr("Loading tasks ") + count + "/" + tasksall
                        multiline: true
                        textStyle.color: Color.Yellow
                    }
                }
                function update() {
                    activeframe.text = qsTr("Loading tasks " )+ count + "/" + tasksall
                }

            }
        }
    ,
    Notification {
        id: notification
        body: " You can view your tasks now"
        title: "Banana Sync Completed"
        
    },
    VibrationController {
        id: vibration
    }
    ]
    function getworkspace() {
        var doc = new XMLHttpRequest();
        var url = endpoint + "workspaces"
        //lambda
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var data = JSON.parse(doc.responseText)
                    workspacecount += data.data.length
                    for (var i = 0; i < data.data.length; i ++) {
                        var workspace = data.data[i];
                        app.insertWorkspace(workspace.id, workspace.name)
                        app.insertTempWorkSpace(workspace.id, true)
                        if (i == data.data.length - 1) {
                            workspaceloader.running = false
                            grabprojects()
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
    function grabprojects() {
        var temproj = app.getTempWorkSpaceId()
        if (temproj) {
            workspace(temproj)
        } else {

            projectsme()
        }
    }
    function workspace(id) {
        var doc = new XMLHttpRequest();
        var url = endpoint + "workspaces/" + id + "/projects"
        //lambda
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var data = JSON.parse(doc.responseText)
                    for (var i = 0; i < data.data.length; i ++) {
                        var project = data.data[i];
                        app.insertTempProject(project.id, true)
                        if (i == data.data.length - 1) {
                            app.insertTempWorkSpace(id, false)
                            grabprojects()
                        }
                    }
                    if (data.data.length == 0) {
                        app.insertTempWorkSpace(id, false)
                        grabprojects()
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

    function projectsme() {
        var temproj = app.getTempProjectId()

        if (temproj) {
            projectsmeta(temproj)
        } else {
            app.projectsToTempProject();
            projectloader.running = false
            //            lastupdate()
            insertUsers()
        }
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
    function projectsmeta(id) {
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
                    for (var i = 0; i < info.followers.length; i ++) {
                        app.insertProjectFollowers(info.followers[i].id, info.id)
                    }
                    for (var i = 0; i < info.followers.length; i ++) {
                        app.insertProjectMembers(info.followers[i].id, info.id)
                    }
                    app.insertTempProject(id, false)
                    projectsme()
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

    function insertUsers() {
        var doc = new XMLHttpRequest();
        var url = endpoint + "users?opt_fields=name,email,photo,workspaces"
        //lambda
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var data = JSON.parse(doc.responseText).data
                    for (var i = 0; i < data.length; i ++) {
                        var info = data[i]
                        app.insertUsers(info.id, info.name, info.email)
                        for (var j = 0; j < info.workspaces.length; j ++) {
                            app.insertUsers2Work(info.id, info.workspaces[j].id)
                        }
                    }
                    grabtasks()
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
    function grabtasks() {
        usersloader.running = false
        var temproj = app.getTempProjectId()

        if (temproj) {
            tasks(temproj)
        } else {
            tasksall = app.getTableSize("temptask");
            isbegin = true
            grabtaskmeta()
        }
    }
    function tasks(id) {
        var doc = new XMLHttpRequest();
        var url = endpoint + "projects/" + id + "/tasks" //lambda
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var data = JSON.parse(doc.responseText)
                    for (var i = 0; i < data.data.length; i ++) {
                        var task = data.data[i];
                        app.insertTempTask(task.id, true)
                        if (i == data.data.length - 1) {
                            app.insertTempProject(id, false)
                            grabtasks()
                        }
                    }
                    if (data.data.length == 0) {
                        app.insertTempProject(id, false)
                        grabtasks()
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
    function grabtaskmeta() {
        var temproj = app.getTempTaskId()
        if (temproj) {
            count ++
            isbegin = true
            taskmeta(temproj)
        } else {
            console.log()
            app.logincomplete()
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
    function lastupdate() {
        var allproj = app.getAllProjects()
        for (var i = 0; i < allproj.length; i ++) {
            getsynckey(allproj[i].id)
        }
    }
    function getsynckey(projid) {
        var doc = new XMLHttpRequest();
        var url = endpoint + "events?resource=" + projid + "&sync="
        doc.onreadystatechange = function() {
            if (doc.readyState === 3) {
                if (doc.status === 412) {
                    var input = JSON.parse(doc.responseText)
                    app.projectLastUpdate(projid, input.sync)

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
}
