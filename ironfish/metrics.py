#!/usr/bin/env python3

import http.server
import subprocess
import re
import os


HEIGHT_EXTRACTOR = re.compile(r"^Blockchain\s+([A-Z]+).*\((\d+)\)$", re.DOTALL | re.MULTILINE)
MINING_STATUS_EXTRACTOR = re.compile(r"^Mining\s+([A-Z]+).*(\d+) mined$", re.DOTALL | re.MULTILINE)
VERSION_EXTRACTOR = re.compile(r"^Version\s+(\d+)[.](\d+)[.](\d+)", re.DOTALL | re.MULTILINE)


class MyHandler(http.server.BaseHTTPRequestHandler):
    def print_gauge(self, name, value):
        prefix = "ironfish_"
        self.wfile.write("# TYPE {2}{0} gauge\n{2}{0} {1}\n".format(name, value, prefix).encode("utf-8"))

    def do_GET(self):
        try:
            status, height, mining_status, mined, version = self.get_status_and_height()
            self.send_response(200)
            self.end_headers()
            self.print_gauge("status", status)
            self.print_gauge("height", height)
            self.print_gauge("mining_status", mining_status)
            self.print_gauge("mined", mined)
            self.print_gauge("version", version)
        except Exception as e:
            self.send_response(500)
            self.end_headers()
            self.wfile.write(str(e).encode("utf-8"))

    def get_status_and_height(self):
        proc = subprocess.Popen(
            ["/usr/bin/yarn", "start:once", "status"],
            stdout=subprocess.PIPE,
            cwd=f"{{ ansible_facts['env']['HOME'] }}/ironfish/ironfish-cli"
        )
        stdout, _ = proc.communicate()
        lines = stdout.decode("utf-8")
        status = "0"
        height = "0"
        mined = "0"
        mining_status = "0"
        version = "0"

        match_obj = HEIGHT_EXTRACTOR.search(lines)
        if match_obj:
            status = "1" if match_obj.group(1) == 'SYNCED' else "0"
            height = match_obj.group(2)
        match_obj = MINING_STATUS_EXTRACTOR.search(lines)
        if match_obj:
            mining_status = "1" if match_obj.group(1) == 'STARTED' else "0"
            mined = match_obj.group(2)
        match_obj = VERSION_EXTRACTOR.search(lines)
        if match_obj:
            version = (int(match_obj.group(1)) * 100 + int(match_obj.group(2))) * 100 + int(match_obj.group(3))
        return status, height, mining_status, mined, version


server = http.server.HTTPServer(('', 9113), MyHandler)
server.serve_forever()
