from rest_framework import viewsets
from .models import Game, Score
from .serializers import GameSerializer, ScoreSerializer

class GameViewSet(viewsets.ModelViewSet):  #ModelViewSet gestisce automaticamente le operazioni CRUD (Creare, Leggere, Aggiornare, Eliminare) per un modello specifico.
    queryset = Game.objects.all() #queryset: Specifica come ottenere l'insieme di dati dal database.
    serializer_class = GameSerializer #serializer_class: Collega il ViewSet al serializer appropriato.

class ScoreViewSet(viewsets.ModelViewSet):
    queryset = Score.objects.all()
    serializer_class = ScoreSerializer