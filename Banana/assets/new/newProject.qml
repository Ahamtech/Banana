import bb.cascades 1.4
import bb.system 1.2
import bb.device 1.4
import "../moment.js" as Moment

Page {
    onCreationCompleted: {
        newprojecttext.requestFocus()
    }
    titleBar: TitleBar {
        title: qsTr("Add New Project")
    }
    Container {
        layout: DockLayout {

        }
        Container {
            id: loading
            visible: false
            verticalAlignment: VerticalAlignment.Bottom
            horizontalAlignment: HorizontalAlignment.Center
            bottomPadding: ui.du(12)
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            Label {
                text: qsTr("Creating Project")
            }
            ActivityIndicator {
                id: projectloader
                running: true
            }
        }
        Container {
            topPadding: 20
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Top
            TextArea {
                id: newprojecttext
                hintText: qsTr("Enter Project Name")
                input.submitKey: SubmitKey.Next
                input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                maxWidth: ui.du(65)
                autoSize.maxLineCount: 2
            }
            TextArea {
                id: notes
                hintText: qsTr("Enter Description")
                input.submitKey: SubmitKey.Submit
                input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                maxWidth: ui.du(65)
                autoSize.maxLineCount: 6

                input {
                    onSubmitted: {
                        testingchecks()
                    }
                }
            }
        }
    }
    actions: [
        ActionItem {
            id: newaction
            title: qsTr("Save Project")
            imageSource: "asset:///Images/BBicons/ic_done.png"
            ActionBar.placement: ActionBarPlacement.Signature
            onTriggered: {
                testingchecks()
            }
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                    onTriggered: {
                        testingchecks()
                    }
                }
            ]
        }
    ]
    function testingchecks() {
        if (newprojecttext.text.length > 0) {
            newaction.enabled = false
            loading.visible = true
            newproject();
        } else
            emptytitle.show()
    }
    attachedObjects: [
        SystemToast {
            id: emptytitle
            body: qsTr("Enter Project Title") + Retranslate.onLanguageChanged
        },
        SystemToast {
            id: newprojectcreated
            body: qsTr("Project Created") + Retranslate.onLanguageChanged
        },
        SystemToast {
            id: newprojectcreatederror
            body: qsTr("Project Creation Failed") + Retranslate.onLanguageChanged
        },
        Led {
            id: blinkled
            color: LedColor.Yellow
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
    function newproject() {
        var param = {
            "workspace": activeworkspace,
            "name": newprojecttext.text
        }
        if (notes.text.length > 0) {
            param["notes"] = notes.text
        }
        var doc = new XMLHttpRequest();
        var url = endpoint + "projects"
        var params = serialize(param)
        url += "?"
        url += params
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 201) {
                    newprojectcreated.show()
                    blinkled.flash(2)
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
                    navigationpane.pop()
                } else {
                    console.log("STATUS:" + doc.status + " \nHEADERS: " + doc.getAllResponseHeaders() + "\n BODY: " + doc.responseText);
                    newprojectcreatederror.body = qsTr("Error in Project Creation try again....")
                    newprojectcreatederror.show()
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
