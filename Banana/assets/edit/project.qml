import bb.cascades 1.4
import bb.device 1.4
import bb.system 1.2
import "../moment.js" as Moment
Page {
    onCreationCompleted: {
        var data = app.getProject(activeproject)
        var info = data[0]
        projecttitle.text = info.name
        projectdes.text = info.notes
    }
    titleBar: TitleBar {
        title: qsTr("Edit Project")
    }
    ScrollView {

        Container {
            layout: DockLayout {
            }
            Container {
                visible: false
                bottomPadding: ui.du(20)
                verticalAlignment: VerticalAlignment.Bottom
                horizontalAlignment: HorizontalAlignment.Center
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                id: loader
                Label {

                    text: qsTr("Project Edit Process")
                }
                ActivityIndicator {
                    running: true
                }
            }
            Container {
                leftPadding: ui.du(2)
                topPadding: ui.du(2)
                rightPadding: ui.du(2)
                TextArea {
                    id: projecttitle
                    hintText: qsTr("Title")
                    autoSize.maxLineCount: 2

                }
       /*         Container {
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    horizontalAlignment: HorizontalAlignment.Fill
                    Container {
                        horizontalAlignment: HorizontalAlignment.Center
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                        Label {
                            horizontalAlignment: HorizontalAlignment.Right
                            text: qsTr("Due date : ")
                            opacity: 0.7
                        }

                    }
                    Container {
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                        Label {

                            text: "21/12/0123"
                        }
                    }
                }
                Container {
                    topPadding: 5
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    horizontalAlignment: HorizontalAlignment.Fill
                    Container {
                        horizontalAlignment: HorizontalAlignment.Center
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                        Label {
                            horizontalAlignment: HorizontalAlignment.Right
                            text: qsTr("Owner : ")
                            opacity: 0.7
                        }

                    }
                    Container {
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                        Label {
                            text: "founder"
                        }
                    }
                }*/
                TextArea {
                    id: projectdes

                    hintText: qsTr("Description")
                    autoSize.maxLineCount: 6
                }

            }
        }

    }
    actions: [
        ActionItem {
            title: qsTr("save")
            ActionBar.placement: ActionBarPlacement.Signature
            imageSource: "asset:///Images/BBicons/ic_done.png"
            onTriggered: {
                if (projecttitle.text.length > 0) {
                    loader.visible = true
                    refreshProjects()
                }
            }
        }
    ]
    function refreshProjects() {
        var doc = new XMLHttpRequest();
        console.log("token : " + token)
        var url = endpoint + "projects/" + activeproject
        var param = {
            name: projecttitle.text
        }
        if (projectdes.text) {
            param["notes"] = projectdes.text
        }
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    editsuccesstoast.show()
                    ledID.flash(1)
                    loader.visible = false
                    console.log(doc.responseText)
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
                    insert["color"] = info.color
                    app.insertProjects(insert)
                    for (var i = 0; i < info.followers.length; i ++) {
                        app.insertProjectFollowers(info.followers[i].id, info.id)
                    }
                    for (var i = 0; i < info.followers.length; i ++) {
                        app.insertProjectMembers(info.followers[i].id, info.id)
                    }
                } else {
                    editfailuretoast.show()
                    loader.visible = false
                    if (doc.status == 404) {
                        app.deleteProject(activeproject)
                    }
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
    attachedObjects: [
        SystemToast {
            id: editsuccesstoast
            body: qsTr("Saved")

        },
        SystemToast {
            id: editfailuretoast
            body: qsTr("Failed")
        },
        Led {
            id: ledID
            color: LedColor.Yellow
        }
    ]
}
