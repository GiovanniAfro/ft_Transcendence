const HomeView = {
    render: function() {
        const app = document.getElementById('app');
        app.innerHTML = `
        <card>	
        	<div class="main-body">
				<div class="row justify-content-md-center">
            		<div class="col-md-4 mb-3">
            		  <div class="card">
            		    <div class="card-body">
                        <h1 class="h3 mb-3 font-weight-normal" style="text-align:center;">
                        Welcome to Pong Game! Proceed with registration to play.
                        </h1>
                        </div>
                      </div>
                    </div>
                </div>
            </div>
        </card>
        `;
    }
};