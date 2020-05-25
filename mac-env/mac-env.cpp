#include <QApplication>
#include <QFile>
#include <QProcess>
#include <QDebug>

void run(QString cmd, QStringList args = QStringList()) {
	QProcess p;

	QString header = cmd;
	if (!args.isEmpty()) {
		header += QStringLiteral(" ") + args.join(" ");
	}

	QFile log(QStringLiteral("mac-env.log"));
	if (log.open(QFile::WriteOnly | QFile::Append)) {
		QTextStream strm(&log);
		strm << QStringLiteral("\n========= %1 =========\n").arg(header);
	}
	log.close();


	p.setStandardOutputFile(QStringLiteral("mac-env.log"), QIODevice::Append);
	p.start(cmd, args);
	p.waitForFinished();
/*

	qDebug() << qPrintable(QStringLiteral("========= %1 =========").arg(header));
	qDebug() << qPrintable(p.readAllStandardOutput());
*/
}

int main(int argc, char ** argv)
{
	QApplication app(argc, argv);

	QFile log(QStringLiteral("mac-env.log"));
	if (log.open(QFile::WriteOnly | QFile::Truncate)) {
		log.close();
	}

	run(QStringLiteral("env"));
	run(QStringLiteral("sh"), {QStringLiteral("-c"), QStringLiteral("env")});

	return 0;
}
