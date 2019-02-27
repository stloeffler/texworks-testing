// Taken from https://stackoverflow.com/a/34032216

function Controller()
{
	installer.autoRejectMessageBoxes();
	installer.installationFinished.connect(function() {
		gui.clickButton(buttons.NextButton);
	})
}

Controller.prototype.WelcomePageCallback = function() {
	gui.clickButton(buttons.NextButton, 3000);
}

Controller.prototype.CredentialsPageCallback = function() {
	gui.clickButton(buttons.NextButton);
}

Controller.prototype.IntroductionPageCallback = function() {
	gui.clickButton(buttons.NextButton);
}

Controller.prototype.TargetDirectoryPageCallback = function()
{
//	gui.currentPageWidget().TargetDirectoryLineEdit.setText(installer.value("HomeDir") + "/Qt");
	gui.clickButton(buttons.NextButton);
}

Controller.prototype.ComponentSelectionPageCallback = function() {
	var widget = gui.currentPageWidget();

	widget.deselectAll();
	widget.selectComponent("qt.qt5.5121.qtscript");
	widget.selectComponent("qt.qt5.5121.win32_msvc2017");
	//widget.selectComponent("qt.qt5.5121.win32_msvc2017_64");
	//widget.selectComponent("qt.qt5.5121.win64_mingw73");
}


Controller.prototype.LicenseAgreementPageCallback = function() {
	gui.currentPageWidget().AcceptLicenseRadioButton.setChecked(true);
	gui.clickButton(buttons.NextButton);
}


Controller.prototype.StartMenuDirectoryPageCallback = function() {
	gui.clickButton(buttons.NextButton);
}

Controller.prototype.ReadyForInstallationPageCallback = function()
{
	gui.clickButton(buttons.NextButton);
}

Controller.prototype.FinishedPageCallback = function() {
	var checkBoxForm = gui.currentPageWidget().LaunchQtCreatorCheckBoxForm;
	if (checkBoxForm && checkBoxForm.launchQtCreatorCheckBox) {
		checkBoxForm.launchQtCreatorCheckBox.checked = false;
	}
	gui.clickButton(buttons.FinishButton);
}
