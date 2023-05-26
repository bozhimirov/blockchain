import logo from "./logo.svg";
import "./App.css";

import { ethers } from "ethers";
import MyButton from "./components/MyButton";

import { useEffect, useState } from "react";

function App() {
  // declare state variable
  const [count, setCount] = useState(0);
  const [currentAccount, setCurrentAccount] = useState(null);
  const [provider, setProvider] = useState(null);
  const [blockNumber, setBlockNumber] = useState(null);
  const [accountBalance, setAccountBalance] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(false);

  //
  useEffect(() => {
    if (localStorage.getItem("connected")) {
      handleConnection();
    }
  }, []);

  //If count == 0 nothing happens, but the first time count is not 0, the handleConnection function is executed

  // useEffect(() => {
  //   if (count != 0) {
  //     handleConnection();
  //   }
  // }, [count]);

  function handleClick() {
    //update the state variable value
    setCount(count + 1);
  }

  function sendTransaction() {
    const signer = provider.getSigner();
    //Send 1 ether to an address
    // const tx = signer.sendTransaction({
    // // ENS not supported in local networking mode
    //   to: "<address>",
    //   value: ethers.utils.parseEther("1.0"),
    setLoading(true);
    signer
      .sendTransaction({
        to: "0x6F99eE21d845F833749DD420C48122FA0DB04275",
        value: ethers.utils.parseEther("1.0"),
      })
      .then((tx) => {
        console.log(tx);
        return tx.wait();
      })
      .then((receipt) => {
        setError("success!");
      })
      .catch((e) => {
        setError(e.message);
      })
      .finally(() => {
        setLoading(false);
      });
  }

  function handleConnection() {
    if (!window.ethereum) {
      alert("install MetaMask");
      return;
    }

    //A Web3Provider wraps a standart Web3 provider, which is what MetaMask injects as window.ethereum into each page
    const newProvider = new ethers.providers.Web3Provider(window.ethereum);

    newProvider
      .send("eth_requestAccounts", [])
      .then((accounts) => {
        if (accounts.length > 0) setCurrentAccount(accounts[0]);
        localStorage.setItem("connected", true);

        setProvider(newProvider);
      })
      .catch((e) => console.log(e));
  }

  function getBlockNumber() {
    if (!provider || !currentAccount) {
      alert("Connect first");
      return;
    }

    //Look up the current block number
    provider.getBlockNumber().then((blockNumber) => {
      console.log("Current block number: " + blockNumber);
      console.log(blockNumber);
      setBlockNumber(blockNumber);
    });
  }
  function getAccountBalance() {
    if (!provider || !currentAccount) {
      alert("Connect first");
      return;
    }
    //Look up the current account balance
    provider.getBalance(currentAccount).then((accountBalance) => {
      // console.log("Current account balance: " + accountBalance);
      console.log(accountBalance);
      //represented with wei
      setAccountBalance(accountBalance);
      // console.log(accountBalance);
      //represented with ether
      // setAccountBalance(ethers.utils.formatEther(accountBalance));
    });
  }

  return (
    <>
      <div className="App">
        <MyButton buttonClicked={handleClick} count={count} />
        <MyButton buttonClicked={handleClick} count={count} />
        <button onClick={handleConnection}>Connect</button>
      </div>
      <div></div>
      {/* {currentAccount && <h1>{currentAccount}</h1>} */}
      {currentAccount ? <h1>{currentAccount}</h1> : <h1>Not connected</h1>}
      {provider ? (
        <button onClick={getBlockNumber}>Get Block Number</button>
      ) : (
        <h1>Not connected</h1>
      )}
      {provider ? (
        <button onClick={getAccountBalance}>Get Account Balance</button>
      ) : (
        <h1>Not connected</h1>
      )}
      {/* {blockNumber != null ? <h1>{blockNumber}</h1> : <h1>Not connected</h1>} */}
      {blockNumber != null && <h1>{blockNumber.toString()}</h1>}
      {accountBalance != null && (
        <h1>
          {ethers.utils.formatEther(accountBalance.toString()) + " Ethers"}
        </h1>
      )}
      {accountBalance != null && <h1>{accountBalance.toString() + " Wei"}</h1>}
      {accountBalance != null && (
        <h1>
          {ethers.utils.parseEther(
            ethers.utils.formatEther(accountBalance.toString())
          ) + " Wei"}
        </h1>
      )}
      <button onClick={sendTransaction}>sendTransaction</button>

      {loading && <h1>Loading ...</h1>}
      {error}
    </>
  );
}

export default App;
