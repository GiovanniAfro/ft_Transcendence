from django.db import models
from django.contrib.auth.models import User

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    alias = models.CharField(max_length=100, blank=True)

    def __str__(self):
        return self.user.username
    
class Tournament(models.Model):
    name = models.CharField(max_length=255)
    start_date = models.DateTimeField()
    is_active = models.BooleanField(default=True)
    players = models.ManyToManyField(User, related_name='tournaments')

    def determine_winner(self):
        # Logica per determinare il vincitore del torneo
        pass

class Game(models.Model):
    player1 = models.ForeignKey(User, related_name='games_player1', on_delete=models.CASCADE)
    player2 = models.ForeignKey(User, related_name='games_player2', on_delete=models.CASCADE)
    score_player1 = models.IntegerField(default=0)
    score_player2 = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class Score(models.Model):
    player = models.ForeignKey(User, on_delete=models.CASCADE)
    game = models.ForeignKey(Game, on_delete=models.CASCADE)
    score = models.IntegerField(default=0)
    date = models.DateTimeField(auto_now_add=True)