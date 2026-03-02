#!/bin/bash

echo "=== Install Discord Clear Skill ==="
read -p "Enter nanobot workspace path [default: ~/.nanobot/workspace]: " NANOBOT_PATH
NANOBOT_PATH=${NANOBOT_PATH:-~/.nanobot/workspace}
NANOBOT_PATH=$(eval echo "$NANOBOT_PATH")

read -p "Enter nanobot config file path [default: ~/.nanobot/config.json]: " CONFIG_PATH
CONFIG_PATH=${CONFIG_PATH:-~/.nanobot/config.json}
CONFIG_PATH=$(eval echo "$CONFIG_PATH")

SKILL_DIR="$NANOBOT_PATH/skills/discord-clear"
TOOL_DIR="$NANOBOT_PATH/skill-tools"

mkdir -p "$SKILL_DIR"
mkdir -p "$TOOL_DIR"

cat << 'EOF' > "$SKILL_DIR/SKILL.md"
---
name: discord-clear
description: Clear Discord message history.
---

# Discord Clear Skill

## Description
Clears the bot's own message history in the current Discord DM channel or server. It uses `uv` with PEP 723 inline script metadata to handle `discord.py` dependencies dynamically.

## Usage
When the user asks to clear the chat, wipe history, or delete bot messages, use the `exec` tool to run the script. **You must pass your current Chat ID** (available in your system prompt) as an argument.

```bash
uv run SKILL_TOOL_PATH <YOUR_CHAT_ID>
```

This will log into Discord, find the specified channel, loop through the history, and delete messages authored by the bot one by one (with a rate-limit delay). Note that the script has a limit of deleting up to 100 messages per run. If there are more than 100 messages to clear, you may need to run the command multiple times or inform the user.
EOF

# Replace SKILL_TOOL_PATH with the actual path
sed -i "s|SKILL_TOOL_PATH|$TOOL_DIR/discord_clear.py|g" "$SKILL_DIR/SKILL.md"

cat << 'EOF' > "$TOOL_DIR/discord_clear.py"
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "discord.py",
# ]
# ///
import discord
import json
import asyncio
import sys

class ClearClient(discord.Client):
    def __init__(self, channel_id, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.target_channel_id = channel_id

    async def on_ready(self):
        print(f'Logged on as {self.user}!')
        try:
            channel = await self.fetch_channel(self.target_channel_id)
            if channel:
                deleted = 0
                async for message in channel.history(limit=100):
                    if message.author == self.user:
                        try:
                            await message.delete()
                            deleted += 1
                            await asyncio.sleep(0.5)
                        except Exception as e:
                            print(f"Error deleting message: {e}")
                print(f"Successfully deleted {deleted} messages.")
            else:
                print("Could not find the specified channel.")
        except Exception as e:
            print(f"Error accessing channel: {e}")
        finally:
            await self.close()

def main():
    if len(sys.argv) < 2:
        print("Usage: uv run discord_clear.py <CHANNEL_ID>")
        sys.exit(1)
        
    try:
        channel_id = int(sys.argv[1])
    except ValueError:
        print("Error: CHANNEL_ID must be an integer.")
        sys.exit(1)

    config_path = 'REPLACE_CONFIG_PATH'
    try:
        with open(config_path, 'r') as f:
            config = json.load(f)
        
        # Attempt to find the token in common configuration structures
        token = config.get('token')
        if not token and 'channels' in config and 'discord' in config['channels']:
            token = config['channels']['discord'].get('token')
            
        if not token:
            print("Error: Could not find Discord token in config.json")
            return

        intents = discord.Intents.default()
        client = ClearClient(channel_id=channel_id, intents=intents)
        client.run(token)
    except Exception as e:
        print(f"Failed to start: {e}")

if __name__ == '__main__':
    main()
EOF

# Replace config path
sed -i "s|REPLACE_CONFIG_PATH|$CONFIG_PATH|g" "$TOOL_DIR/discord_clear.py"
chmod +x "$TOOL_DIR/discord_clear.py"

echo "Discord Clear Skill installed successfully!"
