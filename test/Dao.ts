import { isCommunityResourcable } from "@ethersproject/providers";
import { expect } from "chai";
import { ethers, network } from "hardhat";
import { BigNumber } from "ethers";
const { parseEther } = ethers.utils;
const { MaxUint256 } = ethers.constants;



describe("Dao", function () {

  let acc1: any;

  let acc2: any;

  let acc3: any;

  let acc4: any;

  let token: any;

  let dao: any;

  beforeEach(async function() {
    [acc1, acc2, acc3, acc4] = await ethers.getSigners()

    // deploy ERC20 token
    const Erc20Token = await ethers.getContractFactory('Erc20Token', acc1)
    token = await Erc20Token.deploy("Pepelaz","PPLZ", parseEther("10000"))
    await token.deployed()  
    
    // deploy Dao contract
    const Dao = await ethers.getContractFactory('Dao', acc1)
    dao = await Dao.deploy(acc1.address, token.address, 3, 60*60*24*3)
    await dao.deployed()  

    token.mint(acc2.address, parseEther('10000'))
    token.connect(acc2).approve(dao.address, MaxUint256)

    token.mint(acc3.address, parseEther('10000'))
    token.connect(acc3).approve(dao.address, MaxUint256)

    token.mint(acc4.address, parseEther('10000'))
    token.connect(acc4).approve(dao.address, MaxUint256)
  })

  it("should be deployed", async function(){
     expect(dao.address).to.be.properAddress
  })

  it("test", async function(){
    let tx = await dao.connect(acc2).deposit(parseEther('100'))
    await tx.wait()

    tx = await dao.connect(acc3).deposit(parseEther('200'))
    await tx.wait()

    tx = await dao.connect(acc2).deposit(parseEther('200'))
    await tx.wait()

    tx = await dao.connect(acc4).deposit(parseEther('500'))
    await tx.wait()

    //--------

    tx = await dao.addProposal('function 1', 'description 1')
    await tx.wait()

    tx = await dao.addProposal('function 2', 'description 2')
    await tx.wait()

    tx = await dao.addProposal('function 3', 'description 3')
    await tx.wait()

    //--------

    tx = await dao.connect(acc2).vote('description 1')
    await tx.wait()

    tx = await dao.connect(acc2).vote('description 2')
    await tx.wait()

    tx = await dao.connect(acc3).vote('description 1')
    await tx.wait()

    tx = await dao.connect(acc3).vote('description 3')
    await tx.wait()

    tx = await dao.connect(acc4).vote('description 3')
    await tx.wait()

    //--------

    await network.provider.send("evm_increaseTime", [60*60*24*3]) 

    tx = await dao.finishProposal('description 1')
    await tx.wait()

 })
  
});