
import { ethers } from "hardhat";

async function main() { 

  const Dao = await ethers.getContractFactory("Dao");
  const dao = await Dao.deploy();
  await dao.deployed();

  console.log("Dao deployed to:", dao.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
