.PHONY: all
all : base14-fonts-locked.pdf logo.pdf

base14-fonts-locked.pdf : base14-fonts.pdf
	pdftk $< output $@ compress user_pw 123 owner_pw test

logo.pdf : ../icons/tango-qtpdf/apps/512x512/QtPDF.png
	convert $< jpg:- | convert jpg:- -density 59 $@

