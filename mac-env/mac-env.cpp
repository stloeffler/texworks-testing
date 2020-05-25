#include <QApplication>
#include <QProcess>
#include <QDebug>

void run(QString cmd, QStringList args = QStringList()) {
	QProcess p;

	p.start(cmd, args);
	p.waitForFinished();

	QString header = cmd;
	if (!args.isEmpty()) {
		header += QStringLiteral(" ") + args.join(" ");
	}

	qDebug() << qPrintable(QStringLiteral("========= %1 =========").arg(header));
	qDebug() << qPrintable(p.readAllStandardOutput());
}

int main(int argc, char ** argv)
{
	QApplication app(argc, argv);

	run(QStringLiteral("env"));
	run(QStringLiteral("sh"), {QStringLiteral("-c"), QStringLiteral("env")});

	return 0;
}
