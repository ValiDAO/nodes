#!/usr/bin/env python3

import http.server
import json
import subprocess


BINARY_PATH = "HOME/.local/share/solana/install/active_release/bin/solana"
KEY_PATH = "HOME/validator-keypair.json"



class MyHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if not hasattr(self, 'pubkey'):
            self.pubkey = subprocess.check_output(
                [BINARY_PATH, "address", "-k", KEY_PATH, "--output=json"],
            ).decode('ascii').strip()

        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"# TYPE solana_balance gauge\n")
        self.wfile.write(b"solana_balance ")
        self.wfile.write(str(self.get_balance()).encode("utf-8"))
        self.wfile.write(b"\n")

        self.wfile.write(b"# TYPE solana_skiprate gauge\n")
        self.wfile.write(b"solana_skiprate ")
        self.wfile.write(str(self.get_skip_rate()).encode("utf-8"))
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
           return 1.0  # 100% skip as this requires investigation
        my_leader_info = my_leader_info[0]
        skip_rate = my_leader_info["skippedSlots"] / my_leader_info["leaderSlots"]
        return skip_rate

  
server = http.server.HTTPServer(('', 9114), MyHandler)
server.serve_forever()
