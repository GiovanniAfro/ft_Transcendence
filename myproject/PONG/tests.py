from django.test import TestCase
from django.contrib.auth.models import User
from rest_framework.test import APIClient
from rest_framework import status
from .models import Game

class GameAPITestCase(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(username='testuser', password='testpassword')
        self.client.force_authenticate(user=self.user)
        self.game = Game.objects.create(player1=self.user, player2=self.user)

    def test_get_games(self):
        response = self.client.get('/api/games/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_create_game(self):
        data = {
            'player1': self.user.id,
            'player2': self.user.id,
            'score_player1': 0,
            'score_player2': 0
        }
        response = self.client.post('/api/games/', data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
