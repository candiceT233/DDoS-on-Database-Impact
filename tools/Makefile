

pat:
	@echo "Installing python2 and python2 packages for PAT"
	sudo apt install -y python2
	sudo apt install python-pip
	python2 -m pip install matplotlib XlsxWriter
	python2 -m pip install --upgrade numpy scipy matplotlib

ddos:
	@echo "Installing python3 and python3 packages for DDOS"
	sudo apt install -y python3
	sudo apt install python3-pip
	cd MHDDoS && pip install -r requirements.txt

all: pat ddos
