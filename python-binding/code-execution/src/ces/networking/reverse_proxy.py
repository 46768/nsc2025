from ces.networking import packet
import json


class ReverseProxy:
    def __init__(self):
        self.route_mapping = {
            "/net": {
                "shutdown": self.pong_packet,
                "ping:pong": self.pong_packet,
            },
        }

    def add_service(self, service_url):
        if service_url not in self.route_mapping:
            self.route_mapping[service_url] = {}

    def remove_service(self, service_url):
        if service_url in self.route_mapping:
            self.route_mapping.pop(service_url)

    def set_method(self, service_url, method_name, method_handler):
        if service_url not in self.route_mapping:
            raise KeyError(f"URL '{service_url}' not found")
        self.route_mapping[service_url][method_name] = method_handler

    def remove_method(self, service_url, method_name):
        if service_url not in self.route_mapping:
            raise KeyError(f"URL '{service_url}' not found")
        self.route_mapping[service_url].pop(method_name)

    def pong_packet(self, pkt):
        return packet.build_packet(
                pkt["url"], pkt["headers"]["p-type"], 200,
                json.loads(pkt["content"]))

    # Route packet to the target handler by type
    def route_packet(self, pkt_json):
        pkt_type = str(pkt_json["headers"]["p-type"])
        pkt_url = str(pkt_json["url"])

        if pkt_url not in self.route_mapping:
            packet.log_packet_issue("Bad URL", pkt_json)
            return packet.build_packet(pkt_url, "notfound:url", 404, {
                "msg": "URL not found"
            })

        if pkt_type not in self.route_mapping[pkt_url]:
            packet.log_packet_issue("Bad Method", pkt_json)
            return packet.build_packet(pkt_url, "notfound:method", 404, {
                "msg": "Method not found"
            })

        return self.route_mapping[pkt_url][pkt_type](pkt_json)
