import bb.cascades 1.3
import bb.system 1.2
import "../moment.js" as Moment
Page {
    property variant assignvar
    titleBar: TitleBar {
        title: qsTr("Add New Task")
    
    }
    onCreationCompleted: {
        getWorkspaces()
    }
    function projectsByWorkspace(id){
        var projectdata=[]
        projectdata= app.getProjectsById(id);
        for(var i=0;i<projectdata.length ;i++){
            var p_option = optiondef.createObject();
            p_option.text=projectdata[i].name
            p_option.value=projectdata[i].id
            project_options.add(p_option) 
        }
    }
    function getWorkspaces(){
        var workspacedata=[]
        workspacedata= app.getWorkSpacesList();
        for(var i=0;i<workspacedata.length ;i++){
            var w_option = optiondef.createObject();
            w_option.text=workspacedata[i].name
            w_option.value=workspacedata[i].id
            workspace_options.add(w_option) 
        
        }
    
    }
    function searchupdate() {
        
        userslist.dataModel.clear()
        userslist.dataModel.append(app.getUsersBySearch(usersearch.text))
    }
    function getAllProjects(){
        
        var projectdata=[]
        projectdata= app.getProjectsById(activeworkspace)
        for(var i=0;i<projectdata.length ;i++){
            
            var p_option = optiondef.createObject();
            p_option.text=projectdata[i].name
            p_option.value=projectdata[i].id
            project_options.add(p_option) 
            if(activeproject){
                if(activeproject==projectdata[i].id){
                    project_options.selectedOption =p_option
                }
            }
        }
    }
    attachedObjects: [
        SystemToast {
            id: toast
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
                    title: "Add Due Date"
                    dismissAction: ActionItem {
                        title: "Cancel"
                        onTriggered: {
                            duedate.close()
                        }
                    }
                    acceptAction: ActionItem {
                        title: "Save"
                        //enabled: false
                        onTriggered: {
                            task_duedate.text = task_datepicker.value.getFullYear() + "-" + ( task_datepicker.value.getMonth()+ 1) + "-" + task_datepicker.value.getDate()
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
                //                        userslist.dataModel.clear()
                //                        userslist.dataModel.append(app.getAllUsers)
            }
            Page {
                onCreationCompleted: {
                
                }
                titleBar: TitleBar {
                    id: titlebaar
                    visibility: ChromeVisibility.Visible
                    title: "Assign Task"
                    dismissAction: ActionItem {
                        title: "Cancel"
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
                        onCreationCompleted: {
                            dataModel.clear()
                            dataModel.append(app.getAllUsers())
                        }
                        onTriggered: {
                            clearSelection()
                            select(indexPath)
                            var data = dataModel.data(indexPath);
                            task_assigner.text = data.name
                            assignvar=data.id
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
            topPadding: 10
            rightPadding: 10
            leftPadding: 10
            horizontalAlignment: HorizontalAlignment.Center
            DropDown {
                id: workspace_options
                title: qsTr("Select workspace")
                onSelectedOptionChanged: {
                  projectsByWorkspace(selectedValue)
                }
            
            }
            DropDown {
                id: project_options
                title: qsTr("Select Project")
            
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
                id: tasktitlelabel
                text: "Add Title"
                verticalAlignment: VerticalAlignment.Center
            }
            TextArea {
                id: tasktitle
                backgroundVisible: false
                hintText: qsTr("Task Title")
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
                text: "Title Description"
                verticalAlignment: VerticalAlignment.Center
            }
            TextArea {
                id: taskdesc
                textStyle.textAlign: TextAlign.Right
                
                backgroundVisible: false
                hintText: qsTr("Task Descriptions")
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
                        task_assigner_label.text = "Assign To"
                    }
                }
                textStyle.fontSize: FontSize.Medium
                textStyle.textAlign: TextAlign.Right
                verticalAlignment: VerticalAlignment.Center
                text: "Assign To"
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
                imageSource: "asset:///Images/BBicons/ic_cancel.png"
                onClicked: {
                    task_assigner.text = ""
                    assignvar = ""
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
                text: "Due Date"
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
                imageSource: "asset:///Images/BBicons/ic_cancel.png"
                onClicked: {
                    task_duedate.text = ""
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
                if(tasktitle.text.length>0){
                    createNewTask()         
                }
                else 
                {
                    toast.body="please enter the task title"
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
    function createNewTask(){
        
        var param = {"workspace": activeworkspace,"projects":activeproject,"name": tasktitle.text }
        if (taskdesc.text.length > 0) {
            param.notes = taskdesc.text
        }
        if(task_duedate.text.length>0){
            param.due_on = task_datepicker.value.toISOString()
        }
        if(task_assigner.text.length>0){
            param.assignee= assignvar
        }
        var doc = new XMLHttpRequest();
        var url = endpoint + "tasks"
        var params = serialize(param)
        url += "?"
        url += params
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 201) {
                    //                    newprojectcreated.show()
                    //                    blinkled.flash(2)
                    var input = JSON.parse(doc.responseText).data
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
                                    "taskid": input.id
                            })
                        if (member.section) {
                            app.insertSectionMeta(member.section.id, member.section.name, input.id, member.project.id)
                        }
                        }
                    }
                    app.flushTags(input.id)
                    if (input.tags) {
                        for (var a = 0; a < input.tags.length; a ++) {
                            app.insertTag(input.tags[a].id, input.tags[a].name, input.id)
                        }
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
        doc.send();
    
    }

}
