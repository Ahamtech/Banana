/**
 * 
 */
var insert = function(stuff){
	var input = stuff.data
	var section = false
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
    insert.workid = input["workspace"].id
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
    app.flushProject2Task(input.id)
    if (input.memberships) {
        for (var a = 0; a < input.memberships.length; a ++) {
            var member = input.memberships[a]
            app.insertProject2Task({
                    'projectid': member.project.id,
                    "taskid": input.id
            })
        if (member.section) {
            if (member.section.name == input.name) {
                section = true
            
            } else {
                app.insertSectionMeta(member.section.id, member.section.name, input.id, member.project.id)
            }
        }
        }
    }
    app.flushTags(input.id)
    if (input.tags) {
        for (var a = 0; a < input.tags.length; a ++) {
            app.insertTag(input.tags[a].id, input.tags[a].name, input.id,input.workspace.id)
        }
    }
    if (section == false) {
        app.deleteTaskItem(insert.id);
        app.insertTask(insert);
    } else {
        console.log(input.name)
    }
}