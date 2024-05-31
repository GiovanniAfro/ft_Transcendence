from rest_framework import viewsets, permissions
from .models import Game, Score, Tournament, User
from .serializers import GameSerializer, ScoreSerializer, TournamentSerializer, UserSerializer
from django.shortcuts import render

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
