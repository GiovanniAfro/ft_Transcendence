from rest_framework import viewsets, permissions
from .models import Game, Score, Tournament, User
from .serializers import GameSerializer, ScoreSerializer, TournamentSerializer, UserSerializer
from django.shortcuts import render
from django.contrib.auth.models import User
from django.contrib.auth.hashers import make_password
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
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
        if not username or not password:
            return JsonResponse({'error': 'Username and password are required'}, status=400)
        if User.objects.filter(username=username).exists():
            return JsonResponse({'error': 'Username is already taken'}, status=400)
        user = User.objects.create(username=username, password=make_password(password))
        return JsonResponse({'message': 'User registered successfully'}, status=201)
    return JsonResponse({'error': 'Invalid method'}, status=405)

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