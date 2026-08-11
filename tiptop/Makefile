BRIDGES   := tiptop-br-earth tiptop-br-hub tiptop-br-rover tiptop-br-space

# Link impairment settings
UPLINK_BW	?= 1000000		# bandwidth from earth to space body in kbps
DOWNLINK_BW ?= 1000000		# bandwidth from space body to earth in kbps
DELAY		?= 1.3s 		# one-way delay on deep space links

.PHONY: all lab bridges clean destroy-bridges

all: lab

lab: bridges
	sudo containerlab deploy
	echo "Applying impairment: $(UPLINK_BW)kbps uplink, $(DOWNLINK_BW)kbps downlink, and $(DELAY) delay;"
	containerlab tools netem set -n clab-tiptop-GS1 -i eth1 --rate $(UPLINK_BW) --delay $(DELAY)
	containerlab tools netem set -n clab-tiptop-GS2 -i eth1 --rate $(UPLINK_BW) --delay $(DELAY) 
	containerlab tools netem set -n clab-tiptop-GS3 -i eth1 --rate $(UPLINK_BW) --delay $(DELAY) 
	containerlab tools netem set -n clab-tiptop-Orbiter1 -i eth4 --rate $(DOWNLINK_BW) --delay $(DELAY) 
	containerlab tools netem set -n clab-tiptop-Orbiter2 -i eth4 --rate $(DOWNLINK_BW) --delay $(DELAY) 

bridges:
	@for br in $(BRIDGES); do \
		if ! ip link show $$br >/dev/null 2>&1; then \
			echo "Creating bridge $$br"; \
			sudo ip link add $$br type bridge; \
			sudo ip link set $$br up; \
		else \
			echo "Bridge $$br already exists, skipping"; \
		fi; \
	done

clean: 
	sudo containerlab destroy --cleanup
	$(MAKE) destroy-bridges

destroy-bridges:
	@for br in $(BRIDGES); do \
		if ip link show $$br >/dev/null 2>&1; then \
			echo "Removing bridge $$br"; \
			sudo ip link set $$br down; \
			sudo ip link delete $$br type bridge; \
		else \
			echo "Bridge $$br not present, skipping"; \
		fi; \
	done