const crypto = require('crypto');
const fs = require('fs');

const key = Buffer.from(process.env.BRIDGE_SECRET_KEY || 'ThisIsA32ByteBridgeKey___');
const data = {
  sender: 'CordaBankA',
  amount: '100000',
  swiftCode: 'MT103',
  reference: 'CDXFN-4234'
};

const encryptPayload = (payload) => {
  const cipher = crypto.createCipheriv('aes-256-ecb', key, null);
  const encrypted = Buffer.concat([
    cipher.update(JSON.stringify(payload), 'utf8'),
    cipher.final()
  ]);
  return encrypted.toString('base64');
};

const encrypted = encryptPayload(data);
console.log('🔐 Encrypted:', encrypted);
fs.writeFileSync('out/encryptedPayload.txt', encrypted);
