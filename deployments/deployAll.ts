import { ethers, run } from "hardhat";
import * as fs from "fs";
import * as path from "path";
import dotenv from "dotenv";

dotenv.config();

async function deployContract(name: string, args: any[] = []) {
  const factory = await ethers.getContractFactory(name);
  const contract = await factory.deploy(...args);
  await contract.deployed();
  console.log(`✅ ${name} deployed at ${contract.address}`);
  return contract.address;
}

async function main() {
  const network = process.env.NETWORK || "localnet";

  const deployments: Record<string, any> = {};

  deployments["XinfinBridge"] = await deployContract("XinfinBridge");
  deployments["MultiAssetSwap"] = await deployContract("MultiAssetSwap");
  deployments["CrossChainLiquidityPool"] = await deployContract("CrossChainLiquidityPool");
  deployments["EncryptedDataMap"] = await deployContract("EncryptedDataMap");
  deployments["RelayerBridge"] = await deployContract("RelayerBridge");
  deployments["VotingMechanism"] = await deployContract("VotingMechanism");

  const filePath = path.join(__dirname, "..", "contracts", "deployed-addresses.json");

  const currentData = fs.existsSync(filePath) ? JSON.parse(fs.readFileSync(filePath", "utf8")) : {};

  const updated = {
    ...currentData,
    ...Object.fromEntries(Object.entries(deployments).map(([k, v]) => [k, { [network]: v }]))
  };

  fs.writeFileSync(filePath, JSON.stringify(updated, null, 2));
  console.log("📁 Deployment addresses saved to deployed-addresses.json");
}

main().catch((error) => {
  console.error("🚨 Deployment failed:", error);
  process.exit(1);
});
