from django import forms
from django.db import connections
from django.core.validators import MaxValueValidator
from datetime import datetime, timezone

class Login(forms.Form):
    email = forms.CharField(label='email', max_length=100)
    password = forms.CharField(label='Palavra-Passe', max_length=100)