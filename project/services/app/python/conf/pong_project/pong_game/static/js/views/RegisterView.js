const RegisterView = {
    render: function() {
        const app = document.getElementById('app');
        app.innerHTML = `
		<card>	
        	<div class="main-body">
				<div class="row justify-content-md-center">
            		<div class="col-md-4 mb-3">
            		  <div class="card">
            		    <div class="card-body">
        					<form id="register-form">
        			    	<h1 class="h3 mb-3 font-weight-normal" style="text-align:center;">Please Register Yourself</h1>
							<h1 class="h3 mb-3 font-weight-normal" style="text-align:center;">NO FAKE DATA OR GTFO</h1>
							<div class="row">
								<div class="col-sm">
									<input type="text" id="username" class="form-control" placeholder="Username" required style="text-align:center;">
									<p></p>
									<input type="email" id="email" class="form-control" placeholder="Email" required style="text-align:center;">
								</div>
								<div class="col-sm">
        			    			<input type="password" id="password" class="form-control" placeholder="Password" required style="text-align:center;">
									<p></p>
									<input type="password" id="confirm-password" class="form-control" placeholder="Confirm Password" required style="text-align:center;">
								</div>
							</div>
							<div class="text-center">
        			    		<p></p>
        			    		<button class="btn btn-lg btn-primary btn-block" type="submit">Register</button>
								<p></p>
								<img  src="/static/img/logo1.jpeg" class="rounded-circle" alt="" width="200" height="200" >
							</div>
        					</form>
						</div>
					</div>
				</div>
        	</div>
		</card>
        <p id="register-message"></p>
        `;
        this.attachEventListeners();
    },

    attachEventListeners: function() {
        const form = document.getElementById('register-form');
        form.addEventListener('submit', this.handleRegister);
    },

    handleRegister: async function(e) {
        e.preventDefault();
        const username = document.getElementById('username').value;
        const email = document.getElementById('email').value;
        const password = document.getElementById('password').value;
        const confirmPassword = document.getElementById('confirm-password').value;
        const messageElement = document.getElementById('register-message');
    
        // Controllo lato client
        if (password !== confirmPassword) {
            messageElement.textContent = 'Le password non corrispondono.';
            return;
        }
    
        try {
            const response = await fetch('/api/accounts/register/', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRFToken': getCookie('csrftoken')
                },
                credentials: 'include',
                body: JSON.stringify({ username, email, password, confirm_password: confirmPassword }),
            });
    
            console.log('Response status:', response.status);
            const data = await response.json();
            console.log('Response data:', data);
    
            if (response.ok) {
                messageElement.textContent = 'Registrazione avvenuta con successo! Effettua il login.';
                setTimeout(() => {
                    window.location.hash = '#login';
                }, 2000);
            } else {
                messageElement.textContent = `Registrazione fallita: ${data.message || JSON.stringify(data)}`;
            }
        } catch (error) {
            console.error('Error:', error);
            messageElement.textContent = 'Si è verificato un errore. Riprova più tardi.';
        }
    }
};

// Funzione per ottenere il valore del cookie CSRF
function getCookie(name) {
    let cookieValue = null;
    if (document.cookie && document.cookie !== '') {
        const cookies = document.cookie.split(';');
        for (let i = 0; i < cookies.length; i++) {
            const cookie = cookies[i].trim();
            if (cookie.substring(0, name.length + 1) === (name + '=')) {
                cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                break;
            }
        }
    }
    return cookieValue;
}
