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

.PHONY: all up down start stop clean fclean re setup_vault setup_firewall
.SILENT:

IMAGES?=

MAKEFLAGS += --no-print-directory

WHITE_BOLD=\033[1;37m
BLUE=\033[0;34m
NC=\033[0m

# Rules ----------------------------------------------------------------------->

all: up

up: setup_firewall 
	@echo "\n$(BLUE)[+] Starting $(WHITE_BOLD)VAULT $(BLUE)profile ..." 
	docker compose -p "ft_transcendence" --profile vault up -d >/dev/null 2>&1 
	@$(MAKE) setup_vault
	docker compose -p "ft_transcendence" --profile log-system up -d
	# docker compose -p "ft_transcendence" --profile monitor-system up -d
	docker compose -p "ft_transcendence" --profile app up -d
	# docker compose -p "ft_transcendence" --profile proxy-waf up -d
	rm -rf .env
	echo

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
	@echo "\n$(BLUE)[+] Removing all volumes$(NC)"
	@docker volume ls -q | while read id; do \
		echo "    $(BLUE)Removing: $(WHITE_BOLD)$$id$(NC)"; \
		docker volume rm $$id > /dev/null 2>&1; \
	done

fclean: clean
	@echo "\n$(BLUE)[+] Removing all networks$(NC)"
	@docker network ls -q | while read id; do \
		name=$$(docker network inspect --format='{{.Name}}' $$id); \
		if [ "$$name" != "bridge" ] && [ "$$name" != "host" ] && [ "$$name" != "none" ]; then \
			echo "    $(BLUE)Removing: $(WHITE_BOLD)$$name$(NC)"; \
			docker network rm $$id > /dev/null 2>&1; \
		fi \
	done
	@echo "\n$(BLUE)[+] Removing all build cache$(NC)"
	@-docker builder prune --all --force > /dev/null 2>&1
	@echo "\n$(BLUE)[+] Cleaning Completed$(NC)"

re: clean up

setup_vault:
	@keys=$$(docker exec hashicorp-vault vault operator init) && \
	key1=$$(echo "$$keys" | grep 'Unseal Key 1:' | awk '{print $$4}') && \
	key2=$$(echo "$$keys" | grep 'Unseal Key 2:' | awk '{print $$4}') && \
	key3=$$(echo "$$keys" | grep 'Unseal Key 3:' | awk '{print $$4}') && \
	key4=$$(echo "$$keys" | grep 'Unseal Key 4:' | awk '{print $$4}') && \
	key5=$$(echo "$$keys" | grep 'Unseal Key 5:' | awk '{print $$4}') && \
	root_token=$$(echo "$$keys" | grep 'Initial Root Token:' | awk '{print $$4}') && \
	echo "\n$(BLUE)[+] Vault initialized. Here are the keys and the root token:" && \
	echo "$(BLUE)    UNSEAL KEY 1: $(WHITE_BOLD)$$key1" && \
	echo "$(BLUE)    UNSEAL KEY 2: $(WHITE_BOLD)$$key2" && \
	echo "$(BLUE)    UNSEAL KEY 3: $(WHITE_BOLD)$$key3" && \
	echo "$(BLUE)    UNSEAL KEY 4: $(WHITE_BOLD)$$key4" && \
	echo "$(BLUE)    UNSEAL KEY 5: $(WHITE_BOLD)$$key5" && \
	echo "$(BLUE)    ROOT TOKEN:   $(WHITE_BOLD)$$root_token" && \
	docker exec hashicorp-vault vault operator unseal $$key1 > /dev/null 2>&1 && \
	docker exec hashicorp-vault vault operator unseal $$key2 > /dev/null 2>&1 && \
	docker exec hashicorp-vault vault operator unseal $$key3 > /dev/null 2>&1 && \
	echo "\n$(BLUE)[+] The vault has been unsealed" && \
	docker exec -e VAULT_TOKEN=$$root_token hashicorp-vault vault secrets enable -path=secret kv >/dev/null 2>&1 && \
	echo "\n$(BLUE)[+] Enabled the kv secrets engine at: $(WHITE_BOLD)secret/" && \
	docker exec -e VAULT_TOKEN=$$root_token -i hashicorp-vault vault kv put secret/app - < secrets/app.json > /dev/null && \
	echo "\n$(BLUE)[+] Add $(WHITE_BOLD)app $(BLUE)secrets to vault at $(WHITE_BOLD)/secret/app" && \
	docker exec -e VAULT_TOKEN=$$root_token -i hashicorp-vault vault kv put secret/log-system - < secrets/log-system.json > /dev/null && \
	echo "\n$(BLUE)[+] Add $(WHITE_BOLD)log-system $(BLUE)secrets to vault at $(WHITE_BOLD)/secret/log-system" && \
	docker exec -e VAULT_TOKEN=$$root_token hashicorp-vault vault policy write app-policy /bitnami/vault/config/app-policy.hcl > /dev/null && \
	echo "\n$(BLUE)[+] Uploaded policy: $(WHITE_BOLD)app-policy" && \
	docker exec -e VAULT_TOKEN=$$root_token hashicorp-vault vault policy write log-system-policy /bitnami/vault/config/log-system-policy.hcl > /dev/null && \
	echo "\n$(BLUE)[+] Uploaded policy: $(WHITE_BOLD)log-system-policy" && \
	app_token=$$(docker exec -e VAULT_TOKEN=$$root_token hashicorp-vault vault token create -policy="app-policy" -format=json | jq -r .auth.client_token) && \
	echo "\n$(BLUE)[+] Created token with access to $(WHITE_BOLD)/secret/app: $(WHITE_BOLD)$$app_token" && \
	logsystem_token=$$(docker exec -e VAULT_TOKEN=$$root_token hashicorp-vault vault token create -policy="log-system-policy" -format=json | jq -r .auth.client_token) && \
	echo "\n$(BLUE)[+] Created token with access to $(WHITE_BOLD)/secret/log-system: $(WHITE_BOLD)$$logsystem_token" && \
	echo "APP_TOKEN=$$app_token" >> .env && \
	echo "LOG_SYSTEM_TOKEN=$$logsystem_token" >> .env

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

	# PROXY-WAF SEGMENT ------------------------------------------------------->
	iptables -I DOCKER-USER -s 10.0.0.1 -d 10.0.1.1 -p tcp --dport 8000 -j ACCEPT

	# APP SEGMENT ------------------------------------------------------------->
	iptables -I DOCKER-USER -s 10.0.1.1 -d 10.0.1.2 -p tcp --dport 5432 -j ACCEPT
	iptables -I DOCKER-USER -s 10.0.1.1 -d 10.0.4.1 -p tcp --dport 8200 -j ACCEPT
	iptables -I DOCKER-USER -s 10.0.1.2 -d 10.0.4.1 -p tcp --dport 8200 -j ACCEPT

	# LOG-SYSTEM SEGMENT ------------------------------------------------------>
	iptables -I DOCKER-USER -s 10.0.2.3 -d 10.0.2.1 -p tcp --dport 9200 -j ACCEPT
	iptables -I DOCKER-USER -s 10.0.2.2 -d 10.0.2.1 -p tcp --dport 9200 -j ACCEPT
	iptables -I DOCKER-USER -p udp --dport 5000 -j ACCEPT
	iptables -I DOCKER-USER -p udp --sport 5000 -j ACCEPT
	iptables -I DOCKER-USER -s 10.0.1.0/24 -d 10.0.2.2 -p udp --dport 5000 -j ACCEPT
	iptables -I DOCKER-USER -s 10.0.2.1 -d 10.0.4.1 -p tcp --dport 8200 -j ACCEPT
	iptables -I DOCKER-USER -s 10.0.2.2 -d 10.0.4.1 -p tcp --dport 8200 -j ACCEPT
	iptables -I DOCKER-USER -s 10.0.2.3 -d 10.0.4.1 -p tcp --dport 8200 -j ACCEPT

	# MONITOR-SYSTEM SEGMENT -------------------------------------------------->
	iptables -I DOCKER-USER -s 10.0.3.2 -d 10.0.3.1 -p tcp --dport 9090 -j ACCEPT
	iptables -I DOCKER-USER -s 10.0.3.1 -d 10.0.3.3 -p tcp --dport 9093 -j ACCEPT
	iptables -I DOCKER-USER -s 10.0.3.1 -d 10.0.1.1 -p tcp --dport 8000 -j ACCEPT
	iptables -I DOCKER-USER -s 10.0.3.4 -d 10.0.1.2 -p tcp --dport 5432 -j ACCEPT
	iptables -I DOCKER-USER -s 10.0.3.1 -d 10.0.3.4 -p tcp --dport 9187 -j ACCEPT

	# VAULT SEGMENT ----------------------------------------------------------->
	iptables -I DOCKER-USER -s 10.0.0.1 -d 10.0.4.1 -p tcp --dport 8200 -j ACCEPT

	# SET IPTABLES IN STATEFUL MODE ------------------------------------------->
	iptables -I DOCKER-USER -m state --state ESTABLISHED,RELATED -j ACCEPT
