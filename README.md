# ft-transcendence

![ft-transcendence](https://github.com/kichkiro/42_cursus/blob/assets/banner_ft-transcendence.jpg?raw=true)

<i>
  <p>
    This project is about doing something you’ve never done before.
  </p>
  <p>
    Remind yourself the beginning of your journey in computer science.
  </p>
  <p>
    Look at you now. Time to shine!
  </p>
</i>

#### <i>[subject](_subject/en.subject.pdf) v.15</i>

## 📌 -  Dependencies (for Ubuntu 24.04LTS)

- docker
``` sh
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

- make
``` sh
sudo apt install make
```

## 🛠️ - Usage
```
git clone https://github.com/kichkiro/ft_transcendence.git
cd ft_transcendence/project
```
- make up: 
  - creates the /data directory and related subdirectories if they do not exist (for local volumes) 
  - create images 
  - start containers
- make down: 
  - stop containers
  - remove containers
  - remove networks
- make stop: 
  - stop containers
- make start: 
  - start containers
- make clean:
  - remove all container
  - remove all images
  - remove all volums (not local)
  - remove all networks
- make re:
  - make clean
  - make up
- make fclean:
  - make clean
  - remove all build cache
  - remove locale volumes (/data/)

## 📚 - References
- ELK
  - [The Complete Guide to the ELK Stack](https://logz.io/learn/complete-guide-elk-stack/#what-elk-stack)
  - [Docker ELK](https://github.com/deviantony/docker-elk)


## ⚖️ - License
See [LICENSE](https://github.com/GiovanniAfro/ft_transcendence-/blob/master/LICENSE)

<br>

Work in Progress ...
