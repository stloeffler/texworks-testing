/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2019-2024  Stefan Löffler

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.

	For links to further information, or to contact the authors,
	see <http://www.tug.org/texworks/>.
*/

#include "document/SpellChecker.h"

#include "TWUtils.h" // for TWUtils::getLibraryPath
#include "utils/ResourcesLibrary.h"

#include <hunspell.h>

#include <QLocale>

namespace Tw {
namespace Document {

QMultiHash<QString, QString> * SpellChecker::dictionaryList = nullptr;
QHash<const QString,SpellChecker::Dictionary*> * SpellChecker::dictionaries = nullptr;
SpellChecker * SpellChecker::_instance = new SpellChecker();

// static
QString SpellChecker::labelForDict(QString &dict)
{
	QLocale loc{dict};

	if (loc.language() != QLocale::C) {
		const QString languageString = QLocale::languageToString(loc.language());
#if QT_VERSION < QT_VERSION_CHECK(6, 2, 0)
		const QString territoryString = (loc.country() != QLocale::AnyCountry ? QLocale::countryToString(loc.country()) : QString());
#else
		const QString territoryString = (loc.territory() != QLocale::AnyTerritory ? QLocale::territoryToString(loc.territory()) : QString());
#endif
		if (!territoryString.isEmpty()) {
			//: Format to display spell-checking dictionaries (ex. "English - United States (en_US)")
			return tr("%1 - %2 (%3)").arg(languageString, territoryString, dict);
		}
		else {
			//: Format to display spell-checking dictionaries (ex. "English (en)")
			return tr("%1 (%2)").arg(languageString, dict);
		}
	}
	return dict;
}

QMultiHash<QString, QString> * SpellChecker::getDictionaryList(const bool forceReload /* = false */)
{
	if (dictionaryList) {
		if (!forceReload)
			return dictionaryList;
		delete dictionaryList;
	}

	dictionaryList = new QMultiHash<QString, QString>();
	const QStringList dirs = Tw::Utils::ResourcesLibrary::getLibraryPaths(QStringLiteral("dictionaries"));
	foreach (QDir dicDir, dirs) {
		foreach (QFileInfo dicFileInfo, dicDir.entryInfoList(QStringList(QString::fromLatin1("*.dic")),
					QDir::Files | QDir::Readable, QDir::Name | QDir::IgnoreCase)) {
			QFileInfo affFileInfo(dicFileInfo.dir(), dicFileInfo.completeBaseName() + QLatin1String(".aff"));
			if (affFileInfo.isReadable())
				dictionaryList->insert(dicFileInfo.canonicalFilePath(), dicFileInfo.completeBaseName());
		}
	}

	emit SpellChecker::instance()->dictionaryListChanged();
	return dictionaryList;
}

// static
SpellChecker::Dictionary * SpellChecker::getDictionary(const QString& language)
{
	if (language.isEmpty())
		return nullptr;

	if (!dictionaries)
		dictionaries = new QHash<const QString, Dictionary*>;

	if (dictionaries->contains(language))
		return dictionaries->value(language);

	const QStringList dirs = Tw::Utils::ResourcesLibrary::getLibraryPaths(QStringLiteral("dictionaries"));
	foreach (QDir dicDir, dirs) {
		QFileInfo affFile(dicDir, language + QLatin1String(".aff"));
		QFileInfo dicFile(dicDir, language + QLatin1String(".dic"));
		if (affFile.isReadable() && dicFile.isReadable()) {
			Hunhandle * h = Hunspell_create(affFile.canonicalFilePath().toLocal8Bit().data(),
								dicFile.canonicalFilePath().toLocal8Bit().data());
			dictionaries->insert(language, new Dictionary(language, h));
			return dictionaries->value(language);
		}
	}
	return nullptr;
}

// static
void SpellChecker::clearDictionaries()
{
	if (!dictionaries)
		return;

	foreach(Dictionary * d, *dictionaries)
		delete d;

	delete dictionaries;
	dictionaries = nullptr;
}

SpellChecker::Dictionary::Dictionary(const QString & language, Hunhandle * hunhandle)
	: _language(language)
	, _hunhandle(hunhandle)
	, _codec(nullptr)
{
	if (_hunhandle)
		_codec = QTextCodec::codecForName(Hunspell_get_dic_encoding(_hunhandle));
	if (!_codec)
		_codec = QTextCodec::codecForLocale(); // almost certainly wrong, if we couldn't find the actual name!
}

SpellChecker::Dictionary::~Dictionary()
{
	if (_hunhandle)
		Hunspell_destroy(_hunhandle);
}

bool SpellChecker::Dictionary::isWordCorrect(const QString & word) const
{
	return (Hunspell_spell(_hunhandle, _codec->fromUnicode(word).data()) != 0);
}

QList<QString> SpellChecker::Dictionary::suggestionsForWord(const QString & word) const
{
	QList<QString> suggestions;
	char ** suggestionList{nullptr};

	int numSuggestions = Hunspell_suggest(_hunhandle, &suggestionList, _codec->fromUnicode(word).data());
	suggestions.reserve(numSuggestions);
	for (int iSuggestion = 0; iSuggestion < numSuggestions; ++iSuggestion)
		suggestions.append(_codec->toUnicode(suggestionList[iSuggestion]));

	Hunspell_free_list(_hunhandle, &suggestionList, numSuggestions);

	return suggestions;
}

void SpellChecker::Dictionary::ignoreWord(const QString & word)
{
	// note that this is not persistent after quitting TW
	Hunspell_add(_hunhandle, _codec->fromUnicode(word).data());
}

} // namespace Document
} // namespace Tw
