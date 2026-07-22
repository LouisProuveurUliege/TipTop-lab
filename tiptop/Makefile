BRIDGES   := tiptop-br-earth tiptop-br-hub tiptop-br-rover tiptop-br-space

.PHONY: all lab bridges clean destroy-bridges

all: lab

lab: bridges
	sudo containerlab deploy

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