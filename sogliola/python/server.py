from socket import AF_INET, socket, SOCK_STREAM
from threading import Thread
from time import sleep
import random


clients = []
freeClients = []
addresses = {}

HOST = ''
PORT = 33000
BUFSIZ = 1024
ADDR = (HOST, PORT)

SERVER = socket(AF_INET, SOCK_STREAM)
SERVER.bind(ADDR)

matches = []

def accept_incoming_connections():
    """Sets up handling for incoming clients."""
    while True:
        client, client_address = SERVER.accept()
        print("%s:%s has connected." % client_address)
        addresses[client] = client_address
        Thread(target=handle_client, args=(client,)).start()


# +============================================================================+
# | CLIENT MANAGEMENT THREAD                                                   |
# +============================================================================+
# This thread is started whenever a client joins the server.
# The argument is the client socket
def handle_client(client): 
    client.send(bytes("welcome", "utf8"))
    msg = client.recv(BUFSIZ)
    print(msg.decode("utf8"))
    clients.append(client)
    freeClients.append(client)


    # Waiting to enter in a match ----------------------------------------------
    while True:
        sleep(0.1)
        inMatch = False
        for match in matches:
            if match[0] == client:
                opponent = match[1]
                inMatch = True
                break
            if match[1] == client:
                opponent = match[0]
                inMatch = True
                break
        if inMatch: break

    # Match mode ---------------------------------------------------------------
    # The main server thread put me into a match. From now on, I am in match
    # mode. The variable opponent has been set with the opponent socket.
    # The only functionality in this mode is to forward messages from my
    # client to my opponent
    while True:
        msg = client.recv(BUFSIZ)
        opponent.send(msg)
        msg = msg.decode("utf8")

        if msg == "quit":
            print("client %s:%s disconnected" % addresses[client])
            break



# +============================================================================+
# | Main Server                                                                |
# +============================================================================+
if __name__ == "__main__":
    SERVER.listen(5)
    print(f"Waiting for connection on port {PORT}...")
    ACCEPT_THREAD = Thread(target=accept_incoming_connections)
    ACCEPT_THREAD.start()

    # Matchmaking
    while True:
        sleep(5)
        if len(freeClients) >= 2:
            # Start a new match: determine [TODO: the seed and] the first player
            firstPlayer = 1 if random.uniform(0, 1) > 0.5 else 0
            freeClients[firstPlayer].send(bytes("match_start,0","utf-8"))
            freeClients[1-firstPlayer].send(bytes("match_start,1","utf-8"))
            matches.append( (freeClients[0],freeClients[1]) )
            freeClients = freeClients[2:]
    #ACCEPT_THREAD.join()
    SERVER.close()