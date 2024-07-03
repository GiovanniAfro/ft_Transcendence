from rest_framework import serializers
from .models import Game, Score
from django.contrib.auth.models import User
from .models import Tournament, UserProfile

class UserSerializer(serializers.ModelSerializer):
    alias = serializers.CharField(source='profile.alias', allow_blank=True)

    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'alias')

    def update(self, instance, validated_data):
        profile_data = validated_data.pop('profile', {})
        alias = profile_data.get('alias')

        instance = super(UserSerializer, self).update(instance, validated_data)
        if alias:
            profile, created = UserProfile.objects.get_or_create(user=instance)
            profile.alias = alias
            profile.save()
        return instance
    
class TournamentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Tournament
        fields = '__all__'

class GameSerializer(serializers.ModelSerializer):
    class Meta:
        model = Game
        fields = '__all__'  # Includi tutti i campi del modello Game

class ScoreSerializer(serializers.ModelSerializer):
    class Meta:
        model = Score
        fields = '__all__'  # Includi tutti i campi del modello Score