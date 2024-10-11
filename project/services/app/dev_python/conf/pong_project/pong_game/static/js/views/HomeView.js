const HomeView = {
    render: function() {
        const app = document.getElementById('app');
        app.innerHTML = `	
        	<div class="main-body">
				<div class="row justify-content-md-center">
            		<div class="col-md-4 mb-3">
            		  <div class="box-light" style="backdrop-filter: blur(15px); padding: 20px; border-radius: 8px;">
            		    <div class="home-title">
                        <h1 class="h3 font-weight-normal" style="text-align:center;">
                          <span style="font-size: xx-large; font-weight: bold; color: #0e1422;">Welcome to Pong Game!</span><br>
                          <span style="font-size: medium; font-weight: normal; color: #0e1422;">Proceed with registration to play.</span>
                        </h1>
                        </div>
                      </div>
                    </div>
                </div>
            </div>
        `;
    }
};

