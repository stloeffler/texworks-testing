/*
#include <QApplication>
#include <QMessageBox>

int main(int argc, char * argv[]) {
	QApplication app(argc, argv);
	QMessageBox::information(nullptr, QStringLiteral("It works!"), QStringLiteral("Hello World"));
	return 0;
}
*/

#include <QDebug>
#include <iostream>


void messageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
	std::cout << qUtf8Printable(msg) << "\n";
}

int main() {
	qInstallMessageHandler(messageHandler);

	std::cout << "OK" << std::endl;
	qDebug() << "Hello World";
	std::cout << "OK2" << std::endl;
	return 0;
}

/*
#include <iostream>
int main() {
	std::cout << "Hello World\n";
	return 0;
}
*/
