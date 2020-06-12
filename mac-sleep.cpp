#include <QElapsedTimer>
#include <QDebug>
#include <QtTest/QtTest>

int main() {
	QElapsedTimer t;


	for (int i = 0; i < 25; ++i) {
		t.start();
		QTest::qSleep(50);
		qDebug() << t.elapsed();
	}
	return 0;
}
