import { isCommunityResourcable } from "@ethersproject/providers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { BigNumber } from "ethers";
const { parseEther } = ethers.utils;



describe("Dao", function () {

  let acc1: any;

  let acc2: any;

  let acc3: any;

  let token: any;

  let dao: any;

  beforeEach(async function() {
    [acc1, acc2, acc3] = await ethers.getSigners()

    // deploy ERC20 token
    const Erc20Token = await ethers.getContractFactory('Erc20Token', acc1)
    token = await Erc20Token.deploy("Pepelaz","PPLZ", ethers.utils.parseEther("10000"))
    await token.deployed()  
    
    // deploy Dao contract
    const Dao = await ethers.getContractFactory('Dao', acc1)
    dao = await Dao.deploy(token.address)
    await dao.deployed()  

   
  })

  it("should be deployed", async function(){
     expect(dao.address).to.be.properAddress
  })
  
});