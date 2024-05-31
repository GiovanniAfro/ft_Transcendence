from django.contrib import admin
from .models import User, UserProfile, Tournament, Match, Game, Score

# Opzionale: Definisci classi Admin per personalizzare la visualizzazione e la gestibilità dei modelli
class TournamentAdmin(admin.ModelAdmin):
    list_display = ('name', 'start_date', 'is_active')  # Campi mostrati nella lista
    search_fields = ('name',)  # Campi ricercabili

class MatchAdmin(admin.ModelAdmin):
    list_display = ('tournament', 'player1', 'player2', 'winner')
    list_filter = ('tournament', 'winner')  # Filtri disponibili

# Registra i modelli con le opzioni Admin, se presenti
admin.site.register(Tournament, TournamentAdmin)
admin.site.register(Match, MatchAdmin)
admin.site.register(Game)
admin.site.register(Score)
admin.site.register(UserProfile)

# Se il modello User non è già registrato da un'altra app

