#!/usr/bin/env python3

import http.server
import json
import subprocess


BINARY_PATH = "HOME/.local/share/solana/install/active_release/bin/solana"
KEY_PATH = "HOME/validator-keypair.json"
VOTE_ACCOUNT_PATH = "HOME/vote-account-keypair.json"



class MyHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if not hasattr(self, 'pubkey'):
            self.pubkey = subprocess.check_output(
                [BINARY_PATH, "address", "-k", KEY_PATH, "--output=json"],
            ).decode('ascii').strip()
        if not hasattr(self, 'vote_pubkey'):
            self.vote_pubkey = subprocess.check_output(
                [BINARY_PATH, "address", "-k", VOTE_ACCOUNT_PATH, "--output=json"],
            ).decode('ascii').strip()

        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"# TYPE solana_balance gauge\n")
        self.wfile.write(b"solana_balance ")
        self.wfile.write(str(self.get_balance()).encode("utf-8"))
        self.wfile.write(b"\n")

        skip_rate, delinquent, leader_slots = self.get_skip_rate()
        self.wfile.write(b"# TYPE solana_skiprate gauge\n")
        self.wfile.write(b"solana_skiprate ")
        self.wfile.write(str(skip_rate).encode("utf-8"))
        self.wfile.write(b"\n")
        self.wfile.write(b"# TYPE solana_delinquent gauge\n")
        self.wfile.write(b"solana_delinquent ")
        self.wfile.write(str(delinquent).encode("utf-8"))
        self.wfile.write(b"\n")
        self.wfile.write(b"# TYPE solana_leader_slots gauge\n")
        self.wfile.write(b"solana_leader_slots ")
        self.wfile.write(str(leader_slots).encode("utf-8"))
        self.wfile.write(b"\n")

    def get_balance(self):
        balance_data = float(subprocess.check_output(
            [BINARY_PATH, "balance", "-ul", self.pubkey, "--output=json"]
        ).decode('ascii').split()[0].strip())
        return balance_data

    def get_skip_rate(self):
        block_data = json.loads(subprocess.check_output(
            [BINARY_PATH, "block-production", "-ul", "--output=json"]
        ))

        my_leader_info = [li for li in block_data["leaders"] if li["identityPubkey"] == self.pubkey]
        if not my_leader_info:
           return 0.0, 0.0, 0.0  # 100% skip as this requires investigation
        my_leader_info = my_leader_info[0]
        skip_rate = my_leader_info["skippedSlots"] / my_leader_info["leaderSlots"]
        delinquent = 1.0 if my_leader_info["delinquent"] else 0.0
        leader_slots = my_leader_info["leaderSlots"]
        return skip_rate, delinquent, leader_slots

    def get_credits(self):
        block_data = json.loads(subprocess.check_output(
            [BINARY_PATH, "block-production", "-ul", "--output=json"]
        ))

  
server = http.server.HTTPServer(('', 9114), MyHandler)
server.serve_forever()
