const {assert} = require('chai');

const KryptoBird = artifacts.require("./KryptoBird");

//check for chai 
require('chai')
.use(require('chai-as-promised'))
.should()


contract('KryptoBird', (accounts) => {

    let contract;
    //before - tells our test to run this first before anything else 
    before( async () => {
        contract = await KryptoBird.deployed();
    })

    //testing contrainer - describe
    describe('deployment', async () => {

        //test samples with writing 'it'
        it("deploys the contract", async () => {
            const address = await contract.address;

            assert.notEqual(address, '');
            assert.notEqual(address, null);
            assert.notEqual(address, undefined);
            assert.notEqual(address, 0x0);

        }),

        it("sets name and symbol", async () => {
            const name = await contract.name();
            const symbol = await contract.symbol();

            assert.equal(name, "KryptoBird");
            assert.equal(symbol, "KBIRDZ");

        })
    })

    //testing the minting function 
    describe('minting', async () => {
        it('creates a new token', async () => {
            const result = await contract.mint('https...1');
            const totalSupply = await contract.totalSupply();
            const event = result.logs[0].args;

            //Success
            assert.equal(event._from, '0x0000000000000000000000000000000000000000', "from is the contract address");
            assert.equal(event._to, accounts[0], "to is the message sender");
            assert.equal(totalSupply, 1);

            //Failure 
            await contract.mint('https...1').should.be.rejected;

        })
    })

    //test indexing functionality of the contract
    describe('indexing', async () => {
        it('lists the minted KryptoBirds', async () => {
            await contract.mint('https...2');
            await contract.mint('https...3');
            await contract.mint('https...4');

            const totalSupply = await contract.totalSupply();

            //loop through minted tokens and dispay them 
            let result = [];
            let KB; 
            for(i = 0; i < totalSupply; i++){
                KB = await contract.kryptoBirdz(i);
                result.push(KB);
            }

            //assert that the result array is equal to the kryptoBirdz array 
            let expected = ['https...1','https...2','https...3','https...4'];
            assert.equal(result.join(','), expected.join(','));

        })
    })

})