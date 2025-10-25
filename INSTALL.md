# AA Timer Cog - Installation Guide

This guide will walk you through installing and configuring AA Timer Cog on your Alliance Auth instance.

## Prerequisites

Before you begin, make sure you have:

1. **Alliance Auth 4.0.0 or higher** installed and running
2. **aa-discordbot 3.0.0 or higher** installed and configured
3. **aa-structuretimers 1.0.0 or higher** installed and configured
4. **Access to your server** via SSH
5. **Sudo privileges** (for restarting services)

## Installation Steps

### 1. Download and Extract

If you received this as a ZIP file:

```bash
# Upload the ZIP file to your server, then:
cd /tmp
unzip aa-timercog.zip
cd aa-timercog
```

### 2. Activate Virtual Environment

```bash
# For standard installations:
source /home/allianceserver/venv/auth/bin/activate

# For Docker installations, enter the container first:
docker-compose exec allianceauth_gunicorn bash
```

### 3. Install the Package

```bash
pip install .
```

The installation will automatically install all required dependencies.

### 4. Update local.py

Edit your Alliance Auth `local.py` file (usually at `/home/allianceserver/myauth/myauth/local.py` or for Docker at your project root):

```bash
nano /home/allianceserver/myauth/myauth/local.py
```

Add `'timercog'` to your `INSTALLED_APPS`:

```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    # ... other apps ...
    'structuretimers',  # Make sure this is present
    'aadiscordbot',     # Make sure this is present
    'timercog',         # Add this line
]
```

### 5. Configure Permissions (Recommended)

Add these settings to your `local.py`:

```python
# Timer Cog Settings
# Discord Role IDs that can use the /timer add command
TIMERCOG_ALLOWED_ROLE_IDS = [
    # To get role IDs:
    # 1. Enable Developer Mode in Discord (User Settings > Advanced)
    # 2. Right-click on the role > Copy ID
    # 3. Paste the ID here (as a number, no quotes)
    
    # Example:
    # 123456789012345678,  # FC Role
    # 234567890123456789,  # Director Role
]

# Discord Channel IDs where command can be used (optional)
TIMERCOG_ALLOWED_CHANNELS = [
    # To get channel IDs:
    # 1. Enable Developer Mode in Discord
    # 2. Right-click on the channel > Copy ID
    # 3. Paste the ID here
    
    # Example:
    # 345678901234567890,  # #timer-management
]
```

**Notes:**
- If you leave `TIMERCOG_ALLOWED_ROLE_IDS` empty, no one can use the command
- If you leave `TIMERCOG_ALLOWED_CHANNELS` empty, the command works in all channels
- Role IDs are Discord role IDs, not Alliance Auth group IDs

### 6. Run Migrations

```bash
cd /home/allianceserver/myauth
python manage.py migrate
python manage.py collectstatic --noinput
```

### 7. Restart Services

**For Docker installations:**

```bash
docker-compose restart allianceauth_discordbot
```

**For Supervisor (bare metal) installations:**

```bash
supervisorctl restart myauth:authbot
```

### 8. Verify Installation

Check the bot logs to ensure the cog loaded successfully:

**Docker:**
```bash
docker-compose logs allianceauth_discordbot | grep -i "timer"
```

**Supervisor:**
```bash
tail -f /home/allianceserver/myauth/log/authbot.log | grep -i "timer"
```

You should see a message like:
```
Timer Cog loaded
```

### 9. Test in Discord

1. Go to your Discord server
2. Type `/timer` and you should see the `add` command appear
3. Try creating a test timer

## Post-Installation

### Load Eve Universe Data

If you haven't already, make sure to load the required Eve Universe data:

```bash
# Load solar systems
python manage.py eveuniverse_load_types EveSolarSystem

# Load structure types (category 65 is Structures)
python manage.py eveuniverse_load_types EveType --category_id 65
```

This may take several minutes to complete.

### Set Up Timer Board

Make sure aa-structuretimers is properly configured. See the [aa-structuretimers documentation](https://apps.allianceauth.org/apps/detail/aa-structuretimers) for details.

## Troubleshooting

### Command doesn't appear in Discord

**Problem:** `/timer` command doesn't show up in Discord

**Solutions:**
1. Check that `'timercog'` is in `INSTALLED_APPS`
2. Verify the bot has been restarted
3. Check bot logs for errors:
   ```bash
   # Docker
   docker-compose logs allianceauth_discordbot
   
   # Supervisor
   tail -100 /home/allianceserver/myauth/log/authbot.log
   ```
4. Make sure your bot has the `applications.commands` scope

### "You don't have permission" error

**Problem:** Users get permission denied when trying to use the command

**Solutions:**
1. Verify `TIMERCOG_ALLOWED_ROLE_IDS` is set correctly
2. Check that users have the required Discord role
3. Ensure users' Discord accounts are linked to Alliance Auth
4. Verify the command is being used in an allowed channel (if `TIMERCOG_ALLOWED_CHANNELS` is set)

### Autocomplete not working

**Problem:** Solar system or structure type autocomplete shows no results

**Solutions:**
1. Load Eve Universe data:
   ```bash
   python manage.py eveuniverse_load_types EveSolarSystem
   python manage.py eveuniverse_load_types EveType --category_id 65
   ```
2. Wait for the data to fully load (check progress in logs)
3. Restart the bot after data is loaded

### Timer not appearing in Timer Board

**Problem:** Timer is created but doesn't show in the web interface

**Solutions:**
1. Check that aa-structuretimers is properly installed
2. Verify timer permissions in Alliance Auth
3. Check timer filters in the web interface
4. Look for errors in Django logs

## Uninstallation

If you need to uninstall the plugin:

1. Remove `'timercog'` from `INSTALLED_APPS` in local.py
2. Remove the configuration settings
3. Restart services
4. Optionally uninstall the package:
   ```bash
   pip uninstall aa-timercog
   ```

## Getting Help

If you continue to have issues:

1. Check the bot logs carefully
2. Verify all prerequisites are met
3. Join the Alliance Auth Discord for community support
4. Open an issue on the GitHub repository with:
   - Your Alliance Auth version
   - Your aa-discordbot version
   - Your aa-structuretimers version
   - Relevant log excerpts
   - Steps to reproduce the issue

## Next Steps

- Configure notification rules in aa-structuretimers
- Set up additional timer types
- Train your FCs on how to use the command
- Consider integrating with other Auth apps like aa-opcalendar
