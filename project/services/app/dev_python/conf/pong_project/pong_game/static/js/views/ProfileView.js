const ProfileView = {
    render: async function() {
        const token = localStorage.getItem('access_token');
        if (!token) {
            window.location.hash = '#login';
            return;
        }
        const app = document.getElementById('app');
        app.innerHTML = '<h2>Loading profile...</h2>';

        try {
            const profileResponse = await fetch('/api/accounts/me/', {
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            });
            const statsResponse = await fetch('/api/user/stats/', {
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            });
            const friendsResponse = await fetch('/api/friends/', {
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            });

            if (profileResponse.ok && statsResponse.ok && friendsResponse.ok) {
                const profileData = await profileResponse.json();
                this.profileData = profileData; // Assegna profileData come proprietà
                const statsData = await statsResponse.json();
                const friendsData = await friendsResponse.json();
                
                app.innerHTML = `
				  <div class="container">
    <div class="main-body">
          <!-- Breadcrumb -->

          <div class="row gutters-sm">
            <div class="col-md-4 mb-3">
              <div class="card">
                <div class="card-body">
                  <div class="d-flex flex-column align-items-center text-center">
                  <form id="profile-form">
                  <div class="d-flex flex-column align-items-center text-center">
                    <img src="${profileData.avatar || "/static/img/default_avatar.png"}" alt="Admin" class="rounded-circle" width="150" height="150">
                    <div class="mt-3">
                      <div class="mb-3">
                        <label for="username" class="form-label">Username:</label>
                        <input type="text" class="form-control" id="username" value="${profileData.username}">
                        <input type="file" id="avatar-input" style="display: none;" accept="image/*">
                        <div class="mb-3">
                            <label for="email" class="form-label">Email:</label>
                            <input type="email" class="form-control" id="email" value="${profileData.email}">
                        </div>
                        <p></p>
                        <button class="btn btn-primary" id="change-avatar-btn">Change Avatar</button>
                        <button type="submit" class="btn btn-outline-primary">Update Profile</button>
                      </div>
                    </div>
                  </div>
                  </form>
                  </div>
                </div>
              </div>
              <div class="card mt-3">
                <ul class="list-group list-group-flush">
                  <li class="list-group-item d-flex justify-content-between align-items-center flex-wrap">
                    <h6 class="mb-0"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-globe mr-2 icon-inline"><circle cx="12" cy="12" r="10"></circle><line x1="2" y1="12" x2="22" y2="12"></line><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path></svg>boh</h6>
                    <span class="text-secondary">Roba da aggiungere volendo, i match o lista amici</span>
                  </li>
                </ul>
              </div>
            </div>
            <div class="col-md-8">
              <div class="card mb-3">
                <div class="card-body">
                  <div class="row">
                    <div class="col-sm-3">
                      <h6 class="mb-0">qua match/editable/lista amici</h6>
                    </div>
                    <div class="col-sm-9 text-secondary">
                      username
                    </div>
                  </div>
                  <hr>
                  <div class="row">
                    <div class="col-sm-3">
                      <h6 class="mb-0">Email</h6>
                    </div>
                    <div class="col-sm-9 text-secondary">
                      email editable
                    </div>
                  </div>
                  <hr>
                  <div class="row">
                    <div class="col-sm-3">
                      <h6 class="mb-0">altra roba</h6>
                    </div>
                    <div class="col-sm-9 text-secondary">
                     boh
                    </div>
                  </div>
                  <hr>
                  <div class="row">
                    <div class="col-sm-12">
                      <a class="btn btn-info " target="__blank" href="">btn edit o pagine successive o boh lista di amici etc...</a>
                    </div>
                  </div>
                </div>
              </div>

              <div class="row gutters-sm">
                <div class="col-sm-6 mb-3">
                  <div class="card h-100">
                    <div class="card-body">
                      	<h6 class="d-flex align-items-center mb-3"><i class="material-icons text-info mr-2">Stats</i></h6>
                      	<div class="card p-3">
                        	<h5 class="card-title">Games Played:</h5>
                        	<h5 class="card-text">${statsData.games_played}</h5>
                      	</div>
                      	<div class="card p-3" style="text-align:right;">
						  	<h5 class="card-title">Games Won:</h5>
                        	<h5 class="card-text">${statsData.games_won_count}</h5>
                      	</div>
                      	<div class="card p-3">
                      	  <h5 class="card-title">Total Score:</h5>
                      	  <h5 class="card-text">${statsData.total_score}</h5>
                      	</div>
					    <div class="card p-3" style="text-align:right;">
                      	  <h5 class="card-title">Win Rate:</h5>
                      	  <h5 class="card-text">${statsData.win_rate}%</h5>
                      	</div>
                      	<small>Win Rate:</small>
                      	<div class="progress" style="height: 20px">
                       		<div class="progress-bar bg-primary" role="progressbar" style="width:${statsData.win_rate}" " aria-valuemin="0" aria-valuemax="100">${statsData.win_rate}%</div>
					  	</div>
                    </div>
                  </div>
                </div>
                <div class="col-sm-6 mb-3">
                  <div class="card h-100">
                    <div class="card-body">
                    <div class="col-md-6">
                                <h3>Friends</h3>
                                <ul id="friends-list">
                                    ${friendsData.map(friend => `
                                        <li>
                                            ${friend.username} 
                                            <span class="${friend.is_online ? 'online' : 'offline'}">
                                                (${friend.is_online ? 'Online' : 'Offline'})
                                            </span>
                                        </li>
                                    `).join('')}
                                </ul>
                                <div class="mt-3">
                                    <input type="text" id="friend-username" placeholder="Friend's username">
                                    <button id="add-friend-btn" class="btn btn-secondary">Add Friend</button>
                                </div>
                            </div>
                    </div>
                  </div>
                </div>
              </div>



            </div>
          </div>

        </div>
    </div>
                        <div class="row mt-4">
                            <div class="col">
                                <h3>Match History</h3>
                                <div id="match-history"></div>
                            </div>
                        </div>	
                `;
                this.attachEventListeners();
                this.loadMatchHistory();
            } else {
                app.innerHTML = '<h2>Failed to load profile</h2>';
            }
        } catch (error) {
            console.error('Error:', error);
            app.innerHTML = '<h2>Error loading profile</h2>';
        }
    },

    attachEventListeners: function() {
        const form = document.getElementById('profile-form');
        form.addEventListener('submit', this.handleProfileUpdate);
    
        const changeAvatarBtn = document.getElementById('change-avatar-btn');
        changeAvatarBtn.addEventListener('click', this.handleAvatarChange);
    
        const avatarInput = document.getElementById('avatar-input');
        avatarInput.addEventListener('change', this.handleAvatarUpload);

        const addFriendBtn = document.getElementById('add-friend-btn');
        addFriendBtn.addEventListener('click', this.handleAddFriend);
    },

    handleProfileUpdate: async function(e) {
        e.preventDefault();
        const username = document.getElementById('username').value;
        const email = document.getElementById('email').value;
        const updateData = { username, email };

        try {
            const response = await fetch('/api/accounts/me/', {
                method: 'PATCH',  // Cambiato da PUT a PATCH
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${localStorage.getItem('access_token')}`
                },
                body: JSON.stringify(updateData)
            });

            if (response.ok) {
                const responseData = await response.json();
                alert('Profile updated successfully');
                document.getElementById('username').value = responseData.username;
                document.getElementById('email').value = responseData.email || '';
            } else {
                const errorData = await response.json();
                alert('Failed to update profile: ' + JSON.stringify(errorData));
            }
        } catch (error) {
            console.error('Error:', error);
            alert('An error occurred while updating profile');
        }
    },

    handleAvatarChange: function() {
        console.log('Avatar change button clicked');
        document.getElementById('avatar-input').click();
    },
    
    handleAvatarUpload: async function(e) {
        console.log('Avatar file selected', e.target.files[0]);
        const file = e.target.files[0];
        if (file) {
            const formData = new FormData();
            formData.append('avatar', file);
    
            try {
                const response = await fetch('/api/accounts/me/', {
                    method: 'PATCH',
                    headers: {
                        'Authorization': `Bearer ${localStorage.getItem('access_token')}`
                    },
                    body: formData
                });
    
                if (response.ok) {
                    const data = await response.json();
                    document.getElementById('avatar-preview').src = data.avatar;
                    alert('Avatar updated successfully');
                } else {
                    const errorData = await response.json();
                    alert('Failed to update avatar: ' + JSON.stringify(errorData));
                }
            } catch (error) {
                console.error('Error:', error);
                alert('An error occurred while updating avatar');
            }
        }
    },

    loadMatchHistory: async function() {
        const matchHistoryDiv = document.getElementById('match-history');
        try {
            const response = await fetch('/api/accounts/matches/', {
                headers: {
                    'Authorization': `Bearer ${localStorage.getItem('access_token')}`
                }
            });
            if (response.ok) {
                const matches = await response.json();
                console.log('Matches:', matches);
                const username = this.profileData.username;
    
                if (matches.length === 0) {
                    matchHistoryDiv.innerHTML = '<p>No matches found.</p>';
                    return;
                }
    
                matchHistoryDiv.innerHTML = `
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Opponent</th>
                                <th>Result</th>
                                <th>Score</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${matches.map(match => {
                                const opponent = match.player1_username === username
                                    ? (match.player2_username || match.player2_alias || 'Unknown')
                                    : (match.player1_username || 'Unknown');
                                const result = match.winner_username === username ? 'Win' : 'Loss';
                                const score = `${match.score_player1} - ${match.score_player2}`;
                                return `
                                    <tr>
                                        <td>${new Date(match.date_played).toLocaleString()}</td>
                                        <td>${opponent}</td>
                                        <td>${result}</td>
                                        <td>${score}</td>
                                    </tr>
                                `;
                            }).join('')}
                        </tbody>
                    </table>
                `;
            } else {
                matchHistoryDiv.innerHTML = '<p>Failed to load match history</p>';
            }
        } catch (error) {
            console.error('Error:', error);
            matchHistoryDiv.innerHTML = '<p>Error loading match history</p>';
        }
    },

    handleAddFriend: async function() {
        const friendUsername = document.getElementById('friend-username').value;
        if (!friendUsername) {
            alert('Please enter a friend\'s username');
            return;
        }

        try {
            const response = await fetch('/api/friends/add/', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${localStorage.getItem('access_token')}`
                },
                body: JSON.stringify({ friend_username: friendUsername })
            });

            if (response.ok) {
                alert('Friend added successfully');
                // Aggiorna la lista degli amici
                const friendsList = document.getElementById('friends-list');
                friendsList.innerHTML += `<li>${friendUsername}</li>`;
                document.getElementById('friend-username').value = '';
            } else {
                const errorData = await response.json();
                alert('Failed to add friend: ' + errorData.error);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('An error occurred while adding friend');
        }
    }
};
