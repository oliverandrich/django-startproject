from django.contrib.auth import get_user_model
from django.http import HttpRequest

User = get_user_model()


class AuthenticatedHttpRequest(HttpRequest):
    user: User
