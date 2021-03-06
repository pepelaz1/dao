
import { expect } from "chai";
import { ethers, network } from "hardhat";
const { parseEther } = ethers.utils;
const { MaxUint256 } = ethers.constants;


describe("Dao", function () {

  let acc1: any;

  let acc2: any;

  let acc3: any;

  let acc4: any;

  let token: any;

  let test: any;

  let dao: any;

  //beforeEach(async function() {
  step('init', async function() {
    [acc1, acc2, acc3, acc4] = await ethers.getSigners()

    // deploy ERC20 token
    const Erc20Token = await ethers.getContractFactory('Erc20Token', acc1)
    token = await Erc20Token.deploy("Pepelaz","PPLZ", parseEther("10000"))
    await token.deployed()  
    
    // deploy test contract
    const Test = await ethers.getContractFactory('Test', acc1)
    test = await Test.deploy()
    await test.deployed()  

    // deploy Dao contract
    const Dao = await ethers.getContractFactory('Dao', acc1)
    dao = await Dao.deploy(token.address, parseEther('400'), 60*60*24*3)
    await dao.deployed()  

    await dao.grantRole(await dao.CHAIRMAN_ROLE(), acc1.address)
    
    token.mint(acc2.address, parseEther('10000'))
    token.connect(acc2).approve(dao.address, MaxUint256)

    token.mint(acc3.address, parseEther('10000'))
    token.connect(acc3).approve(dao.address, MaxUint256)

    token.mint(acc4.address, parseEther('10000'))
    token.connect(acc4).approve(dao.address, MaxUint256)
  });

  step('deposit', async function() {
    let tx = await dao.connect(acc2).deposit(parseEther('100'))
    await tx.wait()

    tx = await dao.connect(acc3).deposit(parseEther('200'))
    await tx.wait()

    tx = await dao.connect(acc2).deposit(parseEther('200'))
    await tx.wait()

    tx = await dao.connect(acc4).deposit(parseEther('500'))
    await tx.wait()
  });

  step('add proposals', async function() {
    var abi1 =    [  {
      "inputs": [],
      "name": "sample",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
     }
    ];

    const calldata1 = new ethers.utils.Interface(abi1).encodeFunctionData('sample',[]);
  
    let tx = await dao.addProposal(test.address, calldata1, 'description 1')
    await tx.wait()

    tx = await dao.addProposal(test.address, calldata1, 'description 2')
    await tx.wait()

    var abi2 =    [  {
      "inputs": [],
      "name": "sampleRevert",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
     }
    ];

    const calldata2 = new ethers.utils.Interface(abi2).encodeFunctionData('sampleRevert',[]);

    tx = await dao.addProposal(test.address, calldata2, 'description 3')
    await tx.wait()
  });
  
  step('vote', async function() {
    let tx = await dao.connect(acc2).vote(0)
    await tx.wait()

    tx = await dao.connect(acc2).vote(1)
    await tx.wait()

    tx = await dao.connect(acc3).vote(0)
    await tx.wait()

    tx = await dao.connect(acc3).vote(2)
    await tx.wait()

    tx = await dao.connect(acc4).vote(2)
    await tx.wait()

    await expect(dao.connect(acc2).vote(0)).to.be.revertedWith("already voted")
  });

  step('finish', async function() {
    await expect(dao.finishProposal(0)).to.be.revertedWith("proposal is not over yet")

    await expect(dao.connect(acc2).withdraw()).to.be.revertedWith("not all proposals are over")

    await network.provider.send("evm_increaseTime", [60*60*24*3]) 

    let tx = await dao.finishProposal(0)
    await tx.wait()

    await expect(dao.finishProposal(0)).to.be.revertedWith("can't finish proposal twice")

    tx = await dao.finishProposal(1)
    await tx.wait()

    tx = await dao.connect(acc2).withdraw()
    await tx.wait()

    expect(await token.balanceOf(acc2.address)).to.equal(parseEther("10000"))

    await expect(dao.finishProposal(2)).to.be.revertedWith("test revert")

    await expect(test.sampleRevert()).to.be.revertedWith("test revert")
  });
});

