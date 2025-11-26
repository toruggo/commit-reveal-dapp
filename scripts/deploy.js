const hre = require("hardhat");

async function main() {
  const CommitReveal = await hre.ethers.getContractFactory("CommitReveal");

  const commitDuration = 3 * 60;  // 2 min de commit
  const revealDuration = 3 * 60;  // 2 min de reveal
  const maxChoice = 3;            // opções 1, 2 e 3

  const contract = await CommitReveal.deploy(
    commitDuration,
    revealDuration,
    maxChoice
  );

  await contract.waitForDeployment();

  console.log(`CommitReveal deployed to: ${await contract.getAddress()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
