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

.PHONY: all up down start stop clean re fclean setup_firewall setup_elasticsearch banner
.SILENT:

DATA_DIR := /data
DB_DIR := $(DATA_DIR)/db

# Rules ----------------------------------------------------------------------->

all: banner up setup_firewall

$(DB_DIR):
	@if [ ! -d $(DB_DIR) ]; then \
		echo "Directory $(DB_DIR) does not exists. Creation..."; \
		mkdir -p $(DB_DIR); \
	fi

up: banner $(DB_DIR)
	docker compose -f ./srcs/docker-compose.yml up -d

down: banner
	docker compose -f ./srcs/docker-compose.yml down

start: banner
	docker compose -f ./srcs/docker-compose.yml start

stop: banner
	docker compose -f ./srcs/docker-compose.yml stop

clean: banner
	echo "Removing all containers..."
	-docker rm -f $$(docker ps -qa)
	echo "\nRemoving all images..."
	-docker rmi -f $$(docker images -qa)
	echo "\nRemoving all volumes..."
	-docker volume rm $$(docker volume ls -q)
	echo "\nRemoving network..."
	-docker network rm $$(docker network ls -q) 2>/dev/null

re: banner clean up setup_firewall

fclean: banner clean
	rm -rf /data
	docker system prune -a

setup_firewall:
	iptables -I DOCKER-ISOLATION-STAGE-2 1 -s 10.0.0.0/24 -d 10.0.1.2 -p udp --dport 50000 -j ACCEPT

setup_elasticsearch:
	docker exec elasticsearch /tmp/set_users.sh
	docker exec elasticsearch rm /tmp/set_users.sh
	docker exec elasticsearch rm /tmp/lib.sh
	docker exec elasticsearch rm /tmp/logstash_writer.json

banner:
	${info }
