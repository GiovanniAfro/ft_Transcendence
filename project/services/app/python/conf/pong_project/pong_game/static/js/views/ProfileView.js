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

                if (profileResponse.ok && statsResponse.ok) {
                    const profileData = await profileResponse.json();
                    this.profileData = profileData; // Assegna profileData come proprietà
                    const statsData = await statsResponse.json();

                    app.innerHTML = `
				  <div class="container">
    <div class="main-body">
          <!-- Breadcrumb -->

          <div class="row gutters-sm">
            <div class="col-md-4 mb-3 h-100">
              <div class="card-opacity">
                <div class="card-body">
                  <div class="d-flex flex-column align-items-center text-center">
                  <form id="profile-form">
                  <div class="d-flex flex-column align-items-center text-center">
                   <img id="avatar-preview" src="${profileData.avatar || "/static/img/default_avatar.png"}" alt="Admin" class="rounded-circle" width="150" height="150">
                    <div class="mt-3">
                      <div class="mb-3">
                        <label for="username" class="form-label"><h3 style="color: white"  >Username:</h3></label>
                        <input type="text" class="form-control" id="username" value="${profileData.username}">
                        <input type="file" id="avatar-input" style="display: none;" accept="image/*">
                        <div class="mb-3">
                            <label for="email" class="form-label"><h3 style="color: white"  >Email:</h3></label>
                            <input type="email" class="form-control" id="email" value="${profileData.email}">
                        </div>
                        <p></p>
                        <button class="btn btn-primary" id="change-avatar-btn">Change Avatar</button>
                        <button type="submit" class="btn btn-danger">Update Profile</button>
                      </div>
                    </div>
                  </div>
                  </form>
                  </div>
                </div>
              </div>
            </div>
            <div class="col-md-8">
			<div class="row gutters-sm">
                <div class="card-opacity" >
        	              <h3 style="font-size: xx-large; font-weight: bold; color: #0e1422; text-align:center;">Friends</h3>
        	              <ul id="friends-list">
        	              </ul>
                          <p></p>
			    	<div class="row w-100">
			    		<h3 class="mb-0" style="font-size: x-large; font-weight: medium; color: #0e1422;">Friend's Username:</h3>
			    		<p></p>
        	              	<div class="col-6 w-50">
        	              	    <input type="text" id="friend-username" class="form-control w-100" placeholder="Friend">
			    		</div>
			    		<div class="col-6 w-50">
        	              	    <button id="add-friend-btn" class="btn btn-danger">Add Friend</button>
        	              	</div>
			    	</div>
                    <p></p>
                </div>
			</div>
              <div class="row gutters-sm">
                  <div class="card-opacity">
                    <div class="card-body">
					<div class="row">
                      	<div class="p-3 col-6" style="color: #0e1422;">
                        	<h6 class="card-title">Games Played: ${statsData.games_played}</h6>
                      	</div>
                      	<div class="p-3 col-6" style="text-align:right;">
						  	<h6 class="card-title">Games Won: ${statsData.games_won_count}</h6>
                      	</div>
                      	<div class="p-3 col-6" style="color: #0e1422;">
                      	  <h6 class="card-title;">Total Score: ${statsData.total_score}</h6>
                      	</div>
					    <div class="p-3 col-6" style="text-align:right;">
                      	  <h6 class="card-title">Win Rate: ${statsData.win_rate}%</h6>
                      	</div>
						</div>
                    </div>
                  </div>
              </div>
            </div>
          </div>
        </div>
    </div>
<div class="container">
	<div class="row  text-align:center;" >
    <div class="card-opacity">
        <h3 style="font-size: xx-large; font-weight: bold; color: #0e1422; text-align:center;">Match History</h3>
        <div id="match-history"></div>
        </div>
    </div>
</div>
						`;
                    this.loadMatchHistory(1);
                    this.friendsResponse(1);
                    this.attachEventListeners();
                    //this.loadMatchHistory();
                } else {
                    app.innerHTML = '<h2 style="color:red; text-align:center;">Failed to load profile</h2>';
                }
            } catch (error) {
                console.error('Error:', error);
                app.innerHTML = '<h2>Error loading profile</h2>';
            }
        },
        friendsResponse: async function(page) {
            const token = localStorage.getItem('access_token');
            if (!token) {
                console.log('No token available for friends update');
                return; // Semplicemente esce senza reindirizzare
            }

            const result = await fetch(`/api/accounts/friends/status/?page=${page}`, { headers: { 'Authorization': `Bearer ${token}` } });
            const json = await result.json();
            console.log('json_Friends:', json);
            const friendsContainer = document.getElementById('friends-list');
            if (!friendsContainer)
            {
                console.log('Friends container not found');
                return;
            }
              const list = json.data.map(friend => `
			  <li>
			  	${friend.username}
			  	<span class="${friend.is_online ? 'online' : 'offline'}">
			  		(${friend.is_online ? 'Online' : 'Offline'})
			  	</span>
			  </li>
	          `).join('');

            friendsContainer.innerHTML = `
			${list}
            <p></p>
			<div class="d-flex justify-content-center gap-2">
				<button id="friends-prev-page" class="btn btn-primary" ${json.previous_page !== null ? '' : 'disabled'}>Previous</button>
				<div>Page ${json.actual_page}</div>
				<button id="friends-next-page" class="btn btn-primary" ${json.next_page !== null  ? '' : 'disabled'}>Next</button>
			</div>
		`;
            document.querySelector('#friends-prev-page').addEventListener('click', () => {
                if (json.previous_page !== null) {
                    this.friendsResponse(json.previous_page);
                }
            });
            document.querySelector('#friends-next-page').addEventListener('click', () => {
                if (json.next_page !== null) {
                    this.friendsResponse(json.next_page)
                }
            });
        },

        attachEventListeners: function() {
            const form = document.getElementById('profile-form');
            form.addEventListener('submit', this.handleProfileUpdate);

            const changeAvatarBtn = document.getElementById('change-avatar-btn');
            changeAvatarBtn.addEventListener('click', this.handleAvatarChange);

            const avatarInput = document.getElementById('avatar-input');
            avatarInput.addEventListener('change', this.handleAvatarUpload);

            const addFriendBtn = document.getElementById('add-friend-btn');
            addFriendBtn.addEventListener('click', () => this.handleAddFriend());
            setInterval(this.friendsResponse, 10000);

        },

        handleProfileUpdate: async function(e) {
            e.preventDefault();
            const username = document.getElementById('username').value;
            const email = document.getElementById('email').value;
            const updateData = { username, email };

            try {
                const response = await fetch('/api/accounts/me/', {
                    method: 'PATCH', // Cambiato da PUT a PATCH
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

        loadMatchHistory: async function(page) {
                const matchHistoryDiv = document.getElementById('match-history');
                try {
                    const response = await fetch(`/api/accounts/matches/?page=${page}`, {
                        headers: {
                            'Authorization': `Bearer ${localStorage.getItem('access_token')}`
                        }
                    });
                    if (response.ok) {
                        const output1 = await response.json();
                        const matches = output1.matches;
                        console.log('output1:', output1);
                        console.log('Matches:', matches);
                        const username = this.profileData.username;

                        if (matches.length === 0) {
                            matchHistoryDiv.innerHTML = '<p>No matches found.</p>';
                            return;
                        }

                        matchHistoryDiv.innerHTML = `

                    <table class="table table-primary">
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
                    <div class="gap-2 text-center">
						<button id="matches-prev-page" class="btn btn-primary" ${output1.matches_previous_page !== null ? '' : 'disabled'}>Previous</button>
						<span class="label label-primary">Page ${output1.matches_actual_page}</span>
						<button id="matches-next-page" class="btn btn-primary" ${output1.matches_next_page !== null  ? '' : 'disabled'}>Next</button>
					</div>
                    <p></p>
                `;
                document.querySelector('#matches-prev-page').addEventListener('click', () =>{0
                    if (output1.matches_previous_page !== null) {
                        this.loadMatchHistory(output1.matches_previous_page);
                    }
                });
             document.querySelector('#matches-next-page').addEventListener('click', () => {
                    if (output1.matches_next_page !== null){
                        this.loadMatchHistory(output1.matches_next_page)
                    }
                });
            } else {
                matchHistoryDiv.innerHTML = '<h4 style="color:yellow; text-align:center;">Failed to load match history, it seems you have 0 game played, GO TO PLAY THE GAMEEEEEEEE</p>';
            }
        } catch (error) {
            console.error('Error:', error);
            matchHistoryDiv.innerHTML = '<p>Error loading match history</p>';
        }
    },

    handleAddFriend: async function () {
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
                //alert('Friend added successfully');
                // Aggiorna la lista degli amici
                this.friendsResponse(1);
            } else {
                const errorData = await response.json();
                alert('Failed to add friend: ' + errorData.error);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('An error occurred while adding friend');
        }
    },

    loadOnlineFriends1: async function() {
        try {
            const response = await fetch('/api/accounts/friends/status/', {
                headers: {
                    'Authorization': `Bearer ${localStorage.getItem('access_token')}`
                }
            });
            if (response.ok) {
                const jsonData = await response.json();
                const htmlFriendsList = document.getElementById('friends-list');
                console.log('Friends:', jsonData);
                if (htmlFriendsList) {  // Aggiungi questo controllo
                    htmlFriendsList.innerHTML = jsonData.friends.map(friend => `
                        <li>
                            ${friend.username}
                            <span class="${friend.is_online ? 'online' : 'offline'}">
                                (${friend.is_online ? 'Online' : 'Offline'})
                            </span>
                        </li>
                    `).join('');
                }
            }
        } catch (error) {
            console.error('Error loading friends:', error);
        }
    },
};
