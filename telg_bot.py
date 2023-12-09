#!/usr/bin/python3

# This script uses the Telegram Bot API to send updates 
# to a group with the specified chat_id

import requests
import sys

method  = 'sendMessage'

# Get the token for Telegram Bot
with open('conf/telg_token', 'r') as token_file:
    token = token_file.read()
    token = token[:-1]

# Get the Telegram Chat ID
with open('conf/telg_chatid', 'r') as chatid_file:
    chat_id = chatid_file.read()
    chat_id = chat_id[:-1]

def post_msg(text_data,_token=token,_method=method,_chat_id=chat_id):
    response = requests.post(
            url='https://api.telegram.org/bot{0}/{1}'.format(_token,_method),
            data={'chat_id': _chat_id, 'text': text_data}
        ).json()

    print(response)

message = sys.argv[1]
message = message.replace('\\n', '\n')

post_msg(message)

