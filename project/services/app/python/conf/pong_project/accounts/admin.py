from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser

class CustomUserAdmin(UserAdmin):
    model = CustomUser
    list_display = ['username', 'get_friends', 'email', 'games_played', 'games_won_count', 'total_score', 'win_rate']
    list_filter = UserAdmin.list_filter + ('games_played', 'games_won_count')
    fieldsets = UserAdmin.fieldsets + (
    ('Game Statistics', {'fields': ('games_played', 'games_won_count', 'total_score', 'friends')}),
    )
    add_fieldsets = UserAdmin.add_fieldsets + (
        ('Game Statistics', {'fields': ('games_played', 'games_won_count', 'total_score')}),
    )

    def get_friends(self, obj):
        return ", ".join([friend.username for friend in obj.friends.all()])
    
    get_friends.short_description = 'Friends'

    def win_rate(self, obj):
        if obj.games_played > 0:
            return f"{(obj.games_won_count / obj.games_played) * 100:.2f}%"
        return "0%"
    
    win_rate.short_description = 'Win Rate'

admin.site.register(CustomUser, CustomUserAdmin)