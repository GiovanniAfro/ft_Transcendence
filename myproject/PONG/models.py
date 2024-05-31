from django.db import models
from django.contrib.auth.models import User
import random

class Tournament(models.Model):
    name = models.CharField(max_length=255)
    start_date = models.DateTimeField()
    is_active = models.BooleanField(default=True)
    players = models.ManyToManyField(User, related_name='tournaments')

    def create_matches(self):
        players = list(self.players.all())
        random.shuffle(players)  # Mescola i giocatori per randomizzare gli incontri
        self.matches.all().delete()  # Elimina gli incontri precedenti se il metodo viene richiamato
        # Crea incontri appaiando i giocatori
        for i in range(0, len(players), 2):
            if i+1 < len(players):
                Match.objects.create(
                    tournament=self,
                    player1=players[i],
                    player2=players[i+1]
                )

    def determine_winner(self):
        # Controlla tutti gli incontri del torneo per determinare se c'è un vincitore
        if self.matches.filter(winner__isnull=True).exists():
            return None  # Non tutti gli incontri sono stati conclusi
        winner_counts = self.matches.values('winner').annotate(total_wins=models.Count('winner')).order_by('-total_wins')
        if winner_counts:
            winner_id = winner_counts[0]['winner']
            return User.objects.get(id=winner_id) if winner_id else None
        return None

    def __str__(self):
        return self.name

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    alias = models.CharField(max_length=100, blank=True)

    def __str__(self):
        return self.user.username    
    
class Match(models.Model):
    tournament = models.ForeignKey(Tournament, related_name='matches', on_delete=models.CASCADE)
    player1 = models.ForeignKey(User, related_name='matches_player1', on_delete=models.CASCADE)
    player2 = models.ForeignKey(User, related_name='matches_player2', on_delete=models.CASCADE)
    winner = models.ForeignKey(User, related_name='won_matches', null=True, blank=True, on_delete=models.SET_NULL)

    def set_winner(self, winner):
        self.winner = winner
        self.save()
        self.tournament.determine_winner()

    def __str__(self):
        return f"{self.player1} vs {self.player2}"

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