# Discord Clear Skill for nanobot

This project provides an installation script to add a custom "discord-clear" skill to your nanobot instance.

## Overview
Because Discord limits the ability to clear DMs natively, this skill allows nanobot to delete its *own* recent messages in the active channel. Note: Users will still need to use a tool like Redact to delete their side of the conversation.

## Features
- Deletes the bot's own recent messages (up to 100 per run).
- Dynamically detects the current channel/chat ID (no need to hardcode the channel).
- Uses your existing `config.json` for the Discord bot token.

## Requirements
- **uv**: This tool requires `uv` to be installed on your system. `uv` is used to execute the Python script using PEP 723 inline script metadata (e.g., `# /// script dependencies = ["discord.py"]`). This allows the script to automatically manage its own dependencies on the fly without requiring you to manually set up a virtual environment (`.venv`) or manage a `requirements.txt` file.

## Installation
Run the included shell script:
```bash
./install_discord_clear.sh
```
The script will prompt you for your nanobot workspace path and the path to your `config.json` file. 

*Note: The script will automatically create the following directories in your nanobot workspace if they don't already exist:*
- `skills/discord-clear/` - where the `SKILL.md` instructions are saved.
- `skill-tools/` - where the actual `discord_clear.py` script is saved.

## Usage
Once installed, simply ask your nanobot to clear discord message history (e.g. "Please clear your recent messages in this Discord chat." The bot will execute the skill using its current active channel ID. Optionally, you can instruct your nanobot to configure a cron job to clear message history (Discord API doesn't allow deletion of old messages).

## License
MIT
