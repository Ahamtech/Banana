/*
 * Copyright (c) 2013 BlackBerry Limited.
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

#include <math.h>

#include "Account.hpp"

#include <QDebug>

Account::Account(UDSUtil* udsUtil, HubCache* hubCache) : HubAccount(udsUtil, hubCache)
{

	_categoryId = 0;
    _name = "Banana";
    _displayName = "Banana";
    _serverName = "Banana";
    _iconFilename = "itemRead.png";
    _lockedIconFilename = "acc_locked.png";
    _composeIconFilename = "acc.png";
    _supportsCompose = true;
    _supportsMarkRead = true;
    _supportsMarkUnread = true;
    _headlessTarget = "in.ahamtech.bananaService";
    _appTarget = "in.ahamtech.banana";
    _cardTarget = "in.ahamtech.banana.taskview";
    _cardCompose = "in.ahamtech.banana.compose";
    _itemMimeType = "hub/vnd.banana.item";  // mime type for hub items - if you change this, adjust invocation targets
                                            // to match and ensure this is unique for your application or you might invoke the wrong card
    _itemComposeIconFilename = "compose.png";
    _itemReadIconFilename = "itemRead.png";
    _itemUnreadIconFilename = "itemUnread.png";
    _markReadActionIconFilename = "itemMarkRead.png";
    _markUnreadActionIconFilename = "itemMarkUnread.png";

    // on device restart / update, it may be necessary to reload the Hub
    if (_udsUtil->reloadHub()) {
        _udsUtil->cleanupAccountsExcept(-1, _displayName);
        _udsUtil->initNextIds();
    }

    initialize();

    // reload existing hub items if required
    if (_udsUtil->reloadHub()) {
        repopulateHub();

        _udsUtil->resetReloadHub();
    }
}

Account::~Account()
{
}
qint64 Account::accountId()
{
    return _accountId;
}

qint64 Account::categoryId()
{
    return _categoryId;
}

void Account::initializeCategories(QVariantList newCategories)
{
    HubAccount::initializeCategories(newCategories);

    if (_categoriesInitialized) {
        // initialize category ID - we are assuming that we only added one category
        QVariantList categories = _hubCache->categories();

        _categoryId = categories[0].toMap()["categoryId"].toLongLong();
    }
}
