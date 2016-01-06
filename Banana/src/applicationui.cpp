/*
 * Copyright (c) 2013-2014 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "applicationui.hpp"
#include "applicationuibase.hpp"
#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/pim/contacts/Contact>
#include <bb/pim/contacts/ContactAttribute>
#include <bb/pim/account/Account>
#include <bb/pim/account/AccountService>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>
#include <bb/system/InvokeManager>
#include <bb/system/CardDoneMessage>
#include <bb/cascades/SceneCover>
#include <bb/cascades/AbstractCover>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlRecord>
#include <QtSql/QSqlError>
#include "DownloadManager.hpp"
#include <QPair>
using namespace bb::cascades;
using namespace bb::system;

ApplicationUI::ApplicationUI(InvokeManager *invokeManager) :
        ApplicationUIBase(invokeManager), m_translator(new QTranslator(this)), m_localeHandler(
                new LocaleHandler(this)), m_invokeManager(new InvokeManager(this)), db(
                new Database(this)), DM(new DownloadManager(this))
{
    // prepare the localization
    bool res = connect(m_invokeManager, SIGNAL(childCardDone(const bb::system::CardDoneMessage&)),
            this, SLOT(cardDone(const bb::system::CardDoneMessage&)));
    Q_ASSERT(res);

    // Since the variable is not used in the app, this is added to avoid a
    // compiler warning
    Q_UNUSED(res);
    if (!QObject::connect(m_localeHandler, SIGNAL(systemLanguageChanged()), this,
            SLOT(onSystemLanguageChanged()))) {
        // This is an abnormal situation! Something went wrong!
        // Add own code to recover here
        qWarning() << "Recovering from a failed connect()";
    }
//    connect(m_InvokeManager, SIGNAL(invoked(const bb::system::InvokeRequest&)), this, SLOT(onInvoked(const bb::system::InvokeRequest&)));
    isDatabaseOpen = db->initDatabase();
    // initial load
    onSystemLanguageChanged();
    Init();
    // Create scene document from main.qml asset, the parent is set
    // to ensure the document gets destroyed properly at shut down.

}

void ApplicationUI::onSystemLanguageChanged()
{
    QCoreApplication::instance()->removeTranslator(m_translator);
    // Initiate, load and install the application translation files.
    QString locale_string = QLocale().name();
    QString file_name = QString("Banana_%1").arg(locale_string);
    if (m_translator->load(file_name, "app/native/qm")) {
        QCoreApplication::instance()->installTranslator(m_translator);
    }
}
//void ApplicationUI::onInvoked(const bb::system::InvokeRequest& request) {
//
//
//}
QString ApplicationUI::getCurrentLanguage()
{

//   return QLocale().languageToString(QLocale().language());
    return QLocale().name();

}
void ApplicationUI::Init()
{
    int count = db->getTableSizeByQuery(
            "select count(*) from settings where type = \"token\" or type = \"name\"");
    if (count > 0) {
        mainView();
    } else {
        Login();
    }
}

void ApplicationUI::Login()
{
    QmlDocument *qml = QmlDocument::create("asset:///login.qml").parent(this);

    // Make app available to the qml.
    qml->setContextProperty("app", this);

    // Create root object for the UI
    AbstractPane *root = qml->createRootObject<AbstractPane>();

    // Set created root object as the application scene
    Application::instance()->setScene(root);
}

void ApplicationUI::mainView()
{
    QmlDocument *qml = QmlDocument::create("asset:///main.qml").parent(this);

    // Make app available to the qml.
    qml->setContextProperty("app", this);
    QDeclarativePropertyMap *filepathname = new QDeclarativePropertyMap(this);
    filepathname->insert("data", QVariant(QString("file://" + QDir::homePath())));
    qml->setContextProperty("filepathname", filepathname);
    // Create root object for the UI
    AbstractPane *root = qml->createRootObject<AbstractPane>();

    // Set created root object as the application scene
    Application::instance()->setScene(root);
}

void ApplicationUI::logincomplete()
{
//    InvokeRequest request;
//    request.setTarget("in.ahamtech.BananaService");
//    request.setAction("in.ahamtech.BananaService.ADD");
//    m_invokeManager->invoke(request);
    mainView();
}

QString ApplicationUI::covertToBase64(QString code)
{
    QByteArray ba;
    ba.append(code);
    ba.append(":");
    return ba.toBase64();

}
void ApplicationUI::insertSettings(QString type, QString value)
{
    QVariantMap map;
    map["type"] = type;
    map["value"] = value;
    int count = db->getTableSizeByQuery(QString("select count(*) from settings where type = \"%1\"").arg(type));
     if(count>0){
         db->insertQuery("update settings set value = :value where type = :type", map);

     }
     else {
         db->insertQuery("insert into settings(type,value)values(:type,:value)", map);

     }
}
void ApplicationUI::insertWorkspace(QString id, QString name)
{
    QVariantMap map;
    map["id"] = id;
    map["name"] = name;
    db->insertQuery("insert into workspace(id,name)values(:id,:name)", map);
}
void ApplicationUI::insertProjects(QVariant var)
{
    QVariantMap map = var.value<QVariantMap>();
    int count = db->getTableSizeByQuery(
            QString("select count(*) from projects where id =\"%1\"").arg(
                    map.value("id").toString()));
    if (count > 0) {
        db->insertQuery(
                "update projects set name = :name ,workspace = :workspace,created=:created,modified=:modified,notes=:notes,archive=:archive,color=:color where id = :id",
                map);
        Q_EMIT projectupdated(map.value("id").toString());
    } else {

        db->insertQuery(
                "insert into projects(id,name,workspace,created,modified,notes,archive,color)values(:id,:name,:workspace,:created,:modified,:notes,:archive,:color)",
                map);
        Q_EMIT projectupdated(map.value("id").toString());
    }
}

void ApplicationUI::scrapData()
{
    db->insertQuery("delete from settings", QVariantMap());
    db->insertQuery("delete from workspace", QVariantMap());
    db->insertQuery("delete from projects", QVariantMap());
    db->insertQuery("delete from users", QVariantMap());
    db->insertQuery("delete from tasks", QVariantMap());
    db->insertQuery("delete from subtasks", QVariantMap());
    db->insertQuery("delete from tasksfollowers", QVariantMap());
    db->insertQuery("delete from membership", QVariantMap());
    db->insertQuery("delete from sectionmeta", QVariantMap());
    db->insertQuery("delete from tagsmeta", QVariantMap());
    db->insertQuery("delete from tags", QVariantMap());
    db->insertQuery("delete from fav", QVariantMap());
    db->insertQuery("delete from tempproject", QVariantMap());
    db->insertQuery("delete from temptask", QVariantMap());
    db->insertQuery("delete from tempworkspace", QVariantMap());
    db->insertQuery("delete from projectmembers", QVariantMap());
    db->insertQuery("delete from projectfollowers", QVariantMap());
    db->insertQuery("delete from project2task", QVariantMap());
}

void ApplicationUI::logout()
{
    scrapData();
//    InvokeRequest request;
//    request.setTarget("in.ahamtech.BananaService");
//    request.setAction("in.ahamtech.BananaService.REMOVE");
//    m_invokeManager->invoke(request);
    Login();
}
void ApplicationUI::insertTask(QVariant data)
{
    QVariantMap map = data.value<QVariantMap>();
    QString query;
    int mode = map.contains("assignee") ? (map.contains("assigneestatus") ? 1 : 3) :
               map.contains("assigneestatus") ? 2 : 4;
    int count = db->getTableSizeByQuery(
            QString("select count(*) from tasks where id = \"%1\"").arg(
                    map.value("id").toString()));
    switch (mode) {
        case 1:
            query =
                    count > 0 ?
                            "update tasks set name=:name,created=:created,modified=:modified,notes=:notes,completed=:completed,completeddate=:completeddate,due=:due,assignee=:assignee,assigneestatus=:assigneestatus,fav=:fav,workid=:workid where id = :id" :
                            "insert into tasks(id,name,created,modified,notes,completed,completeddate,due,assignee,assigneestatus,fav,workid)values(:id,:name,:created,:modified,:notes,:completed,:completeddate,:due,:assignee,:assigneestatus,:fav,:workid)";

            break;
        case 2:
            query =
                    count > 0 ?
                            "update tasks set name=:name,created=:created,modified=:modified,notes=:notes,completed=:completed,completeddate=:completeddate,due=:due,assigneestatus=:assigneestatus,fav=:fav,workid=:workid where id = :id" :
                            "insert into tasks(id,name,created,modified,notes,completed,completeddate,due,assigneestatus,fav,workid)values(:id,:name,:created,:modified,:notes,:completed,:completeddate,:due,:assigneestatus,:fav,:workid)";
            break;
        case 3:
            query =
                    count > 0 ?
                            "update tasks set name=:name,created=:created,modified=:modified,notes=:notes,completed=:completed,completeddate=:completeddate,due=:due,assignee=:assignee,fav=:fav,workid=:workid where id = :id" :
                            "insert into tasks(id,name,created,modified,notes,completed,completeddate,due,assignee,fav,workid)values(:id,:name,:created,:modified,:notes,:completed,:completeddate,:due,:assignee,:fav,:workid)";
            break;
        case 4:
            query =
                    count > 0 ?
                            "update tasks set name=:name,created=:created,modified=:modified,notes=:notes,completed=:completed,completeddate=:completeddate,due=:due,fav=:fav,workid=:workid where id = :id" :
                            "insert into tasks(id,name,created,modified,notes,completed,completeddate,due,fav,workid)values(:id,:name,:created,:modified,:notes,:completed,:completeddate,:due,:fav,:workid)";
            break;
    }
    db->insertQuery(query, map);
}
void ApplicationUI::insertTag(QString tagid, QString tagname, QString taskid, QString workid)
{
    QVariantMap map;
    map.insert("taskid", taskid);
    map.insert("tagid", tagid);
    int count = db->getTableSizeByQuery(
            "select count(*) from tags where tagid=\"" + tagid + "\" and taskid = \"" + taskid
                    + "\"");
    bool insert =
            count > 0 ?
                    false :
                    db->insertQuery(QString("insert into tags(tagid,taskid)values(:tagid,:taskid)"),
                            map);
    Q_UNUSED(insert);
    db->insertQuery(
            QString("insert into tagsmeta(id,name,workid)values(%1,\"%2\",%3)").arg(tagid, tagname,
                    workid), QVariantMap());
}

void ApplicationUI::updateTaskTags(QString tagid, QString taskid, bool status)
{
    status ?
            db->executeQuery(
                    QString("insert into tags(tagid,taskid)values(%1,\"%2\")").arg(tagid, taskid)) :
            db->executeQuery(
                    QString("delete from tags where tagid = \"%1\" and taskid = \"%2\"").arg(tagid,
                            taskid));
}

void ApplicationUI::insertProjectFollowers(QString userid, QString projectid)
{
    QVariantMap map;
    map.insert("userid", userid);
    map.insert("projectid", projectid);
    int count = db->getTableSizeByQuery(
            "select count(*) from projectfollowers where userid=\"" + userid
                    + "\" and projectid = \"" + projectid + "\"");
    bool insert =
            count > 0 ?
                    false :
                    db->insertQuery(
                            QString(
                                    "insert into projectfollowers(projectid,userid)values(:projectid,:userid)"),
                            map);
    Q_UNUSED(insert);
}

void ApplicationUI::insertProjectMembers(QString userid, QString projectid)
{
    QVariantMap map;
    map.insert("userid", userid);
    map.insert("projectid", projectid);
    int count = db->getTableSizeByQuery(
            "select count(*) from projectmembers where userid=\"" + userid + "\" and projectid = \""
                    + projectid + "\"");
    bool insert =
            count > 0 ?
                    false :
                    db->insertQuery(
                            QString(
                                    "insert into projectmembers(projectid,userid)values(:projectid,:userid)"),
                            map);
    Q_UNUSED(insert);

}
void ApplicationUI::insertSectionMeta(QString sectionid, QString name, QString taskid,
        QString projectid)
{
    db->insertQuery(
            QString("insert into sectionmeta(id,name)values(%1,\"%2\")").arg(sectionid, name),
            QVariantMap());
    QVariantMap map;
    map.insert("sectionid", sectionid);
    map.insert("taskid", taskid);
    map.insert("projectid", projectid);
    int count = db->getTableSizeByQuery(
            "select count(*) from membership where sectionid=\"" + sectionid + "\" and taskid=\""
                    + taskid + "\"");
    bool insert =
            count > 0 ?
                    false :
                    db->insertQuery(
                            QString(
                                    "insert into membership(taskid,projectid,sectionid)values(:taskid,:projectid,:sectionid)"),
                            map);
    Q_UNUSED(insert);
}
void ApplicationUI::insertFollowers(QString id, QVariantList list)
{
    foreach(QVariant mapvar,list){
    QVariantMap m_map;
    QVariantMap map = mapvar.value<QVariantMap>();
    m_map.insert("userid",map.value("id").toString());
    m_map.insert("taskid",id);
    int count = db->getTableSizeByQuery("select count(*) from tasksfollowers where taskid=\""+id+"\" and userid =\""+map.value("id").toString()+"\"");
    bool insert = count>0?false:db->insertQuery("insert into tasksfollowers(userid,taskid)values(:userid,:taskid)",m_map);
    Q_UNUSED(insert);
}
}
void ApplicationUI::insertUsers(QString id, QString name, QString email)
{
    QVariantMap map;
    map.insert("id", id);
    map.insert("name", name);
    map.insert("email", email);
    int count = db->getTableSizeByQuery("select count(*) from users where id = \"" + id + "\"");
    bool insert =
            count > 0 ?
                    db->insertQuery("update users set name=:name,email=:email where id = :id",
                            map) :
                    db->insertQuery("insert into users(id,name,email)values(:id,:name,:email)",
                            map);

}
void ApplicationUI::authkeysuccess(QString token)
{
    db->executeQuery(
            QString("insert into settings(type,value)values(\"token\",\"%1\")").arg(token));
    QmlDocument *qml = QmlDocument::create("asset:///LoadingPage.qml").parent(this);
    qml->setContextProperty("app", this);
    AbstractPane *root = qml->createRootObject<AbstractPane>();
    Application::instance()->setScene(root);
}
QString ApplicationUI::getToken()
{
    QSqlQuery query = db->executeSqlQuery(
            QString("select value from settings where type = \"token\""));
    QString token;
    while (query.next()) {
        token = query.value(0).toString();
    }
    return token;
}

QVariant ApplicationUI::getWorkSpacesList()
{
    return db->executeQuery("select * from workspace");
}

QVariant ApplicationUI::getWorkSpace(QString id)
{
    return db->executeQuery(QString("select * from workspace where id = \"%1\"").arg(id));
}
void ApplicationUI::insertTempProject(QString id, bool status)
{
    if (status) {
        db->executeQuery(QString("insert into tempproject(id)values(%1)").arg(id));
    } else {
        db->executeQuery(QString("delete from tempproject where id = \"" + id + "\""));
    }
}
QString ApplicationUI::getTempProjectId()
{
    QSqlQuery query = db->executeSqlQuery("select id from tempproject limit 1");
    QString id;
    int count = db->getTableSize("tempproject");
    if (count > 0) {
        while (query.next()) {
            id = query.value(0).toString();
        }
        return id;
    } else
        return "";
}

void ApplicationUI::insertTempTask(QString id, bool status)
{
    if (status) {
        db->executeQuery(QString("insert into temptask(id)values(%1)").arg(id));
    } else {
        db->executeQuery(QString("delete from temptask where id = \"" + id + "\""));
    }
}
QString ApplicationUI::getTempTaskId()
{
    QSqlQuery query = db->executeSqlQuery("select id from temptask limit 1");
    QString id;
    int count = db->getTableSize("temptask");
    if (count > 0) {
        while (query.next()) {
            id = query.value(0).toString();
        }
        return id;
    } else
        return "";
}

void ApplicationUI::insertTempWorkSpace(QString id, bool status)
{
    if (status) {
        db->executeQuery(QString("insert into tempworkspace(id)values(%1)").arg(id));
    } else {
        db->executeQuery(QString("delete from tempworkspace where id = \"" + id + "\""));
    }
}
QString ApplicationUI::getTempWorkSpaceId()
{
    QSqlQuery query = db->executeSqlQuery("select id from tempworkspace limit 1");
    QString id;
    int count = db->getTableSize("tempworkspace");
    if (count > 0) {
        while (query.next()) {
            id = query.value(0).toString();
        }
        return id;
    } else
        return "";
}
int ApplicationUI::getTableSize(QString tablename)
{
    return db->getTableSize(tablename);
}
void ApplicationUI::projectsToTempProject()
{
    QVariant query = db->executeQuery("select id from projects where archive = \"false\"");
    QVariantList list = query.value<QVariantList>();
    foreach(QVariant var,list){
    QVariantMap map = var.value<QVariantMap>();
    QString id = map.value("id").toString();
    db->executeQuery(QString("insert into tempproject(id)values(%1)").arg(id));
}
}

void ApplicationUI::invokeCard(const QString &memo)
{
    InvokeRequest cardRequest;
    cardRequest.setTarget("com.example.CardApp");
    cardRequest.setAction("bb.action.VIEW");
    cardRequest.setMimeType("application/text");
    cardRequest.setData(memo.toUtf8());
    m_invokeManager->invoke(cardRequest);
}

void ApplicationUI::cardDone(const bb::system::CardDoneMessage &doneMessage)
{
    qDebug() << "cardDone: " << doneMessage.reason();
}
int ApplicationUI::getProjectsCountInWorkSpace(QString id)
{
    return db->getTableSizeByQuery(
            QString(
                    "select count(*) from projects where workspace = \"%1\" and archive = \"false\"").arg(
                    id));
}
QString ApplicationUI::getWorkSpaceId(QString name)
{
    QSqlQuery query = db->executeSqlQuery(
            QString("select id from workspace where name = \"%1\"").arg(name));
    QString id;
    while (query.next()) {
        id = query.value(0).toString();
    }
    return id;
}
QVariant ApplicationUI::getProjectsById(QString id)
{
    return db->executeQuery(
            QString(
                    "select * from projects where workspace = \"%1\" and archive = \"false\" order by modified desc").arg(
                    id));
}

QVariant ApplicationUI::getProject(QString id)
{
    return db->executeQuery(QString("select * from projects where id = \"%1\"").arg(id));
}

QVariant ApplicationUI::getProjectFollowers(QString id)
{
    return db->executeQuery(
            QString(
                    "select name,email from users where id in (select userid from projectfollowers where projectid =\"%1\")").arg(
                    id));
}

QVariant ApplicationUI::getTasks(QString id)
{
    return db->executeQuery(QString("select * from tasks where id = \"" + id + "\""));
}
void ApplicationUI::insertProject2Task(QVariantMap map)
{
    int count =
            db->getTableSizeByQuery(
                    QString(
                            "select count(*) from project2task where projectid=\"%1\" and taskid = \"%2\"").arg(
                            map.value("projectid").toString(), map.value("taskid").toString()));
    count > 0 ? :
                db->insertQuery(
                        "insert into project2task(projectid,taskid)values(:projectid,:taskid)",
                        map);
}
QVariant ApplicationUI::getValueByType(QString type)
{
    return db->executeQuery(QString("select value from settings where type = \"%1\"").arg(type));
}
QVariant ApplicationUI::getTasksByAssignee(QString assignee, QString projectid)
{
    return projectid.isEmpty() ?
            db->executeQuery(
                    QString(
                            "select * from tasks where completed = \"false\" and assignee = \"%1\" order by modified desc").arg(
                            assignee)) :
            db->executeQuery(
                    QString(
                            "select * from tasks where completed = \"false\" and assignee = \"%1\" and id in(select taskid from project2task where projectid =\"%2\") order by modified desc").arg(
                            assignee, projectid));
}
void ApplicationUI::deleteWorkSpace()
{
    db->executeQuery("delete from workspace");
}
QVariant ApplicationUI::getSectionsByProjects(QString projectid)
{
    return db->executeQuery(
            QString(
                    "select * from sectionmeta where id in (select sectionid from membership where projectid = \"%1\")").arg(
                    projectid));
}

QVariant ApplicationUI::getTasksBySections(QString sectionid)
{
    return db->executeQuery(
            QString(
                    "select * from tasks where completed = \"false\" and id in (select taskid from membership where sectionid = \"%1\")").arg(
                    sectionid));
}

QVariant ApplicationUI::searchByProjectID(QString projectid, QString s_string)
{
    return db->executeQuery(
            QString(
                    "select * from tasks where name like \"%" + s_string
                            + "%\" and completed = \"false\" and id in(select taskid from membership where projectid= \"%1\")").arg(
                    projectid));
}

QVariant ApplicationUI::getTasksModel(QString projectid)
{
    return db->executeQuery(
            QString(
                    "select tasks.id,tasks.assignee,tasks.fav,tasks.name as taskname,tasks.due,sectionmeta.name as sectionname from tasks,sectionmeta,membership where tasks.completed = \"false\" and tasks.id = membership.taskid and membership.sectionid =sectionmeta.id and membership.projectid = \"%1\" union select  tasks.id,tasks.assignee,tasks.fav,tasks.name as taskname,tasks.due,null from tasks where completed = \"false\" and id in (select taskid from project2task where ((projectid=\"%2\")and taskid not in (select taskid from membership)))").arg(
                    projectid, projectid));
}
void ApplicationUI::insertSubTasks(QString parentid, QString taskid)
{
    db->executeQuery(
            QString("insert into subtasks(id,parentid)values(%1,%2)").arg(taskid).arg(parentid));
}

void ApplicationUI::flushSubTasks(QString parentid)
{
    db->executeQuery(
            QString(
                    "delete from tasks where id in (select id from subtasks where parentid = \"%1\")").arg(
                    parentid));

    db->executeQuery(QString("delete from subtasks where parentid = \"%1\"").arg(parentid));
}
void ApplicationUI::flushProjectTasks(QString parentid)
{
    db->executeQuery(QString("delete from project2task where projectid = \"%1\"").arg(parentid));
    db->executeQuery(QString("delete from membership where projectid = \"%1\"").arg(parentid));
}
QVariant ApplicationUI::getTaskFollowers(QString taskid)
{
    return db->executeQuery(
            QString(
                    "select users.name,users.email,users.id from users,tasksfollowers where tasksfollowers.taskid = \"%1\" and tasksfollowers.userid=users.id").arg(
                    taskid));
}

QVariant ApplicationUI::getUsersBySearch(QString s_string, QString workid)
{
    return db->executeQuery(
            QString(
                    "select users.id as id ,users.name as name ,users.email as email,users.workid as workid from users,user2workspace where users.name like \"%"
                            + s_string
                            + "%\" and users.id=user2workspace.userid and user2workspace.workid=\"%1\"").arg(
                    workid));
}
QVariant ApplicationUI::getTagsBySearch(QString s_string, QString workid)
{
    return db->executeQuery(
            QString(
                    "select tagsmeta.id,tagsmeta.name,tagsmeta.workid from tagsmeta where name like \"%"
                            + s_string + "%\" and workid = '%1'").arg(workid));
}
QVariant ApplicationUI::getUserByID(QString id)
{
    return db->executeQuery(QString("select * from users where id = \"%1\"").arg(id));
}

QVariant ApplicationUI::getTagsByTaskId(QString taskid, QString workid)
{
    return db->executeQuery(
            QString(
                    "select tagsmeta.name,tagsmeta.id from tagsmeta,tags where tagsmeta.id = tags.tagid and tags.taskid = \"%1\" and tagsmeta.workid = %2").arg(
                    taskid, workid));
}

QVariant ApplicationUI::getNotAssignedUsers(QString id)
{
    return db->executeQuery(QString("select * from users where id !=\"%1\"").arg(id));
}
void ApplicationUI::flushFollowers(QString parentid)
{
    db->executeQuery(QString("delete from tasksfollowers where taskid = \"%1\"").arg(parentid));
}
void ApplicationUI::flushProjectFollowers(QString projectid)
{
    db->executeQuery(
            QString("delete from projectfollowers where projectid = \"%1\"").arg(projectid));
}
void ApplicationUI::flushMemberships(QString parentid)
{
    db->executeQuery(QString("delete from membership where taskid = \"%1\"").arg(parentid));
}
void ApplicationUI::flushTags(QString parentid)
{
    db->executeQuery(QString("delete from tags where taskid = \"%1\"").arg(parentid));
}

void ApplicationUI::insertTagMeta(QString id, QString name, QString workid)
{
    db->executeQuery(
            QString("insert into tagsmeta(id,name,workid)values(%1,\"%2\",%3)").arg(id, name,
                    workid));
}
QVariant ApplicationUI::getSubTasks(QString parentid)
{
    return db->executeQuery(
            QString(
                    "select tasks.id,tasks.name,tasks.due,tasks.completed,tasks.assignee from tasks,subtasks where subtasks.parentid=\"%1\" and subtasks.id=tasks.id").arg(
                    parentid));
}

QVariant ApplicationUI::getAllProjects()
{
    return db->executeQuery(QString("select * from projects where archive = \"false\""));
}
QVariant ApplicationUI::getAllUsers()
{
    return db->executeQuery(QString("select * from users"));
}
QVariantList ApplicationUI::getEmails()
{
    QVariantList list;
    bb::pim::account::Account acc;
    QList<bb::pim::account::Account> emails_attr = bb::pim::account::AccountService().allAccounts();
    foreach(bb::pim::account::Account c,emails_attr){
    list<<c.displayName();
    qDebug()<< "the user email is "<<c.displayName();
}
    return list;
}
void ApplicationUI::cleanWorkspace()
{
    db->executeQuery(QString("delete from workspace"));
}

QVariant ApplicationUI::getTasksByWorkspace(QString id, QString userid)
{
    return db->executeQuery(
            QString("select * from tasks where workid = \"%1\" and assignee = \"%2\" and completed = \"false\"").arg(id,
                    userid));
}
void ApplicationUI::projectLastUpdate(QString id, QString lastupdate)
{
    QVariantMap map;
    map.insert("id", id);
    map.insert("lastupdate", lastupdate);
    db->insertQuery("update projects set lastupdate=:lastupdate where id = :id", map);
}
void ApplicationUI::getImage(QString url_string, QString filename)
{

    QUrl url(url_string);
    DM->append(url_string, filename);

}
void ApplicationUI::SaveSettings(QString name, QString base)
{
    QVariantMap map;
    map["type"] = name;
    map["value"] = base;
    qDebug() << "type" << name << "value" << base;
    QString query = "select count(*) from settings where type =\"";
    query.append(name);
    query.append("\"");
    int setsize = db->getTableSizeByQuery(query);
    if (setsize > 0)
        db->insertQuery("update settings set value= :value where type  = :type", map);
    else
        setSettings(name, base);
}
void ApplicationUI::setSettings(QString name, QString base)
{
    QVariantMap map;
    map["type"] = name;
    map["value"] = base;
    bool test = db->insertQuery("insert into settings(type,value) values(:type,:value)", map);
}
QVariant ApplicationUI::getSettings(QString type)
{
    QVariant var = db->executeQuery(
            QString("select * from settings where type = \"%1\"").arg(type));
    return var;

}
void ApplicationUI::deleteProject(QString projectid)
{
    db->executeQuery(QString("delete from projects where id = \"%1\"").arg(projectid));
    db->executeQuery(QString("delete from membership where projectid = \"%1\"").arg(projectid));
    db->executeQuery(QString("delete from project2task where projectid = \"%1\"").arg(projectid));
    db->executeQuery(
            QString("delete from projectfollowers where projectid = \"%1\"").arg(projectid));
    db->executeQuery(QString("delete from projectmembers where projectid = \"%1\"").arg(projectid));
    Q_EMIT projectDeleted(projectid);
}
void ApplicationUI::taskViewSendwUpdate(QString taskid)
{
    qDebug() << taskid;
    Q_EMIT taskViewUpdate(taskid);
}

void ApplicationUI::subTaskViewSendwUpdate(QString taskid)
{
    qDebug() << taskid;
    Q_EMIT subTaskViewUpdate(taskid);
}
void ApplicationUI::deleteTask(QString taskid)
{
    db->executeQuery(QString("delete from tasks where id=\"%1\"").arg(taskid));
    db->executeQuery(QString("delete from taskfollowers where taskid=\"%1\"").arg(taskid));
    db->executeQuery(QString("delete from membership where taskid = \"%1\"").arg(taskid));
    db->executeQuery(QString("delete from project2task where taskid = \"%1\"").arg(taskid));
    Q_EMIT projectupdated(taskid);
}
void ApplicationUI::projectViewUpdate(QString pid)
{
    Q_EMIT projectupdated(pid);
}
QVariant ApplicationUI::getSectionsByProjectid(QString projectid)
{
    return db->executeQuery(
            QString(
                    "select distinct sectionmeta.id,sectionmeta.name from sectionmeta,membership where membership.projectid=\"%1\" and membership.sectionid=sectionmeta.id").arg(
                    projectid));
}

bool ApplicationUI::isPhotoAvailable(QString id)
{

    QFile file("./data/ahammedia/" + id + ".png");
    return file.exists();
}
QVariant ApplicationUI::getTagsProjectList(QString taskid)
{
    return db->executeQuery(
            QString(
                    "select projects.name as projectname from projects,project2task where project2task.projectid==projects.id and project2task.taskid=\"%1\"").arg(
                    taskid));
}
QVariant ApplicationUI::getTodaysTasks(QString due, QString user, QString assignee)
{
    if (user == "me") {
        return db->executeQuery(
                QString("select * from tasks where due=\"%1\" and assignee=\"%2\" and completed = \"false\"").arg(due,
                        assignee));
    } else {
        return db->executeQuery(QString("select * from tasks where due=\"%1\" and completed = \"false\"").arg(due));
    }
}
int ApplicationUI::getMyTasksCount(QString assignee)
{
    return db->getTableSizeByQuery(
            QString("select count(*) from tasks where assignee=\"%1\"").arg(assignee));
}

void ApplicationUI::removeTask(QString taskid)
{
    db->executeQuery(QString("delete from tasks where id = \"%1\"").arg(taskid));
}
void ApplicationUI::insertUsers2Work(QString userid, QString workid)
{
    int count =
            db->getTableSizeByQuery(
                    QString(
                            "select count(*) from user2workspace where userid = \"%1\" and  workid = \"%2\"").arg(
                            userid, workid));
    if (!count > 0) {
        db->executeQuery(
                QString("insert into user2workspace(userid,workid)values(%1,%2)").arg(userid,
                        workid));
    }
}
void ApplicationUI::dropTable(QString tablename){
    db->executeQuery(QString("delete from user2workspace"));
}
void ApplicationUI::flushProject2Task(QString taskid){
    db->executeQuery(QString("delete from project2task where taskid = \"%1\"").arg(taskid));
}
void ApplicationUI::flushProject(QString projectid){
    db->executeQuery(QString("delete from projects where id = \"%1\"").arg(projectid));
}
void ApplicationUI::deleteTaskItem(QString taskid)
{
    db->executeQuery(QString("delete from tasks where id=\"%1\"").arg(taskid));
}
void ApplicationUI::flushandResync(QString key){
    db->insertQuery("delete from workspace", QVariantMap());
    db->insertQuery("delete from projects", QVariantMap());
    db->insertQuery("delete from users", QVariantMap());
    db->insertQuery("delete from tasks", QVariantMap());
    db->insertQuery("delete from subtasks", QVariantMap());
    db->insertQuery("delete from tasksfollowers", QVariantMap());
    db->insertQuery("delete from membership", QVariantMap());
    db->insertQuery("delete from sectionmeta", QVariantMap());
    db->insertQuery("delete from tagsmeta", QVariantMap());
    db->insertQuery("delete from tags", QVariantMap());
    db->insertQuery("delete from fav", QVariantMap());
    db->insertQuery("delete from tempproject", QVariantMap());
    db->insertQuery("delete from temptask", QVariantMap());
    db->insertQuery("delete from tempworkspace", QVariantMap());
    db->insertQuery("delete from projectmembers", QVariantMap());
    db->insertQuery("delete from projectfollowers", QVariantMap());
    db->insertQuery("delete from project2task", QVariantMap());
    db->executeQuery(
                QString("insert into settings(type,value)values(\"token\",\"%1\")").arg(key));
        QmlDocument *qml = QmlDocument::create("asset:///LoadingPage.qml").parent(this);
        qml->setContextProperty("app", this);
        AbstractPane *root = qml->createRootObject<AbstractPane>();
        Application::instance()->setScene(root);
}

