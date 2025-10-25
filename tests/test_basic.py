"""
Basic tests for Timer Cog
"""

import pytest


def test_import_timercog():
    """Test that the timercog package can be imported."""
    import timercog

    assert timercog is not None
    assert hasattr(timercog, "__version__")


def test_version():
    """Test that version is defined."""
    from timercog import __version__

    assert __version__ is not None
    assert isinstance(__version__, str)
    assert len(__version__) > 0


def test_apps_config():
    """Test that apps.py is configured correctly."""
    from timercog.apps import TimerCogConfig

    assert TimerCogConfig.name == "timercog"
    assert TimerCogConfig.label == "timercog"
    assert TimerCogConfig.verbose_name == "Timer Cog"


def test_auth_hooks():
    """Test that auth hooks are configured correctly."""
    from timercog.auth_hooks import TimerCogHooks

    assert hasattr(TimerCogHooks, "register_cogs")
    cogs = TimerCogHooks.register_cogs()
    assert isinstance(cogs, list)
    assert "timercog.cogs.timer_cog" in cogs


@pytest.mark.django_db
def test_cog_initialization():
    """Test that the TimerCog can be initialized."""
    from unittest.mock import Mock

    from timercog.cogs.timer_cog import TimerCog

    # Create a mock bot
    mock_bot = Mock()

    # Initialize the cog
    cog = TimerCog(mock_bot)

    assert cog is not None
    assert cog.bot == mock_bot


def test_settings_getters():
    """Test that settings getter functions work."""
    from timercog.cogs.timer_cog import (
        get_allowed_discord_roles,
        get_guild_ids,
        get_timer_channels,
    )

    # These should return the values from settings or defaults
    roles = get_allowed_discord_roles()
    channels = get_timer_channels()
    guilds = get_guild_ids()

    assert isinstance(roles, list)
    assert isinstance(channels, list)
    assert guilds is None or isinstance(guilds, list)
