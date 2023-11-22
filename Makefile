
# Define variables
HUGO_VERSION := 0.117.0
HUGO_BINARY := hugo_extended_$(HUGO_VERSION)_linux-amd64.deb

# Install Hugo
install:
	wget https://github.com/gohugoio/hugo/releases/download/v$(HUGO_VERSION)/$(HUGO_BINARY)
	sudo dpkg -i $(HUGO_BINARY)
	rm $(HUGO_BINARY)

serve:
	hugo serve