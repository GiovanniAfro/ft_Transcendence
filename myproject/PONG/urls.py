from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import GameViewSet, ScoreViewSet, TournamentViewSet

router = DefaultRouter()
router.register(r'games', GameViewSet)
router.register(r'scores', ScoreViewSet)
router.register(r'tournaments', TournamentViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
