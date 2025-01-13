import requests
import logging
import os
from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, MessageHandler, ContextTypes
from telegram.ext import filters

# Function to load configuration from a .conf file
def load_config(file_path):
    config = {}
    if not os.path.exists(file_path):
        # Log error if config file is missing
        logger.error(f"Config file not found: {file_path}")
        raise FileNotFoundError(f"Config file not found: {file_path}")

    with open(file_path, "r") as file:
        for line in file:
            line = line.strip()
            if "=" in line and not line.startswith("#"):  # Ignore comments
                key, value = line.split("=", 1)
                config[key.strip()] = value.strip()
    return config

# Set up logging to log to the specified file path
LOG_FILE_PATH = "/opt/dloadbox/log/dloadbox-telegrambot.log"
logging.basicConfig(
    filename=LOG_FILE_PATH,
    level=logging.DEBUG,
    format="%(asctime)s - %(message)s",
)

logger = logging.getLogger(__name__)

# Default config file path
CONFIG_FILE_PATH = "/opt/dloadbox/config/dloadbox-telegrambot.conf"

# Load configuration settings (with error handling if the config file is missing)
try:
    config = load_config(CONFIG_FILE_PATH)
    # Assign configuration variables
    LIMIT_PERMISSION = config["LIMIT_PERMISSION"] == "true"
    ALLOWED_USERNAMES = config["ALLOWED_USERNAMES"].split(",")
    ARIA2_RPC_SECRET = config["ARIA2_RPC_SECRET"]
    ARIA2_RPC_URL = config["ARIA2_RPC_URL"]
    BOT_TOKEN = config["BOT_TOKEN"]
    LOG_FILE_PATH = config["LOG_FILE_PATH"]
except FileNotFoundError as e:
    logger.error(str(e))  # Log the error
    exit(1)  # Exit if config is missing

# Function to check if the URL is valid
def is_valid_url(url):
    try:
        response = requests.head(url, timeout=10)
        if response.status_code // 100 == 2:
            return True
        else:
            return False
    except requests.RequestException as e:
        # Log error if URL check fails
        logger.error(f"Error checking URL {url}: {str(e)} ❌")
        return False

# Function to add a URI to Aria2 (downloads a file)
async def add_uri_to_aria2(uri):
    payload = {
        "jsonrpc": "2.0",
        "method": "aria2.addUri",
        "id": "1",
        "params": [ARIA2_RPC_SECRET, [uri]],
    }
    response = requests.post(ARIA2_RPC_URL, json=payload)
    return response.json()

# Handle /start command (welcomes the user)
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("🚀 Welcome! Send me a download link to start. 🚀")

# Handle incoming messages (parse download link and add to Aria2)
async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    # Get the download link from the message
    message_text = update.message.text

    # Check if the username is allowed to access the bot
    if LIMIT_PERMISSION:
        user_username = update.message.from_user.username
        if user_username not in ALLOWED_USERNAMES:
            # Send message if the user is not allowed
            await update.message.reply_text(f"❌ Your access to this bot is restricted (username: {user_username})\nYou can request to have your username added to the Dloadbox server.")
            logger.error(f"Unauthorized access attempt by {user_username} ❌")
            return

    if not message_text.startswith("http"):
        await update.message.reply_text("❌ Please send a valid URL. ❌")
        return

    # Check if the URL is valid
    if not is_valid_url(message_text):
        await update.message.reply_text("❌ The link is not valid or cannot be downloaded. ❌")
        logger.error(f"Invalid URL attempted: {message_text} ❌")
        return

    # Add the URI to Aria2 for download
    response = await add_uri_to_aria2(message_text)
    if "result" in response:
        gid = response["result"]
        # Sending download success message
        success_message = f"✅ Download added successfully. GID: {gid} ✅"

        # Send the success message without any link
        await update.message.reply_text(success_message)

    elif "error" in response:
        await update.message.reply_text(f"❌ Error: {response['error']['message']} ❌")
        logger.error(f"Error adding URL to Aria2: {response['error']['message']} ❌")
    else:
        await update.message.reply_text("❌ An unknown error occurred. ❌")
        logger.error("Unknown error occurred while adding URL to Aria2. ❌")

# Main function to start the bot
def main():
    # Build the application and set up token
    app = ApplicationBuilder().token(BOT_TOKEN).build()

    # Add command handlers for /start command
    app.add_handler(CommandHandler("start", start))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.Regex(r"^/"), handle_message))

    # Run the bot continuously (polling)
    app.run_polling()

if __name__ == "__main__":
    main()
