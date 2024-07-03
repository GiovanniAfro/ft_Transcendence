from rest_framework import viewsets, permissions
from rest_framework_simplejwt.tokens import AccessToken
from .models import Game, Score, Tournament, UserProfile
from .serializers import GameSerializer, ScoreSerializer, TournamentSerializer, UserSerializer
from django.shortcuts import render
from django.contrib.auth.models import User
from django.contrib.auth.hashers import make_password
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.http import HttpResponse
from django.contrib.auth import authenticate
import json

def home(request):
    return render(request, 'index.html')

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

class TournamentViewSet(viewsets.ModelViewSet):
    queryset = Tournament.objects.all()
    serializer_class = TournamentSerializer

class GameViewSet(viewsets.ModelViewSet):
    queryset = Game.objects.all()
    serializer_class = GameSerializer
    permission_classes = [permissions.IsAuthenticated]

class ScoreViewSet(viewsets.ModelViewSet):
    queryset = Score.objects.all()
    serializer_class = ScoreSerializer
    permission_classes = [permissions.IsAuthenticated]

def register(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        username = data.get('username')
        password = data.get('password')

        # Verifica se il nome utente esiste già
        if User.objects.filter(username=username).exists():
            return JsonResponse({'error': 'Il nome utente è già in uso'}, status=400)

        # Se il nome utente non è in uso, crea il nuovo utente
        user = User.objects.create_user(username=username, password=password)
        UserProfile.objects.create(user=user)  # Crea automaticamente un UserProfile
        return JsonResponse({'message': 'Utente registrato con successo'}, status=201)
    
    return JsonResponse({'error': 'Richiesta non valida'}, status=400)

def login(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        username = data.get('username')
        password = data.get('password')
        user = authenticate(username=username, password=password)
        if user is not None:
            token = AccessToken.for_user(user)
            return JsonResponse({'token': str(token)}, status=200)
        else:
            return JsonResponse({'error': 'Invalid credentials'}, status=400)
    return JsonResponse({'error': 'Invalid method'}, status=405)