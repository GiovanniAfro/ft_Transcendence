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

all: banner up

up: banner
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

re: banner clean up setup_elasticsearch

fclean: banner clean
	rm -rf /data
	docker system prune -a

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

banner:
	${info }
