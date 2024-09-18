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

[v] Vault 
	[v] Usare immagine non-root
	[v] Configurare servizio
		[v] Creare root CA e intermediate CA
		[v] Creare certificati per i container
		[v] Importare segreti
		[v] Settare TLS mode
	[v] Collegare al log-system
	[v] Esportare metriche e creare dashboard

[ ] Django
	[v] Usare immagine non-root
	[v] Prendere segreti da vault
	[ ] Configurare servizio
		[v] Hashare password postgresql
		[ ] Installare e configurare gunicorn
		[ ] Abilitare TLS tra postgres e django
		[ ] Esporre tramite Nginx
	[ ] Collegare al log-system
	[ ] Impostare exporter e creare dashboard tramite TLS

[ ] Postgresql
	[v] Usare immagine non-root
	[v] Prendere segreti da vault
	[ ] Configurare servizio
		[ ] Aggiungere 10.0.1.1 come client (add_remote_host.sh)
	[v] Collegare al log-system
	[v] Impostare exporter e creare dashboard

[ ] Elasticsearch
	[v] Usare immagine non-root
	[v] Prendere segreti da vault
	[v] Configurare servizio
		[v] Settare password login
		[ ] Settare autorizazione TLS da webclient

[v] Logstash
	[v] Usare immagine non-root
	[v] Prendere segreti da vault
	[v] Configurare servizio
		[v] ssl output elasticsearch

[ ] Kibana
	[v] Usare immagine non-root
	[v] Prendere segreti da vault
	[v] Configurare servizio
		[v] Settare HTTPS e TLS
		[v] Settare dataview di defualt per pattern log*
		[ ] Settare autorizazione TLS da webclient

[ ] Prometheus
	[v] Usare immagine non-root
	[v] Prendere segreti da vault
	[ ] Configurare servizio
		[v] Aggiungere target in prometheus.yml
		[v] Settare alert
		[v] Settare autorizazione TLS da webclient
		[v] Settare HTTPS
		[v] Settare data retention
		[ ] Hashare credenziali in web.yml

[v] Grafana
	[v] Usare immagine non-root
	[v] Prendere segreti da vault
	[v] Configurare servizio
		[v] Impostare data source grafana
		[v] Settare autenticazione grafana
		[v] Settare HTTPS
	
[ ] Nginx
	[ ] Usare immagine non-root
	[ ] Prendere segreti da vault
	[ ] Configurare servizio
		[ ] Settare HTTPS
	[ ] Collegare al log-system
	[ ] Impostare exporter e creare dashboard
	[ ] Configurare nginx in modalita solo TLS

