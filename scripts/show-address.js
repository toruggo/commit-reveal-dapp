const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with address:", await deployer.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
