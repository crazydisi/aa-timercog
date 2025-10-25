"""
Django settings for tests
"""

SECRET_KEY = "test-secret-key-for-testing-only"

DEBUG = True

INSTALLED_APPS = [
    "django.contrib.contenttypes",
    "django.contrib.auth",
    "django.contrib.sessions",
    "timercog",
]

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": ":memory:",
    }
}

USE_TZ = True

ROOT_URLCONF = ""

MIDDLEWARE = []

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [],
        },
    },
]

# Timer Cog specific settings for testing
TIMERCOG_ALLOWED_ROLE_IDS = []
TIMERCOG_ALLOWED_CHANNELS = []
TIMERCOG_GUILD_IDS = None
