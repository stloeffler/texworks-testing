include poppler.mk

poppler : $(poppler_FILE)
	if [ "$(shell openssl dgst -sha256 '$^' 2>/dev/null)" != "SHA256($(poppler_FILE))= $(poppler_CHECKSUM)" ]; then echo "\nwrong checksum"; exit 1; fi
	tar -xvf $^
	# FIXME: patch
	$(call poppler_BUILD,$(poppler_SUBDIR))

$(poppler_FILE) :
	wget \$(poppler_URL)

