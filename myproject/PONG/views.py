from rest_framework import viewsets, permissions
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
        if username and password:
            user = User.objects.create_user(username=username, password=password)
            UserProfile.objects.create(user=user)  # Crea automaticamente un UserProfile
            return JsonResponse({"message": "Utente registrato con successo"}, status=201)
        else:
            return JsonResponse({"error": "Manca username o password"}, status=400)
    return JsonResponse({"error": "Metodo non supportato"}, status=405)

def login(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        username = data.get('username')
        password = data.get('password')
        user = authenticate(username=username, password=password)
        if user is not None:
            # Puoi implementare la logica di generazione e restituzione del JWT qui
            return JsonResponse({'message': 'Login successful'}, status=200)
        else:
            return JsonResponse({'error': 'Invalid credentials'}, status=400)
    return JsonResponse({'error': 'Invalid method'}, status=405)
