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

#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_
#include "applicationuibase.hpp"
#include <QObject>
#include "database.hpp"
#include "DownloadManager.hpp"
#include <QPair>
namespace bb
{
    namespace cascades
    {
        class LocaleHandler;
    }
    namespace system
    {
        class InvokeManager;

    }
}
namespace bb
{
    namespace system
    {
        class CardDoneMessage;
    }
}

class QTranslator;
class DownloadManager;

/*!
 * @brief Application UI object
 *
 * Use this object to create and init app UI, to create context objects, to register the new meta types etc.
 */
class ApplicationUI: public ApplicationUIBase
{
Q_OBJECT
public:
    ApplicationUI(bb::system::InvokeManager* invokeManager);
    virtual ~ApplicationUI()
    {
        if (DM) {
            delete DM;
        }
    }
    typedef QPair<QString, QString> pairparams;Q_INVOKABLE
    void invokeCard(const QString &memo);
    void Login();
    void mainView();
    void Init();Q_INVOKABLE
    QString covertToBase64(QString);Q_INVOKABLE
    void insertSettings(QString, QString);Q_INVOKABLE
    void insertWorkspace(QString, QString);Q_INVOKABLE
    void insertProjects(QVariant);Q_INVOKABLE
    void scrapData();Q_INVOKABLE
    void logout();Q_INVOKABLE
    void logincomplete();Q_INVOKABLE
    void insertTask(QVariant data);Q_INVOKABLE
    void insertTag(QString, QString, QString, QString);Q_INVOKABLE
    void insertSectionMeta(QString, QString, QString, QString);Q_INVOKABLE
    void insertUsers(QString id, QString name, QString email);Q_INVOKABLE
    void insertFollowers(QString, QVariantList);Q_INVOKABLE
    void authkeysuccess(QString);Q_INVOKABLE
    QString getToken();Q_INVOKABLE
    QVariant getWorkSpacesList();Q_INVOKABLE
    void insertTempProject(QString, bool);Q_INVOKABLE
    QString getTempProjectId();Q_INVOKABLE
    void insertTempTask(QString, bool);Q_INVOKABLE
    QString getTempTaskId();Q_INVOKABLE
    void insertTempWorkSpace(QString, bool);Q_INVOKABLE
    QString getTempWorkSpaceId();Q_INVOKABLE
    int getTableSize(QString);Q_INVOKABLE
    void insertProjectFollowers(QString, QString);Q_INVOKABLE
    void insertProjectMembers(QString, QString);Q_INVOKABLE
    void projectsToTempProject();Q_INVOKABLE
    int getProjectsCountInWorkSpace(QString id);Q_INVOKABLE
    QString getWorkSpaceId(QString);Q_INVOKABLE
    QVariant getProjectsById(QString);Q_INVOKABLE
    QVariant getProject(QString);Q_INVOKABLE
    QVariant getProjectFollowers(QString id);Q_INVOKABLE
    QVariant getTasks(QString id);Q_INVOKABLE
    void insertProject2Task(QVariantMap);Q_INVOKABLE
    QString getCurrentLanguage();Q_INVOKABLE
    QVariant getValueByType(QString);Q_INVOKABLE
    QVariant getTasksByAssignee(QString, QString);Q_INVOKABLE
    void deleteWorkSpace();Q_INVOKABLE
    QVariant getSectionsByProjects(QString);Q_INVOKABLE
    QVariant getTasksBySections(QString);Q_INVOKABLE
    QVariant searchByProjectID(QString, QString);Q_INVOKABLE
    QVariant getTasksModel(QString);Q_INVOKABLE
    void insertSubTasks(QString, QString);Q_INVOKABLE
    void flushSubTasks(QString);Q_INVOKABLE
    void flushTags(QString);Q_INVOKABLE
    void flushMemberships(QString);Q_INVOKABLE
    void flushFollowers(QString);Q_INVOKABLE
    QVariant getTaskFollowers(QString);Q_INVOKABLE
    QVariant getUsersBySearch(QString, QString);Q_INVOKABLE
    QVariant getTagsBySearch(QString, QString);Q_INVOKABLE
    QVariant getUserByID(QString);Q_INVOKABLE
    QVariant getTagsByTaskId(QString, QString);Q_INVOKABLE
    QVariant getNotAssignedUsers(QString);Q_INVOKABLE
    void updateTaskTags(QString tagid, QString taskid, bool status);Q_INVOKABLE
    void insertTagMeta(QString, QString, QString);Q_INVOKABLE
    QVariant getSubTasks(QString parentid);Q_INVOKABLE
    QVariant getAllProjects();Q_INVOKABLE
    QVariant getAllUsers();Q_INVOKABLE
    QVariantList getEmails();Q_INVOKABLE
    void cleanWorkspace();Q_INVOKABLE
    QVariant getTasksByWorkspace(QString, QString);Q_INVOKABLE
    void projectLastUpdate(QString, QString);Q_INVOKABLE
    void flushProjectFollowers(QString);Q_INVOKABLE
    void getImage(QString, QString);Q_INVOKABLE
    void SaveSettings(QString, QString);Q_INVOKABLE
    void setSettings(QString, QString);Q_INVOKABLE
    QVariant getWorkSpace(QString);Q_INVOKABLE
    QVariant getSettings(QString);Q_INVOKABLE
    void deleteProject(QString);Q_INVOKABLE
    void taskViewSendwUpdate(QString);Q_INVOKABLE
    void subTaskViewSendwUpdate(QString);Q_INVOKABLE
    void deleteTask(QString);Q_INVOKABLE
    void projectViewUpdate(QString);Q_INVOKABLE
    QVariant getSectionsByProjectid(QString);Q_INVOKABLE
    bool isPhotoAvailable(QString);Q_INVOKABLE
    QVariant getTagsProjectList(QString);Q_INVOKABLE
    void flushProjectTasks(QString);Q_INVOKABLE
    QVariant getTodaysTasks(QString, QString, QString);Q_INVOKABLE
    int getMyTasksCount(QString);Q_INVOKABLE
    void removeTask(QString);Q_INVOKABLE
    void insertUsers2Work(QString, QString);Q_INVOKABLE
    void dropTable(QString);Q_INVOKABLE
    void flushProject(QString projectid);Q_INVOKABLE
    void deleteTaskItem(QString);Q_INVOKABLE
    void flushProject2Task(QString);
    Q_INVOKABLE void flushandResync(QString);
private slots:
    void onSystemLanguageChanged();
    void cardDone(const bb::system::CardDoneMessage& doneMessage);
private:
    QTranslator* m_translator;
    bb::cascades::LocaleHandler* m_localeHandler;
    bb::system::InvokeManager* m_invokeManager;
    Database *db;
    DownloadManager *DM;
    bool isDatabaseOpen;signals:
    void projectupdated(QString);
    void projectDeleted(QString);
    void taskViewUpdate(QString);
    void subTaskViewUpdate(QString);
};

#endif /* ApplicationUI_HPP_ */
