#include <QString>
#include <QDebug>

#if defined(Q_OS_DARWIN)
#include <CoreServices/CoreServices.h>

extern QString getOSVersionString();
#endif


int main() {

	qDebug() << QStringLiteral("OK");

#if defined(Q_OS_DARWIN)
	SInt32 major = 0, minor = 0, bugfix = 0;
	Gestalt(gestaltSystemVersionMajor, &major);
	Gestalt(gestaltSystemVersionMinor, &minor);
	Gestalt(gestaltSystemVersionBugFix, &bugfix);
	qDebug() << QString::fromLatin1("Mac OS X %1.%2.%3").arg(major).arg(minor).arg(bugfix);

	qDebug() << getOSVersionString();
#endif

	return 0;
}
