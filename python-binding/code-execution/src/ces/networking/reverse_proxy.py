"""Reverse proxy module
"""

from ces.networking import packet
import json


class ReverseProxy:
    """Reverse proxy provider

    Provides a reverse proxy for routing
    packets to the handlers based on the
    URL and type

    Attributes:
        route_mapping (dict): A mapping for url and methods
    """

    def __init__(self):
        self.route_mapping = {
            "/net": {
                "shutdown": self.pong_packet,
                "ping:pong": self.pong_packet,
            },
        }

    def add_service(self, service_url):
        """Adds a URL to the route mapping

        Notes:
            does nothing if URL already exists

        Args:
            service_url (str): URL to add
        """

        if service_url not in self.route_mapping:
            self.route_mapping[service_url] = {}

    def remove_service(self, service_url):
        """Removes a URL from the route mapping

        Notes:
            does nothing if URL don't exist

        Args:
            service_url (str): URL to remove
        """

        if service_url in self.route_mapping:
            self.route_mapping.pop(service_url)

    def set_method(self, service_url, method_name, method_handler):
        """Sets a method in the given service with a handler

        Args:
            service_url (str): Service URL to add the method to
            method_name (str): Name of the method to set
            method_handler (func): A function to handle a packet.
                    The handler will only be provided the packet in
                    the first arugment

        Raises:
            KeyError: If the service URL doesn't exist
        """

        if service_url not in self.route_mapping:
            raise KeyError(f"URL '{service_url}' not found")
        self.route_mapping[service_url][method_name] = method_handler

    def remove_method(self, service_url, method_name):
        """Remove a method from the given service

        Args:
            service_url (str): The service URL to remove the method from
            method_name (str): Name of the method to remove

        Raise:
            KeyError: If service URL doesn't exist, or method doesn't exist
        """

        if service_url not in self.route_mapping:
            raise KeyError(f"URL '{service_url}' not found")
        self.route_mapping[service_url].pop(method_name)

    def pong_packet(self, pkt):
        """Builds a response packet with the same data

        Builds a response packet with the same content,
        URL, and type with a 200 Ok code. Useful for
        debugging

        Args:
            pkt (Packet): Packet to pong back

        Returns:
            dict: The response packet
        """

        return packet.build_packet(
                pkt["url"], pkt["headers"]["p-type"], 200,
                json.loads(pkt["content"]))

    # Route packet to the target handler by type
    def route_packet(self, pkt_json):
        """Route a packet to a handler

        Args:
            pkt_json (Packet): Packet to route

        Returns:
            Packet: If URL and method exists, returns the handler's response.
            If URL doesn't exists, returns a 404 with `URL not found`.
            If Method doesn't exists, returns a 404 with `Method not found`.
        """

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
