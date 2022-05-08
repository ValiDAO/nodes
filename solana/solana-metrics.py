#!/usr/bin/env python3

import http.server
import json
import subprocess
import pathlib


BINARY_PATH = pathlib.Path("~/.local/share/solana/install/active_release/bin/solana").expanduser()
KEY_PATH = pathlib.Path("~/validator-keypair.json").expanduser()
VOTE_ACCOUNT_PATH = pathlib.Path("~/vote-account-keypair.json").expanduser()


class MyHandler(http.server.BaseHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        self.pubkey = subprocess.check_output(
            [BINARY_PATH, "address", "-k", KEY_PATH, "--output=json"],
        ).decode('ascii').strip()
        self.vote_pubkey = subprocess.check_output(
            [BINARY_PATH, "address", "-k", VOTE_ACCOUNT_PATH, "--output=json"],
        ).decode('ascii').strip()
        super(http.server.BaseHTTPRequestHandler, self).__init__(*args, **kwargs)

    def print_gauge(self, name, value):
        prefix = "solana_"
        self.wfile.write("# TYPE {2}{0} gauge\n{2}{0} {1}\n".format(name, value, prefix).encode("utf-8"))

    def do_GET(self):
        try:
            balance = self.get_balance()
            skip_rate, leader_slots = self.get_skip_rate()
            last_vote, root_slot, epoch_credits, activated_state, slot_delay, root_delay, version = self.get_slot_data()

            self.send_response(200)
            self.end_headers()
            self.print_gauge("balance", balance)
            self.print_gauge("skiprate", skip_rate)
            self.print_gauge("leader_slots", leader_slots)
            self.print_gauge("last_vote", last_vote)
            self.print_gauge("root_slot", root_slot)
            self.print_gauge("epoch_credits", epoch_credits)
            self.print_gauge("activated_stake", activated_state)
            self.print_gauge("slot_delay", slot_delay)
            self.print_gauge("root_delay", root_delay)
            self.print_gauge("version", version)

        except Exception as e:
            self.send_response(500)
            self.end_headers()
            self.wfile.write(str(e).encode("utf-8"))

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
           return 1.0, 1000.0  # 100% skip as this requires investigation
        my_leader_info = my_leader_info[0]
        skip_rate = my_leader_info["skippedSlots"] / my_leader_info["leaderSlots"]
        leader_slots = my_leader_info["leaderSlots"]
        return skip_rate, leader_slots

    def get_slot_data(self):
        validators = json.loads(subprocess.check_output(
            [BINARY_PATH, "validators", "--keep-unstaked-delinquents", "-ul", "--output=json"]
        ))
        my_data = [rec for rec in validators["validators"] if rec["identityPubkey"] == self.pubkey]
        max_known_vote = max(rec["lastVote"] for rec in validators["validators"])
        max_known_root = max(rec["rootSlot"] for rec in validators["validators"])
        if not my_data:
            return 0, 0, 0, 0, 10000, 10000, 0
        my_data = my_data[0]
        version_tuple = tuple(int(i) for i in my_data["version"].split("."))
        version = (version_tuple[0] * 100 + version_tuple[1]) * 100 + version_tuple[2]
        return my_data["lastVote"], my_data["rootSlot"], my_data["epochCredits"], my_data["activatedStake"], max_known_vote - my_data["lastVote"], max_known_root - my_data["rootSlot"], version

  
server = http.server.HTTPServer(('', 9114), MyHandler)
server.serve_forever()
