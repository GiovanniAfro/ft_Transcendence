from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import GameViewSet, ScoreViewSet

router = DefaultRouter()
router.register(r'games', GameViewSet)
router.register(r'scores', ScoreViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
