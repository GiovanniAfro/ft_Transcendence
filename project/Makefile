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

.PHONY: all up down start stop clean fclean banner
.SILENT:

DATA_DIR := /data
DB_DIR := $(DATA_DIR)/db

# Rules ----------------------------------------------------------------------->

all: banner $(DB_DIR) up

$(DB_DIR):
	@if [ ! -d $(DB_DIR) ]; then \
		echo "Directory $(DB_DIR) does not exists. Creation..."; \
		mkdir -p $(DB_DIR); \
	fi

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

fclean: banner clean
	rm -rf /data
	docker system prune -a

banner:
	${info }

# ------------------------------------------------------------------------------
