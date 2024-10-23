from django.utils import timezone
from datetime import timedelta
import logging
from django.core.paginator import Paginator
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny
from pong_game.models import Game
from pong_game.serializers import GameSerializer
from django.db.models import Q
from .models import CustomUser, Match
from django.contrib.auth import get_user_model
from .serializers import UserSerializer, MatchSerializer
from two_factor.views import SetupView, LoginView
from two_factor.forms import AuthenticationTokenForm, BackupTokenForm
from django.contrib.auth.decorators import login_required
from rest_framework_simplejwt.views import TokenObtainPairView
from django.utils.decorators import method_decorator
from django_otp.plugins.otp_totp.models import TOTPDevice
from rest_framework_simplejwt.tokens import RefreshToken
from django_otp.util import random_hex
import qrcode
import qrcode.image.svg
from io import BytesIO
import base64


User = get_user_model()

logger = logging.getLogger(__name__)

@method_decorator(csrf_exempt, name='dispatch')
class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response({"message": "Utente registrato con successo", "user_id": user.id}, status=status.HTTP_201_CREATED)
        return Response({"message": "Errore di registrazione", "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)


class TwoFactorSetupView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        device, created = TOTPDevice.objects.get_or_create(user=user, name="default")

        if created or not device.confirmed:
            device.key = random_hex()
            device.save()

        url = device.config_url
        img = qrcode.make(url, image_factory=qrcode.image.svg.SvgImage)
        buffer = BytesIO()
        img.save(buffer)
        qr_code = base64.b64encode(buffer.getvalue()).decode()

        return Response({
            'qr_code': qr_code,
            'secret_key': device.key,
        })

    def post(self, request):
        user = request.user
        token = request.data.get('token')

        device = TOTPDevice.objects.get(user=user, name="default")
        if device.verify_token(token):
            device.confirmed = True
            device.save()
            return Response({'message': '2FA configurato con successo'}, status=status.HTTP_200_OK)
        else:
            return Response({'message': 'Token non valido'}, status=status.HTTP_400_BAD_REQUEST)

class CustomTokenObtainPairView(TokenObtainPairView):
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)

        try:
            serializer.is_valid(raise_exception=True)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

        user = serializer.user
        device = TOTPDevice.objects.filter(user=user, confirmed=True).first()

        if device:
            # L'utente ha la 2FA abilitata
            return Response({
                'requires_2fa': True,
                'user_id': user.id
            }, status=status.HTTP_202_ACCEPTED)
        elif not TOTPDevice.objects.filter(user=user).exists():
            # L'utente non ha ancora configurato la 2FA
            return Response({
                'requires_2fa_setup': True,
                'access': str(serializer.validated_data['access']),
                'refresh': str(serializer.validated_data['refresh'])
            }, status=status.HTTP_202_ACCEPTED)

        # Se non c'è 2FA o non è confermata, procedi con il login normale
        return Response(serializer.validated_data, status=status.HTTP_200_OK)

@method_decorator(csrf_exempt, name='dispatch')
class Verify2FAView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        logger.info("Received 2FA verification request")
        logger.info(f"Request data: {request.data}")

        token = request.data.get('token')
        username = request.data.get('username')

        if not token or not username:
            return Response({'error': 'Dati mancanti'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.get(username=username)
            device = TOTPDevice.objects.get(user=user, confirmed=True)

            if device.verify_token(token):
                refresh = RefreshToken.for_user(user)
                return Response({
                    'refresh': str(refresh),
                    'access': str(refresh.access_token),
                }, status=status.HTTP_200_OK)
            else:
                return Response({'error': 'Token non valido'}, status=status.HTTP_400_BAD_REQUEST)

        except User.DoesNotExist:
            logger.error(f"User not found: {username}")
            return Response({'error': 'Utente non trovato'}, status=status.HTTP_400_BAD_REQUEST)
        except TOTPDevice.DoesNotExist:
            logger.error(f"TOTP device not found for user: {username}")
            return Response({'error': 'Dispositivo 2FA non trovato'}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            logger.exception(f"Unexpected error during 2FA verification: {str(e)}")
            return Response({'error': 'Errore durante la verifica'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class UserDetailView(generics.RetrieveUpdateAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get_object(self):
        return self.request.user

    def update(self, request, *args, **kwargs):
        logger.info(f"Received update request: {request.data}")
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        if serializer.is_valid():
            logger.info("Data is valid, performing update")
            self.perform_update(serializer)
            return Response(serializer.data)
        else:
            logger.error(f"Validation errors: {serializer.errors}")
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def perform_update(self, serializer):
        serializer.save()

class UserStatsView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        serializer = UserSerializer(user)
        return Response(serializer.data)

class MatchHistoryView(APIView):
    serializer_class = GameSerializer
    permission_classes = [permissions.IsAuthenticated]

    # def get_querygetset(self):
        # user = self.request.user
        # games = Game.objects.filter(Q(player1=user) | Q(player2=user))
        # paginator = Paginator(games, 5)
        # page_number = self.request.GET.get("page", 1)
        # logger.info(f"Requested page: {page_number}")
        # try:
            # page_obj = int(page_number)
        # except ValueError:
            # page_obj = paginator.page(1)
        # page_obj = paginator.get_page(page_obj)
        # output1 = {
            # 'matches_previous_page': page_obj.previous_page_number() if page_obj.has_previous() else None,
            # 'matches_next_page': page_obj.next_page_number() if page_obj.has_next() else None,
            # 'matches_actual_page': page_obj.number,
            # 'matches_start_index': page_obj.start_index(),
            # 'matches_end_index': page_obj.end_index(),
            #    'games': games
        # }
        # return output1
    def get(self, request):
        user = self.request.user

        games = Game.objects.filter(Q(player1=user) | Q(player2=user))
        paginator = Paginator(games, 5)  # Show 25 contacts per page.
        page_number = request.GET.get("page", 1)
        try:
            page_number = int(page_number)
        except ValueError:
            page_number = 1
        page_obj = paginator.get_page(page_number)
        games_serialized = GameSerializer(list(page_obj), many=True)
        output1 = {
            'matches_previous_page': page_obj.previous_page_number() if page_obj.has_previous() else None,
            'matches_next_page': page_obj.next_page_number() if page_obj.has_next() else None,
            'matches_actual_page': page_obj.number,
            'matches_start_index': page_obj.start_index(),
            'matches_end_index': page_obj.end_index(),
            'matches': games_serialized.data
        }
        return Response(output1)


class FollowUserView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        try:
            user_to_follow = CustomUser.objects.get(pk=pk)
            if user_to_follow != request.user:
                request.user.following.add(user_to_follow)
                return Response({"message": f"You are now following {user_to_follow.username}"}, status=status.HTTP_200_OK)
            else:
                return Response({"message": "You cannot follow yourself"}, status=status.HTTP_400_BAD_REQUEST)
        except CustomUser.DoesNotExist:
            return Response({"message": "User not found"}, status=status.HTTP_404_NOT_FOUND)

class UnfollowUserView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        try:
            user_to_unfollow = CustomUser.objects.get(pk=pk)
            request.user.following.remove(user_to_unfollow)
            return Response({"message": f"You have unfollowed {user_to_unfollow.username}"}, status=status.HTTP_200_OK)
        except CustomUser.DoesNotExist:
            return Response({"message": "User not found"}, status=status.HTTP_404_NOT_FOUND)

class OnlineFriendsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        five_minutes_ago = timezone.now() - timedelta(minutes=5)
        online_friends = user.friends.filter(last_activity__gte=five_minutes_ago)
        serializer = UserSerializer(online_friends, many=True)
        return Response(serializer.data)

class FriendsStatusView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        five_minutes_ago = timezone.now() - timedelta(minutes=5)
        friends = user.friends.all()

        paginator = Paginator(friends, 4)
        page_number = request.GET.get("page", 1)
        try:
            page_number = int(page_number)
        except ValueError:
            page_number = 1
        page_obj = paginator.get_page(page_number)
        friend_data = []
        for friend in page_obj:
            friend_data.append({
                'username': friend.username,
                'is_online': friend.last_activity >= five_minutes_ago
            })
        output = {
            'previous_page': page_obj.previous_page_number() if page_obj.has_previous() else None,
            'next_page': page_obj.next_page_number() if page_obj.has_next() else None,
            'actual_page': page_obj.number,
            'start_index': page_obj.start_index(),
            'end_index': page_obj.end_index(),
            'data': friend_data
        }
        return Response(output)
