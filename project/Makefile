# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: kichkiro <kichkiro@student.42firenze.it    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/06/12 14:53:55 by kichkiro          #+#    #+#              #
#    Updated: 2024/07/04 20:37:08 by kichkiro         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Config ---------------------------------------------------------------------->

.PHONY: all up down start stop clean fclean re setup_firewall setup_elasticsearch
.SILENT:

IMAGES?=

NETWORKS = proxy-waf app log-system monitor-system
VOLUMES = db elasticsearch
CONTAINERS = nginx, django, postgres, elasticsearch, logstash, kibana

WHITE_BOLD=\033[1;37m
BLUE=\033[0;34m
NC=\033[0m

# Env ------------------------------------------------------------------------->

export $(shell sed 's/=.*//' .env)

# Defines --------------------------------------------------------------------->

define create_network
	@if ! docker network ls --format '{{.Name}}' | grep -w $(1) > /dev/null 2>&1; then \
		docker network create --subnet=$(2) --gateway=$(3) $(1) > /dev/null 2>&1; \
		echo "$(BLUE)    Network $(WHITE_BOLD)$(1) $(BLUE)created$(NC)"; \
	else \
		echo "$(BLUE)    Network $(WHITE_BOLD)$(1) $(BLUE)already exists$(NC)"; \
	fi
endef

define create_volume
	@if ! docker volume ls --format '{{.Name}}' | grep -w $(1)> /dev/null 2>&1; then \
		docker volume create $(1) > /dev/null 2>&1; \
		echo "$(BLUE)    Volume $(WHITE_BOLD)$(1) $(BLUE)created$(NC)"; \
	else \
		echo "$(BLUE)    Volume $(WHITE_BOLD)$(1) $(BLUE)already exists$(NC)"; \
	fi
endef

define build_image
	@docker build \
		$(foreach arg,$(filter-out $(1),$(2)),--build-arg $(arg) ) \
		-t $(1) $(3); \
	echo "$(BLUE)    Image $(WHITE_BOLD)$(1) $(BLUE)built$(NC)"
endef

define start_container
	@if [ ! "$(shell docker ps -q -f name=$(1))" ]; then \
		docker run -d \
			--name $(1) \
			--network $(2) \
			--ip $(3) \
			--restart $(4) \
			--env-file .env \
			-p $(5) \
			$(6); \
		echo "$(BLUE)    Container $(WHITE_BOLD)$(1) $(BLUE)started$(NC)"; \
	else \
		echo "$(BLUE)    Container $(WHITE_BOLD)$(1) $(BLUE)already running$(NC)"; \
	fi
endef

# Rules ----------------------------------------------------------------------->

all: up

up:
	@echo "\n$(BLUE)[+] Creating networks$(NC)"
	$(call create_network,proxy-waf,10.0.0.0/24,10.0.0.254)
	$(call create_network,app,10.0.1.0/24,10.0.1.254)
	$(call create_network,log-system,10.0.2.0/24,10.0.2.254)
	$(call create_network,monitor-system,10.0.3.0/24,10.0.3.254)
	$(call create_network,secrets,10.0.4.0/24,10.0.4.254)
	@echo "\n$(BLUE)[+] Creating volumes$(NC)"
	$(call create_volume,db)
	$(call create_volume,elasticsearch)
	@echo "\n$(BLUE)[+] Building images$(NC)"
	@docker build -t django -f ./requirements/django/Dockerfile ./requirements/django
	@docker build -t postgres -f ./requirements/postgres/Dockerfile ./requirements/postgres
	@echo "\n$(BLUE)[+] Starting containers$(NC)"
	# $(call start_container,nginx,proxy-waf,10.0.0.1,always,"-p 8080:8080 -p 8443:8443" "nginx_image")
	$(call start_container,django,app,10.0.1.1,always,"8000:8000", "django")
	$(call start_container,postgres,app,10.0.1.2,always,"" "postgres")
	# $(call start_container,elasticsearch,log-system,10.0.2.1,unless-stopped,"-p 9200:9200" "elasticsearch_image")
	# $(call start_container,logstash,log-system,10.0.2.2,unless-stopped,"-p 50000:50000/udp -p 9600:9600" "logstash_image")
	# $(call start_container,kibana,log-system,10.0.2.3,unless-stopped,"-p 5601:5601" "kibana_image")














# up: setup_firewall
# 	@echo
# 	docker compose -p "ft_transcendence" up -d 

down:
	docker compose down

start:
	docker compose start

stop:
	docker compose stop

clean:
	@echo "\n$(BLUE)[+] Removing all containers$(NC)"
	@docker ps -qa | while read id; do \
		name=$$(docker inspect --format='{{.Name}}' $$id | sed 's/^\/\(.*\)/\1/'); \
		echo "    $(BLUE)Removing: $(WHITE_BOLD)$$name$(NC)"; \
		docker rm -f $$id > /dev/null 2>&1; \
	done
	@if [ -z "$(IMAGES)" ]; then \
		echo "\n$(BLUE)[+] Removing all images$(NC)"; \
		docker images -q | while read id; do \
			name=$$(docker inspect --format='{{.RepoTags}}' $$id); \
			echo "    $(BLUE)Removing: $(WHITE_BOLD)$$name$(NC)"; \
			docker rmi -f $$id > /dev/null 2>&1; \
		done; \
	else \
		echo "\n$(BLUE)[+] Removing specified images$(NC)";\
		for image in $(IMAGES); do \
			id=$$(docker images -q $$image 2>/dev/null); \
			if [ ! -z "$$id" ]; then \
				name=$$(docker inspect --format="{{.RepoTags}}" $$id); \
				echo "    $(BLUE)Removing: $(WHITE_BOLD)$$name$(NC)"; \
				docker rmi -f $$id > /dev/null 2>&1; \
			fi; \
		done; \
	fi

fclean: clean
	@echo "\n$(BLUE)[+] Removing all networks$(NC)"
	@docker network ls -q | while read id; do \
		name=$$(docker network inspect --format='{{.Name}}' $$id); \
		echo "    $(BLUE)Removing: $(WHITE_BOLD)$$name$(NC)"; \
		docker network rm $$id > /dev/null 2>&1; \
	done
	@echo "\n$(BLUE)[+] Removing all volumes$(NC)"
	@docker volume ls -q | while read id; do \
		echo "    $(BLUE)Removing: $(WHITE_BOLD)$$id$(NC)"; \
		docker volume rm $$id > /dev/null 2>&1; \
	done
	@echo "\n$(BLUE)[+] Removing all build cache$(NC)"
	@-docker builder prune --all --force > /dev/null 2>&1
	@echo "\n$(BLUE)[+] Cleanup complete$(NC)"

re: clean up

setup_firewall:
	iptables -F DOCKER-USER
	iptables -A DOCKER-USER -s 0.0.0.0/0 -d 0.0.0.0/0 -j RETURN
	iptables -I DOCKER-USER -s 10.0.0.0/24 -d 10.0.0.0/24 -j DROP
	iptables -I DOCKER-USER -s 10.0.1.0/24 -d 10.0.1.0/24 -j DROP
	iptables -I DOCKER-USER -s 10.0.2.0/24 -d 10.0.2.0/24 -j DROP
	iptables -I DOCKER-USER -s 10.0.3.0/24 -d 10.0.3.0/24 -j DROP
	iptables -I DOCKER-USER -s 10.0.4.0/24 -d 10.0.4.0/24 -j DROP

	iptables -I DOCKER-USER -s 10.0.1.1 -d 10.0.1.2 -p tcp --dport 5432 -j ACCEPT

	iptables -I DOCKER-USER -s 10.0.1.0/24 -d 10.0.2.2 -p udp --dport 50000 -j ACCEPT
	iptables -I DOCKER-USER -p udp --dport 50000 -j ACCEPT
	iptables -I DOCKER-USER -p udp --sport 50000 -j ACCEPT

	iptables -I DOCKER-USER -s 10.0.2.3 -d 10.0.2.1 -p tcp --dport 9200 -j ACCEPT
	iptables -I DOCKER-USER -s 10.0.2.2 -d 10.0.2.1 -p tcp --dport 9200 -j ACCEPT

	iptables -I DOCKER-USER -s 10.0.3.1 -d 10.0.1.1 -p tcp --dport 8000 -j ACCEPT
	iptables -I DOCKER-USER -s 10.0.3.1 -d 10.0.1.2 -p tcp --dport 5432 -j ACCEPT





	iptables -I DOCKER-USER -m state --state ESTABLISHED,RELATED -j ACCEPT

setup_elasticsearch:
	docker exec elasticsearch /tmp/set_users.sh
	docker exec elasticsearch rm /tmp/set_users.sh
	docker exec elasticsearch rm /tmp/lib.sh
	docker exec elasticsearch rm /tmp/logstash_writer.json
