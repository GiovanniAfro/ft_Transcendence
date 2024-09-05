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

--------------------------------------------------------------------------------

# kichkiro

[ ] Nginx
	[ ] Usare immagine non-root
	[ ] Prendere segreti da hashicorp-vault
	[ ] Configurare servizio
		[ ] Settare HTTPS
	[ ] Collegare al log-system
	[ ] Impostare exporter e creare dashboard
	[ ] Configurare nginx in modalita solo TLS

[ ] Hashicorp-Vault 
	[ ] Usare immagine non-root
	[ ] Prendere segreti da hashicorp-vault
	[ ] Configurare servizio
		[ ] Settare HTTPS
		[ ] 
	[ ] Collegare al log-system
	[ ] Impostare exporter e creare dashboard

[ ] Django
	[ ] Usare immagine non-root
	[ ] Prendere segreti da hashicorp-vault
	[ ] Configurare servizio
		[ ] Hashare password db
		[ ] Settare HTTPS
		[ ] 
	[ ] Collegare al log-system
	[ ] Impostare exporter e creare dashboard
	[ ] Utilizzare un server WSGI e disabilitare il webserver di sviluppo

[ ] Postgres
	[v] Usare immagine non-root
	[v] Prendere segreti da hashicorp-vault
	[ ] Configurare servizio
		[ ] Aggiungere 10.0.1.1 come client (add_remote_host.sh)
	[ ] Collegare al log-system
	[ ] Impostare exporter e creare dashboard

[ ] Elasticsearch
	[v] Usare immagine non-root
	[v] Prendere segreti da hashicorp-vault
	[ ] Configurare servizio
		[v] Settare password login
		[ ] Settare HTTPS e TLS

[ ] Logstash
	[v] Usare immagine non-root
	[v] Prendere segreti da hashicorp-vault
	[ ] Configurare servizio
		[ ] 

[ ] Kibana
	[v] Usare immagine non-root
	[v] Prendere segreti da hashicorp-vault
	[ ] Configurare servizio
		[ ] Settare HTTPS e TLS
		[ ] Settare dataview di defualt per pattern log*

[ ] Prometheus
	[ ] Usare immagine non-root
	[ ] Prendere segreti da hashicorp-vault
	[ ] Configurare servizio
		[v] Aggiungere target in prometheus.yml
		[ ] Settare alertmanger
		[ ] Settare HTTPS

[ ] Grafana
	[ ] Usare immagine non-root
	[ ] Prendere segreti da hashicorp-vault
	[ ] Configurare servizio
		[v] Impostare password grafana
		[v] Impostare data source grafana
		[ ] Settare autenticazione grafana
		[ ] Settare HTTPS
