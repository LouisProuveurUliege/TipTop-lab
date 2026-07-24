BRIDGES   := tiptop-br-earth tiptop-br-hub tiptop-br-rover tiptop-br-space

# Link imparement settings
BANDWIDTH	?= 1000000		# kbps
DELAY		?= 3s

.PHONY: all lab bridges clean destroy-bridges

all: lab

lab: bridges
	sudo containerlab deploy
	echo "Applying impairment: $(BANDWIDTH)kbps and $(DELAY) delay;"
	containerlab tools netem set -n clab-tiptop-GS1 -i eth1 --rate $(BANDWIDTH) --delay $(DELAY)
	containerlab tools netem set -n clab-tiptop-GS2 -i eth1 --rate $(BANDWIDTH) --delay $(DELAY) 
	containerlab tools netem set -n clab-tiptop-GS3 -i eth1 --rate $(BANDWIDTH) --delay $(DELAY) 
	containerlab tools netem set -n clab-tiptop-Orbiter1 -i eth4 --rate $(BANDWIDTH) --delay $(DELAY) 
	containerlab tools netem set -n clab-tiptop-Orbiter2 -i eth4 --rate $(BANDWIDTH) --delay $(DELAY) 

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