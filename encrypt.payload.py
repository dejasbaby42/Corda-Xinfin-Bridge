from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad
import base64, os, json

SECRET_KEY = os.getenv("BRIDGE_SECRET_KEY", "ThisIsA32ByteBridgeKey___").encode()

def encrypt_data(payload: dict) -> str:
    plaintext = json.dumps(payload).encode('utf-8')
    cipher = AES.new(SECRET_KEY, AES.MODE_ECB)
    ciphertext = cipher.encrypt(pad(plaintext, AES.block_size))
    return base64.b64encode(ciphertext).decode()

def decrypt_data(encoded: str) -> dict:
    cipher = AES.new(SECRET_KEY, AES.MODE_ECB)
    decrypted = unpad(cipher.decrypt(base64.b64decode(encoded)), AES.block_size)
    return json.loads(decrypted.decode())

if __name__ == "__main__":
    data = {
        "sender": "CordaBankA",
        "amount": "100000",
        "swiftCode": "MT103",
        "reference": "CDXFN-4234"
    }

    encrypted = encrypt_data(data)
    print("🔐 Encrypted Payload:", encrypted)

    with open("out/encrypted_payload.txt", "w") as f:
        f.write(encrypted)
