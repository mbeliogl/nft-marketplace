import React, {Component} from 'react';
import Web3 from 'web3';
import detectEthereumProvider from '@metamask/detect-provider';
import KryptoBird from '../abis/KryptoBird.json';
import {MDBCard, MDBCardBody, MDBCardText, MDBCardTitle, MDBCardImage, MDBBtn} from 'mdb-react-ui-kit';
import './App.css';

class App extends Component {

    //checking if the web3 provider is accessible 
    async componentDidMount(){
        await this.loadWeb3();
        await this.loadBlockChainData();
    }

    //first step is detecting an ethereum provider 
    async loadWeb3() {
        const provider = await detectEthereumProvider();

        //checking for modern browsers 
        //setting provider for page (window)
        if(provider){
            console.log("ETH Wallet is Connected");
            window.web3 = new Web3(provider);
        } else{
            console.log("No ETH Wallet Detected")
        }
    }

    async loadBlockChainData() {
        const web3 = window.web3; 
        const accounts = await window.ethereum.request({method: 'eth_requestAccounts'});
        this.setState({account: accounts[0]});

        //***loading contract data to front end***
        const networkId = await web3.eth.net.getId();
        const networkData = KryptoBird.networks[networkId]; //from ABI

        //sett interface (abi) and address 
        //setting contract as a variable using abi and address 
        if(networkData) {
            const abi = KryptoBird.abi;
            const address = networkData.address;
            const contract = new web3.eth.Contract(abi, address);
            this.setState({contract});

            //call totalSupply() of KyrptoBirdz 
            const totalSupply = await contract.methods.totalSupply().call();
            this.setState({totalSupply})
            console.log(this.state.totalSupply)

            //array to keep track of tokens. Loading our KryptoBirdz on front end 
            //updating the state array
            for(let i = 1; i <= totalSupply; i++){
                const KB = await contract.methods.kryptoBirdz(i-1).call();
                
                //using a spread operator '...'
                this.setState({
                    kryptoBirdz: [...this.state.kryptoBirdz, KB] 
                })
            }
        } else{
            window.alert("ERROR: Smart Contract Not Deployed!")
        }
    }

    //minting function requires the from: address 
    mint = (kryptoBird) => {
        this.state.contract.methods.mint(kryptoBird).send({from: this.state.account})
        .once('receipt', (receipt) =>{ //we want this to execute once and sing off immediately
            this.setState({
                kryptoBirdz: [...this.state.kryptoBirdz, kryptoBird] 

            })
    })
    }

    //initializing constructor to set states of the contract 
    constructor(props) {
        super(props); //allows entire component to access the props of parent class with this.props 
        this.state = {
            account: '',
            contract: null, 
            totalSupply: 0,
            kryptoBirdz: []
        }
    }

    render() {
        return (

            <div className="container-filled">
                {console.log(this.state.kryptoBirdz)}
                <nav className="navbar navbar-dark fixed-top bg-dark flex-md-nowrap p-0 shadow">
                <div className="navbar-brand col-sm-3 col-md-3 mr-0" style={{color: 'white'}}>
                    KryptoBirdz NFT
                </div>
                
                <ul className="navbar-nav px-3">
                    <li className="nav-item text-nowrap d-none d-sm-none d-sm-block">
                        <small className="text-white"> Account: {this.state.account}</small>
                    </li>
                </ul>

                </nav>

                <div className="container-fluid mt-top-1">
                    <div className="row">
                        <main role="main" className="col-lg-12 d-flex text-center">
                            <div className="content mr-auto ml-auto" style={{opacity: 0.8}}>
                                <h1 style={{color: 'black'}}>KryptoBirdz NFT Marketplace</h1>

                                <form onSubmit={(event)=>{
                                    event.preventDefault();
                                    const kryptoBird = this.kryptoBird.value;
                                    this.mint(kryptoBird);
                                }}>

                                    <input 
                                        type="text" placeholder="Add a file location" className="form-control mb-1"
                                        ref={(input) => this.kryptoBird = input}
                                    />
                                    <input type="submit" className="btn btn-primary btn-black" value="MINT"/>

                                </form>

                            </div>
                        </main>
                    </div>
                        <hr/>

                        <div className="row text-center">
                            {this.state.kryptoBirdz.map((kryptoBird, key) => {
                                return(
                                    <div>
                                        <div>
                                            <MDBCard className="token img" style={{maxWidth: "22rem"}}>
                                                <MDBCardImage src={kryptoBird} position="top" height="250rem" style={{marginRight: "4px"}} />
                                                <MDBCardBody>
                                                    <MDBCardTitle> KryptoBirdz </MDBCardTitle>
                                                    <MDBCardText> KryptoBirdz are 20 cool creatures from the planet Tralfamadore. 
                                                        They are unique as there is only one of each bird. 
                                                        And each bird can only be owned by a single individual on the ETH blockchain. </MDBCardText>
                                                    <MDBBtn href={kryptoBird}> Download </MDBBtn>
                                                </MDBCardBody>
                                            </MDBCard>

                                        </div>
                                    </div>
                                )
                            })
                        }


                        </div>



                </div>

            </div>
        )
    }
}

export default App; 

