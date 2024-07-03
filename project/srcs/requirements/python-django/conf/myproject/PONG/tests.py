from django.test import TestCase
from django.contrib.auth.models import User
from rest_framework.test import APIClient, APITestCase
from rest_framework import status
from .models import Game, UserProfile
from django.urls import reverse


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

class AuthenticationTests(APITestCase):
    def test_registration(self):
        """
        Assicurati che la registrazione funzioni correttamente.
        """
        url = reverse('register')
        data = {'username': 'newuser', 'password': 'newpassword123'}
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_login(self):
        self.test_registration()  # Prima registra un utente
        url = reverse('login')
        data = {'username': 'newuser', 'password': 'newpassword123'}
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue('token' in response.json())  # Usa response.json() invece di response.data

class UserModelTest(TestCase):
    def test_user_creation(self):
        user = User.objects.create_user('testuser', 'test@example.com', 'testpassword')
        self.assertIsInstance(user, User)
        self.assertFalse(user.is_staff)

    def test_user_profile_creation(self):
        user = User.objects.create_user('testuser', 'test@example.com', 'testpassword')
        user_profile = UserProfile.objects.create(user=user, alias='testuser')
        self.assertEqual(user_profile.alias, 'testuser')