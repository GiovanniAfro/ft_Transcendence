import random
import logging
from django.views.generic import ListView
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
from django.contrib.auth import get_user_model
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
import logging
from django.views import View
from django.utils import timezone
from django.db.models import Q
from django.http import JsonResponse
from django.shortcuts import render, redirect
from django.contrib.auth import get_user_model
from django.core.exceptions import ValidationError
from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework.permissions import IsAuthenticated
from .models import MatchRequest, Game, Lobby, Tournament, TournamentParticipant, TournamentMatch, Notification, PlayerStats
from .serializers import GameSerializer, LobbySerializer, MatchRequestSerializer, TournamentSerializer, TournamentParticipantSerializer, TournamentMatchSerializer, NotificationSerializer, PlayerStatsSerializer, UserSerializer, MyTokenObtainPairSerializer

logger = logging.getLogger(__name__)
User = get_user_model()
CustomUser = get_user_model()

def index(request):
    return render(request, 'index.html')

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
        


class MyTokenObtainPairView(TokenObtainPairView):
    serializer_class = MyTokenObtainPairSerializer

class GameListCreateView(generics.ListCreateAPIView):
    queryset = Game.objects.all()
    serializer_class = GameSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        player2_username = serializer.validated_data.get('player2')
        if not player2_username:
            return Response({"error": "player2 is required"}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            player2 = CustomUser.objects.get(username=player2_username)
        except CustomUser.DoesNotExist:
            return Response({"error": "player2 not found"}, status=status.HTTP_400_BAD_REQUEST)
        
        game = Game.objects.create(
            player1=request.user,
            player2=player2,
            status='WAITING'
        )
        
        serializer = GameSerializer(game)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

class GameDetailView(generics.RetrieveUpdateAPIView):
    queryset = Game.objects.all()
    serializer_class = GameSerializer
    permission_classes = [permissions.IsAuthenticated]




class FriendListView(APIView):
	permission_classes = [IsAuthenticated]
	def get(self, request):
		friends = request.user.friends.all()
		paginator = Paginator(friends, 4)  # Show 25 contacts per page.
		page_number = request.GET.get("page", 1)
		try:
			page_number = int(page_number)
		except ValueError:
			page_number = 1
		page_obj = paginator.get_page(page_number)
		serializer = UserSerializer(list(page_obj), many=True)
		output = {
			'previous_page': page_obj.previous_page_number() if page_obj.has_previous() else None,
			'next_page': page_obj.next_page_number() if page_obj.has_next() else None,
            'actual_page': page_obj.number,
            'start_index': page_obj.start_index(),
            'end_index': page_obj.end_index(),
			'data': serializer.data
		}
		return Response(output)

class AddFriendView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        friend_username = request.data.get('friend_username')
        if not friend_username:
            return Response({"error": "Friend username is required"}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            friend = User.objects.get(username=friend_username)
            if friend == request.user:
                return Response({"error": "You cannot add yourself as a friend"}, status=status.HTTP_400_BAD_REQUEST)
            request.user.friends.add(friend)
            return Response({"message": "Friend added successfully"}, status=status.HTTP_200_OK)
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

class UserStatsView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        serializer = UserSerializer(user)
        return Response(serializer.data)


class MatchHistoryView(generics.ListAPIView):
    serializer_class = GameSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        return Game.objects.filter(Q(player1=user) | Q(player2=user))

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

class StartGameView(APIView):
    def post(self, request):
        player2_username = request.data.get('player2')
        if not player2_username:
            return Response({"error": "player2 is required"}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            player2 = CustomUser.objects.get(username=player2_username)
        except CustomUser.DoesNotExist:
            return Response({"error": "player2 not found"}, status=status.HTTP_400_BAD_REQUEST)
        
        # Verifica se player2 è un amico dell'utente corrente
        if player2 not in request.user.friends.all():
            return Response({"error": "You can only play with friends"}, status=status.HTTP_400_BAD_REQUEST)
        
        game = Game.objects.create(
            player1=request.user,
            player2=player2,
            status='WAITING'
        )
        serializer = GameSerializer(game)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

class SingleGameView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        logger.info(f"Received POST request to SingleGameView: {request.data}")
        player2_type = request.data.get('player2_type')
        player2_name = request.data.get('player2_name')

        if not player2_name:
            logger.error("Player 2 name is empty")
            return Response({'error': 'Player 2 name is required'}, status=status.HTTP_400_BAD_REQUEST)

        if player2_name == request.user.username:
            logger.error("Player trying to play against themselves")
            return Response({'error': 'Non puoi giocare contro te stesso'}, status=status.HTTP_400_BAD_REQUEST)
        game_data = {
            'is_single_game': True,
            'status': 'IN_PROGRESS'
        }

        if player2_type == 'registered':
            try:
                player2 = User.objects.get(username=player2_name)
                if player2 == request.user:
                    logger.error("Player trying to play against themselves")
                    return Response({'error': 'Non puoi giocare contro te stesso'}, status=status.HTTP_400_BAD_REQUEST)
                game_data['player2'] = player2.id
            except User.DoesNotExist:
                logger.error(f"Player 2 not found: {player2_name}")
                return Response({'error': f'Player 2 "{player2_name}" not found'}, status=status.HTTP_404_NOT_FOUND)
        else:
            game_data['player2_alias'] = player2_name

        logger.info(f"Game data prepared: {game_data}")
        serializer = GameSerializer(data=game_data, context={'request': request})
        if serializer.is_valid():
            logger.info("Serializer is valid, saving game")
            game = serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        logger.error(f"Serializer errors: {serializer.errors}")
        return Response({'error': 'Invalid game data', 'details': serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request, pk):
        try:
            game = Game.objects.get(pk=pk, player1=request.user, is_single_game=True)
        except Game.DoesNotExist:
            return Response({'error': 'Game not found'}, status=status.HTTP_404_NOT_FOUND)

        serializer = GameSerializer(game, data=request.data, partial=True, context={'request': request})
        if serializer.is_valid():
            game = serializer.save()

            if game.status == 'FINISHED':
                # Aggiorna le statistiche del giocatore 1
                game.player1.games_played += 1
                game.player1.total_score += game.score_player1

                # Aggiorna le statistiche del giocatore 2, se esiste
                if game.player2:
                    game.player2.games_played += 1
                    game.player2.total_score += game.score_player2

                # Determina il vincitore
                if game.score_player1 > game.score_player2:
                    game.winner = game.player1
                    game.player1.games_won_count += 1
                else:
                    game.winner = game.player2
                    if game.player2:
                        game.player2.games_won_count += 1

                # Salva le modifiche
                game.player1.save()
                if game.player2:
                    game.player2.save()
                game.save()

            return Response(serializer.data)
        else:
            
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
class UpdateScoreView(APIView):
    def post(self, request, pk):
        try:
            game = Game.objects.get(pk=pk)
        except Game.DoesNotExist:
            return Response({"error": "Game not found"}, status=status.HTTP_404_NOT_FOUND)
        
        score1 = request.data.get('score_player1')
        score2 = request.data.get('score_player2')
        
        if score1 is not None and score2 is not None:
            game.score_player1 = score1
            game.score_player2 = score2
            game.status = 'IN_PROGRESS'
            
            if score1 >= 11 or score2 >= 11:
                game.status = 'FINISHED'
                game.player1.games_played += 1
                game.player2.games_played += 1
                game.player1.total_score += score1
                game.player2.total_score += score2

                if score1 > score2:
                    game.player1.games_won_count += 1
                    game.winner = game.player1
                else:
                    game.player2.games_won_count += 1
                    game.winner = game.player2

                game.player1.save()
                game.player2.save()

            game.save()

        serializer = GameSerializer(game)
        return Response(serializer.data)
    
class MatchmakingView(APIView):
    def post(self, request):
        # Crea una nuova richiesta di matchmaking
        match_request = MatchRequest.objects.create(player=request.user)
        
        # Cerca un avversario
        opponent_request = MatchRequest.objects.filter(
            is_active=True
        ).exclude(
            player=request.user
        ).order_by('created_at').first()
        
        if opponent_request:
            # Se trova un avversario, crea una nuova partita
            game = Game.create_from_match_requests(match_request, opponent_request)
            serializer = GameSerializer(game)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        
        # Se non trova un avversario, restituisce la richiesta di matchmaking
        serializer = MatchRequestSerializer(match_request)
        return Response(serializer.data, status=status.HTTP_202_ACCEPTED)

class CancelMatchmakingView(APIView):
    def post(self, request):
        MatchRequest.objects.filter(player=request.user, is_active=True).update(is_active=False)
        return Response({"message": "Matchmaking request cancelled"}, status=status.HTTP_200_OK)
    
class LobbyListCreateView(generics.ListCreateAPIView):
    queryset = Lobby.objects.filter(is_active=True)
    serializer_class = LobbySerializer

    def perform_create(self, serializer):
        serializer.save(creator=self.request.user)

class LobbyDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Lobby.objects.all()
    serializer_class = LobbySerializer

class JoinLobbyView(generics.UpdateAPIView):
    queryset = Lobby.objects.all()
    serializer_class = LobbySerializer

    def patch(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)

    def update(self, request, *args, **kwargs):
        lobby = self.get_object()
        if lobby.players.count() >= lobby.max_players:
            return Response({"error": "Lobby is full"}, status=status.HTTP_400_BAD_REQUEST)
        lobby.players.add(request.user)
        if lobby.players.count() == lobby.max_players:
            # Start the game
            game = Game.objects.create(
                player1=lobby.creator,
                player2=lobby.players.exclude(id=lobby.creator.id).first()
            )
            lobby.is_active = False
            lobby.save()
            game_serializer = GameSerializer(game)
            return Response({"message": "Game started", "game": game_serializer.data}, status=status.HTTP_201_CREATED)

        return Response(LobbySerializer(lobby).data)

class StartMatchView(APIView):
    def post(self, request, tournament_id, match_id):
        try:
            tournament = Tournament.objects.get(id=tournament_id)
            match = TournamentMatch.objects.get(id=match_id, tournament=tournament)
            
            if match.winner is not None:
                return Response({"error": "This match has already been played"}, status=status.HTTP_400_BAD_REQUEST)
            
            # Qui potresti aggiungere logica aggiuntiva per verificare se è il turno corretto per giocare questa partita

            serializer = TournamentMatchSerializer(match)
            return Response(serializer.data)
        except Tournament.DoesNotExist:
            return Response({"error": "Tournament not found"}, status=status.HTTP_404_NOT_FOUND)
        except TournamentMatch.DoesNotExist:
            return Response({"error": "Match not found"}, status=status.HTTP_404_NOT_FOUND)

class CreateTournamentView(APIView):
    def post(self, request):
        if not Tournament.can_create_new():
            return Response({"error": "An active tournament already exists"}, status=status.HTTP_400_BAD_REQUEST)
        
        serializer = TournamentSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
class TournamentListView(generics.ListAPIView):
    serializer_class = TournamentSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        logger.info(f"User {user.username} (ID: {user.id}) requesting tournaments")
        print(f"Debug: User {user.username} (ID: {user.id}) requesting tournaments")
        queryset = Tournament.objects.filter(creator=user)
        logger.info(f"Returning {queryset.count()} tournaments for user {user.username}")
        print(f"Debug: Returning {queryset.count()} tournaments for user {user.username}")
        print(f"Debug: All tournaments in database:")
        for tournament in Tournament.objects.all():
            print(f"  - ID: {tournament.id}, Name: {tournament.name}, Creator: {tournament.creator.username}")
        return queryset
    
class TournamentDetailView(generics.RetrieveAPIView):
    queryset = Tournament.objects.all()
    serializer_class = TournamentSerializer

class TournamentAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        print(f"Debug: User {user.username} (ID: {user.id}) requesting tournaments")
        tournaments = Tournament.objects.filter(creator=user)
        print(f"Debug: Returning {tournaments.count()} tournaments for user {user.username}")
        print(f"Debug: All tournaments in database:")
        for tournament in Tournament.objects.all():
            print(f"  - ID: {tournament.id}, Name: {tournament.name}, Creator: {tournament.creator.username}")
        serializer = TournamentSerializer(tournaments, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = TournamentSerializer(data=request.data)
        if serializer.is_valid():
            try:
                tournament = serializer.save(creator=request.user)
                return Response(serializer.data, status=status.HTTP_201_CREATED)
            except ValidationError as e:
                print(f"Debug: ValidationError occurred: {str(e)}")
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        else:
            print(f"Debug: Serializer errors: {serializer.errors}")
            
            errors = {field: str(error[0]) for field, error in serializer.errors.items()}
            return Response({"errors": errors}, status=status.HTTP_400_BAD_REQUEST)

class JoinTournamentAPIView(APIView):
    def post(self, request, pk):
        try:
            tournament = Tournament.objects.get(pk=pk)
            if tournament.creator != request.user:
                return Response({"error": "You can only add participants to tournaments you've created"}, status=status.HTTP_403_FORBIDDEN)
            if tournament.status != 'REGISTRATION':
                return Response({"error": "Tournament is not open for registration"}, status=status.HTTP_400_BAD_REQUEST)
            
            if tournament.is_full():
                return Response({"error": "Tournament is already full"}, status=status.HTTP_400_BAD_REQUEST)

            alias = request.data.get('alias')
            if not alias:
                return Response({"error": "Alias is required"}, status=status.HTTP_400_BAD_REQUEST)

            participant, created = TournamentParticipant.objects.get_or_create(
                tournament=tournament,
                alias=alias,
                defaults={'user': None}  # L'utente rimane None poiché è solo un alias
            )
            if not created:
                return Response({"error": "This alias is already taken in this tournament"}, status=status.HTTP_400_BAD_REQUEST)

            if tournament.is_full():
                tournament.start_if_full()

            serializer = TournamentSerializer(tournament)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        except Tournament.DoesNotExist:
            return Response({"error": "Tournament not found"}, status=status.HTTP_404_NOT_FOUND)

class StartMatchView(APIView):
    def post(self, request, tournament_id, match_id):
        try:
            tournament = Tournament.objects.get(id=tournament_id)
            match = TournamentMatch.objects.get(id=match_id, tournament=tournament)
            
            if match.winner is not None:
                return Response({"error": "This match has already been played"}, status=status.HTTP_400_BAD_REQUEST)
            
            # Qui potresti aggiungere logica aggiuntiva per verificare se è il turno corretto per giocare questa partita

            serializer = TournamentMatchSerializer(match)
            return Response(serializer.data)
        except Tournament.DoesNotExist:
            return Response({"error": "Tournament not found"}, status=status.HTTP_404_NOT_FOUND)
        except TournamentMatch.DoesNotExist:
            return Response({"error": "Match not found"}, status=status.HTTP_404_NOT_FOUND)

class TournamentMatchDetailView(generics.RetrieveAPIView):
    queryset = TournamentMatch.objects.all()
    serializer_class = TournamentMatchSerializer

    def get_object(self):
        tournament_id = self.kwargs['tournament_id']
        match_id = self.kwargs['match_id']
        return self.queryset.get(tournament_id=tournament_id, id=match_id)
    

class SubmitMatchResultView(APIView):
    def post(self, request, tournament_id, match_id):
        try:
            tournament = Tournament.objects.get(id=tournament_id)
            match = TournamentMatch.objects.get(id=match_id, tournament=tournament)
            
            if match.winner is not None:
                return Response({"error": "This match has already been played"}, status=status.HTTP_400_BAD_REQUEST)
            
            score1 = request.data.get('score_player1')
            score2 = request.data.get('score_player2')
            
            if score1 is None or score2 is None:
                return Response({"error": "Both scores are required"}, status=status.HTTP_400_BAD_REQUEST)
            
            match.score_player1 = score1
            match.score_player2 = score2
            match.winner = match.player1 if score1 > score2 else match.player2
            match.save()
            
            tournament.advance_tournament()
            
            # Trova la prossima partita non giocata
            next_match = TournamentMatch.objects.filter(
                tournament=tournament,
                winner__isnull=True
            ).order_by('round').first()
            
            return Response({
                'match': TournamentMatchSerializer(match).data,
                'next_match': next_match.id if next_match else None,
                'tournament_status': tournament.status
            })
        except Tournament.DoesNotExist:
            return Response({"error": "Tournament not found"}, status=status.HTTP_404_NOT_FOUND)
        except TournamentMatch.DoesNotExist:
            return Response({"error": "Match not found"}, status=status.HTTP_404_NOT_FOUND)

class TournamentStatusView(APIView):
    def get(self, request, pk):
        try:
            tournament = Tournament.objects.get(pk=pk)
            serializer = TournamentSerializer(tournament)
            return Response(serializer.data)
        except Tournament.DoesNotExist:
            return Response({"error": "Tournament not found"}, status=status.HTTP_404_NOT_FOUND)

class UserDashboardView(APIView):
    def get(self, request):
        user = request.user
        stats, _ = PlayerStats.objects.get_or_create(user=user)
        notifications = Notification.objects.filter(user=user, is_read=False)
        current_tournaments = Tournament.objects.filter(participants__user=user, status='IN_PROGRESS')
        
        data = {
            'stats': PlayerStatsSerializer(stats).data,
            'notifications': NotificationSerializer(notifications, many=True).data,
            'current_tournaments': TournamentSerializer(current_tournaments, many=True).data
        }
        return Response(data)

class ReadNotificationView(APIView):
    def post(self, request, pk):
        try:
            notification = Notification.objects.get(pk=pk, user=request.user)
        except Notification.DoesNotExist:
            return Response({"error": "Notification not found"}, status=status.HTTP_404_NOT_FOUND)
        
        notification.is_read = True
        notification.save()
        return Response({"message": "Notification marked as read"})

def chat_room(request, room_name):
    return render(request, 'chat_room.html', {
        'room_name': room_name
    })
