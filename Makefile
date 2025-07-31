# Makefile for CoreDNS Rock
# Description: This Makefile installs necessary tools and updates components.

which_jq = $(shell which jq)
which_yq = $(shell which yq)
COREDNS_GIT_DIR = /tmp/coredns.git

.PHONY: JQ
JQ:
	@if [ -z "${which_jq}" ]; then \
		echo "Installing jq..."; \
		sudo apt-get update && sudo apt-get install -y jq; \
	else \
		echo "jq is installed @ ${which_jq}"; \
	fi

.PHONY: YQ
YQ:
	@if [ -z "$(which_yq)" ]; then \
		echo "Installing yq..."; \
		sudo snap install yq; \
	else \
		echo "yq is installed @ ${which_yq}"; \
	fi

.PHONY: install-tools
install-tools: JQ YQ
	@echo "Tools installed."

.PHONY: clone-CoreDNS
clone-CoreDNS:
	@echo "Cloning CoreDNS..."
	@if [ -d $(COREDNS_GIT_DIR) ]; then \
		echo "CoreDNS already cloned."; \
	else \
		mkdir -p $(COREDNS_GIT_DIR); \
		git clone --bare --filter=blob:none --no-checkout https://github.com/coredns/coredns.git $(COREDNS_GIT_DIR); \
	fi

.PHONY: update-component
update-component: install-tools clone-CoreDNS
	@echo "Updating component..."
	@COREDNS_GIT_DIR=$(COREDNS_GIT_DIR) FIPS_ENABLED=$(FIPS_ENABLED) build/craft_release.sh

# Target to remove the temporary directory
clean:
	@rm -rf $(COREDNS_GIT_DIR)
	@echo "Temporary directory removed: $(COREDNS_GIT_DIR)"
