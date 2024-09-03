# TODO

## Modules

TOTAL
	Major:8
	Minor:3
DOUBTFUL
	Major:1
	Minor:2

### Web
	[*] Major module: Use a Framework as backend.
	[?] Minor module: Use a front-end framework or toolkit.
	[*] Minor module: Use a database for the backend.
	[*] Major module: Store the score of a tournament in the Blockchain.
### User Management
	[*] Major module: Standard user management, authentication, users across tournaments.
	[*] Major module: Implementing a remote authentication.
### Gameplay and user experience
	[?] Major module: Remote players
	[] Major module: Multiplayers (more than 2 in the same game).
	[?] Minor module: Game Customization Options.
	[*] Major module: Live chat.
### Cybersecurity
	[*] Major module: Implement WAF/ModSecurity with Hardened Configuration and HashiCorp Vault for Secrets Management.
	[] Minor module: GDPR Compliance Options with User Anonymization, Local Data Management, and Account Deletion.
	[*] Major module: Implement Two-Factor Authentication (2FA) and JWT.
### Devops
	[*] Major module: Infrastructure Setup for Log Management.
	[*] Minor module: Monitoring system.
	[] Major module: Designing the Backend as Microservices.
### Graphics
	[] Major module: Use of advanced 3D techniques.
### Accessibility
	[] Minor module: Support on all devices.
	[] Minor module: Expanding Browser Compatibility.
	[*] Minor module: Multiple language supports.
	[] Minor module: Server-Side Rendering (SSR) Integration.
### Server-Side Pong
	[] Major module: Replacing Basic Pong with Server-Side Pong and Implementing an API.
	[] Major module: Enabling Pong Gameplay via CLI against Web Users with API Integration.







# kichkiro todo

## App
	[ ] Configurare Django per utilizzare un server WSGI e disabilitare il webserver di sviluppo

## Proxy-Waf
	[ ] Configurare nginx in modalita solo TLS

## Monitor System

	[v] Settare le regole di iptables
	[v] Aggiungere target in prometheus.yml
	[v] Impostare password grafana
	[v] Impostare data source grafana
	[ ] Settare exporter per nginx, django e hashicorpvault
	[ ] Settare alertmanger
	[ ] Settare autenticazione grafana

## Vault PROD

	- docker exec hashicorp-vault vault operator init
	- docker exec hashicorp-vault vault operator unseal <key 1>
	- docker exec hashicorp-vault vault operator unseal <key 2>
	- docker exec hashicorp-vault vault operator unseal <key 3>	
	- docker exec hashicorp-vault vault login <root key>
	- docker exec hashicorp-vault vault secrets enable -path=secret kv
	- docker exec hashicorp-vault vault kv put secret/mysecret username="example_user" password="example_password"
