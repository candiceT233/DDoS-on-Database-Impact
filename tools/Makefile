DOWNLOAD_PATH=$(HOME)/downloads
SCRIPT_PATH=$(HOME)/scripts/DDoS-on-Database-Impact
DDOS_PATH=$(SCRIPT_PATH)/tools/MHDDoS

pat:
	@echo "Installing python2 and python2 packages for PAT"
	sudo apt install -y python2
	sudo apt install python-pip
	# wget $(DOWNLOAD_PATH)/https://bootstrap.pypa.io/pip/2.7/get-pip.py
	# sudo /usr/bin/python2 $(DOWNLOAD_PATH)/get-pip.py
	# sudo apt-get update
	# sudo apt-get install python2-pip
	python2 -m pip install matplotlib XlsxWriter
	python2 -m pip install --upgrade numpy scipy matplotlib

ddos_venv:
	sudo apt install -y python3.8-venv
	cd $(SCRIPT_PATH) && python3 -m venv .ddos_test_env
	source $(SCRIPT_PATH)/.ddos_test_env/bin/activate
	cd $(DDOS_PATH) && pip install -r requirements.txt
	deactivate

ddos_dep:
	@echo "Installing python3 and python3 packages for DDOS"
	sudo apt install -y python3
	sudo apt install -y python3-pip
	# cd MHDDoS && pip install -r requirements.txt

ddos: ddos_dep ddos_venv

all: pat ddos ddos_venv
