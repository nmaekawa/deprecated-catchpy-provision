# generates a jwt token for catchpy requests, that expires in 60 sec
# run from catchpy venv cause it requires catchpy.consumer.catchjwt package

import sys
from consumer.catchjwt import encode_catchjwt

def usage():
    print('{} <api_key> <secret_key> <user_in_payload>'.format(sys.argv[0]))
    exit(0)


if len(sys.argv) != 4:
    usage()

token_enc = encode_catchjwt(
    apikey=sys.argv[1],
    secret=sys.argv[2],
    user=sys.argv[3])
print('{}'.format(
    token_enc.decode('utf-8') if type(token_enc) == type(b'') else token_enc))
