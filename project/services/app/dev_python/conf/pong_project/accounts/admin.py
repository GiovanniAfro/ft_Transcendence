from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser

class CustomUserAdmin(UserAdmin):
    model = CustomUser
    list_display = ['username', 'email', 'games_played', 'games_won_count', 'total_score', 'win_rate', 'friends']
    list_filter = UserAdmin.list_filter + ('games_played', 'games_won_count')
    fieldsets = UserAdmin.fieldsets + (
        ('Game Statistics', {'fields': ('games_played', 'games_won_count', 'total_score', 'friends')}),
    )
    add_fieldsets = UserAdmin.add_fieldsets + (
        ('Game Statistics', {'fields': ('games_played', 'games_won_count', 'total_score', 'friends')}),
    )

admin.site.register(CustomUser, CustomUserAdmin)