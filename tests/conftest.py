"""
Pytest configuration and fixtures for Timer Cog tests
"""

import os

import django
import pytest


def pytest_configure():
    """Configure Django settings for pytest."""
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "tests.settings")
    django.setup()


@pytest.fixture
def mock_bot():
    """Fixture that provides a mock Discord bot."""
    from unittest.mock import Mock

    bot = Mock()
    bot.user = Mock()
    bot.user.id = 123456789
    return bot


@pytest.fixture
def mock_ctx():
    """Fixture that provides a mock Discord context."""
    from unittest.mock import Mock

    ctx = Mock()
    ctx.author = Mock()
    ctx.author.id = 987654321
    ctx.author.name = "TestUser"
    ctx.author.display_name = "Test User"
    ctx.author.roles = []
    ctx.channel = Mock()
    ctx.channel.id = 111222333
    return ctx
