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

.PHONY: all up down start stop clean fclean re setup_firewall dev re-dev
.SILENT:

IMAGES?=

WHITE_BOLD=\033[1;37m
BLUE=\033[0;34m
NC=\033[0m

# Rules ----------------------------------------------------------------------->

all: up

up: setup_firewall
	@echo
	docker compose -p "ft_transcendence" --profile log-system up -d
	docker compose -p "ft_transcendence" --profile monitor-system up -d
	docker compose -p "ft_transcendence" --profile app up -d

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
		if [ "$$name" != "bridge" ] && [ "$$name" != "host" ] && [ "$$name" != "none" ]; then \
			echo "    $(BLUE)Removing: $(WHITE_BOLD)$$name$(NC)"; \
			docker network rm $$id > /dev/null 2>&1; \
		fi \
	done
	@echo "\n$(BLUE)[+] Removing all volumes$(NC)"
	@docker volume ls -q | while read id; do \
		echo "    $(BLUE)Removing: $(WHITE_BOLD)$$id$(NC)"; \
		docker volume rm $$id > /dev/null 2>&1; \
	done
	@echo "\n$(BLUE)[+] Removing all build cache$(NC)"
	@-docker builder prune --all --force > /dev/null 2>&1
	@echo "\n$(BLUE)[+] Cleaning Completed$(NC)"

re: clean up

dev:
	@echo
	docker compose -p "ft_transcendence" --profile app up -d

re-dev: clean dev

setup_firewall:
	# CLEAN DOCKER-USER CHAIN ------------------------------------------------->
	iptables -F DOCKER-USER

	# SET RETURN -------------------------------------------------------------->
	iptables -A DOCKER-USER -s 0.0.0.0/0 -d 0.0.0.0/0 -j RETURN

	# DROP ALL EAST-WEST TRAFFIC ---------------------------------------------->
	iptables -I DOCKER-USER -s 10.0.0.0/24 -d 10.0.0.0/24 -j DROP
	iptables -I DOCKER-USER -s 10.0.1.0/24 -d 10.0.1.0/24 -j DROP
	iptables -I DOCKER-USER -s 10.0.2.0/24 -d 10.0.2.0/24 -j DROP
	iptables -I DOCKER-USER -s 10.0.3.0/24 -d 10.0.3.0/24 -j DROP
	iptables -I DOCKER-USER -s 10.0.4.0/24 -d 10.0.4.0/24 -j DROP

	# APP SEGMENT ------------------------------------------------------------->
	iptables -I DOCKER-USER -s 10.0.1.1 -d 10.0.1.2 -p tcp --dport 5432 -j ACCEPT

	# LOG-SYSTEM SEGMENT ------------------------------------------------------>
	iptables -I DOCKER-USER -s 10.0.2.3 -d 10.0.2.1 -p tcp --dport 9200 -j ACCEPT
	iptables -I DOCKER-USER -s 10.0.2.2 -d 10.0.2.1 -p tcp --dport 9200 -j ACCEPT
	iptables -I DOCKER-USER -p udp --dport 50000 -j ACCEPT
	iptables -I DOCKER-USER -p udp --sport 50000 -j ACCEPT
	iptables -I DOCKER-USER -s 10.0.1.0/24 -d 10.0.2.2 -p udp --dport 50000 -j ACCEPT

	# MONITOR-SYSTEM SEGMENT -------------------------------------------------->
	iptables -I DOCKER-USER -s 10.0.3.2 -d 10.0.3.1 -p tcp --dport 9090 -j ACCEPT
	iptables -I DOCKER-USER -s 10.0.3.1 -d 10.0.1.1 -p tcp --dport 8000 -j ACCEPT
	iptables -I DOCKER-USER -s 10.0.3.1 -d 10.0.1.2 -p tcp --dport 5432 -j ACCEPT

	# SET IPTABLES IN STATEFUL MODE ------------------------------------------->
	iptables -I DOCKER-USER -m state --state ESTABLISHED,RELATED -j ACCEPT
