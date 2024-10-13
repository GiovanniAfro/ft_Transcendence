const LoginView = {
    render: function() {
        const app = document.getElementById('app');
        app.innerHTML = `
		<card>
        	<div class="main-body">
				<div class="row justify-content-md-center">
            		<div class="col-md-4 mb-3">
            		  <div class="card-opacity">
            		    <div class="card-body text-center">
        					<form id="login-form" class="form-signin">
        					    <img  src="/static/img/logo1.jpeg" class="rounded-circle" alt="" width="200" height="200" >
        					    <h1 class="h3 font-weight-normal" style="font-size: xx-large; font-weight: bold; color: #0e1422;">Please sign in</h1>
        					    <label class="sr-only">Username</label>
        					    <input type="text" id="username" class="form-control" placeholder="Username" required style="text-align:center;">
        					    <label for="inputPassword" class="sr-only">Password</label>
        					    <input type="password" id="password" class="form-control" placeholder="Password" required style="text-align:center;">
        					    <p></p>
        					    <button class="btn btn-lg btn-primary btn-block" type="submit">Login</button>
                                <p></p>
                                <p id="login-message" style="text-align:center; font-weight: bold; font-size: small; color: #0e1422;"></p>
        					</form>
						</div>
					</div>
				</div>
        	</div>
		</card>
        `;
        this.attachEventListeners();
    },

    attachEventListeners: function() {
        const form = document.getElementById('login-form');
        form.addEventListener('submit', this.handleLogin.bind(this));
    },

    handleLogin: async function(e) {
        e.preventDefault();
        const username = document.getElementById('username').value;
        const password = document.getElementById('password').value;
        const messageElement = document.getElementById('login-message');

        const result = await auth.login(username, password);

        if (result.success || result.requires_2fa_setup || result.requires_2fa) {
            messageElement.textContent = 'Login successful!';
            setTimeout(() => {
                window.location.hash = '#profile';
            }, 1000);
            //}
            // else if (result.requires_2fa) {
            //    // Salva l'username per l'uso successivo nella verifica 2FA
            //    this.username = username;
            //    this.show2FAForm();
            //} else if (result.requires_2fa_setup) {
            //    messageElement.textContent = 'Please set up 2FA for your account.';
            //    setTimeout(() => {
            //        window.location.hash = '#setup2fa';
            //    }, 1000);
        } else {
            messageElement.textContent = result.error;
        }
    },

    show2FAForm: function() {
        const app = document.getElementById('app');
        app.innerHTML = `
            <h2>Enter 2FA Code</h2>
            <p>Open Google Authenticator on your mobile device and enter the 6-digit code for this account:</p>
            <form id="2fa-form">
                <input type="text" id="2fa-code" placeholder="Enter 6-digit code" required>
                <button type="submit">Verify</button>
            </form>
            <p id="2fa-message"></p>
        `;
        const form = document.getElementById('2fa-form');
        form.addEventListener('submit', this.handle2FAVerification.bind(this));
    },

    handle2FAVerification: async function(event) {
        event.preventDefault();
        const token = document.getElementById('2fa-code').value;
        const username = this.username; // Usa l'username salvato
        console.log(`Verifying 2FA for user ${username} with token ${token}`);
        const result = await auth.verify2FA(username, token);
        const messageElement = document.getElementById('2fa-message');
        if (result.success) {
            messageElement.textContent = '2FA verification successful!';
            setTimeout(() => {
                window.location.hash = '#home';
            }, 1000);
        } else {
            messageElement.textContent = result.error || 'Verification failed';
        }
    },
};