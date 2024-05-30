from rest_framework import serializers
from .models import Game, Score

class GameSerializer(serializers.ModelSerializer):
    class Meta:
        model = Game
        fields = '__all__'  # Includi tutti i campi del modello Game

class ScoreSerializer(serializers.ModelSerializer):
    class Meta:
        model = Score
        fields = '__all__'  # Includi tutti i campi del modello Score