
# Define variables
HUGO_VERSION := 0.88.1
HUGO_BINARY := hugo_$(HUGO_VERSION)_Linux-64bit.deb

# Install Hugo
install-hugo:
	wget https://github.com/gohugoio/hugo/releases/download/v$(HUGO_VERSION)/$(HUGO_BINARY)
	sudo dpkg -i $(HUGO_BINARY)
	rm $(HUGO_BINARY)

# Set up environment to generate site
setup:
	hugo

serve:
	hugo serve