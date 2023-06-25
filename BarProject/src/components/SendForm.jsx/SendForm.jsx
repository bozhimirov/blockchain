import React from "react";
import "./SendForm.css";
import { useWallets } from "@web3-onboard/react";

import { getBeerContract, getCoffeeContract } from "../../helpers";

const SendForm = () => {
  const connectedWallets = useWallets();

  const [message, setMessage] = React.useState(null);

  const handleSend = (e) => {
    e.preventDefault();
    let contract = getBeerContract(connectedWallets);

    const user = connectedWallets[0].accounts[0];
    contract
      .safeMint(user.address)
      .then((res) => {
        console.log(res);
        return res.wait();
      })
      .then((res) => {
        if (res.status === 1) {
          showMessage(
            `Cheers! You received a new digital Beer! To visualize the NFT add it to your MetaMask. Get the contract address from Status of your transaction. View on blockchain explorer and from ERC-721 Tokens Transferred: check the TokenID and contract address. Then add them to your MetaMask on section NFTs -> Import NFTs. Cheers!`
          );
        }

        if (res.status === 0) {
          showMessage("Failed!");
        }
      })
      .catch((err) => {
        console.log(err);
        showMessage(err.message);
      });
  };

  const handleSend2 = (e) => {
    e.preventDefault();
    let contract = getCoffeeContract(connectedWallets);

    const user = connectedWallets[0].accounts[0];
    contract
      .safeMint(user.address)
      .then((res) => {
        console.log(res);
        return res.wait();
      })
      .then((res) => {
        if (res.status === 1) {
          showMessage(
            `Cheers! You received a new digital Coffee! To visualize the NFT add it to your MetaMask. Get the contract address from Status of your transaction. View on blockchain explorer and from ERC-721 Tokens Transferred: check the TokenID and contract address. Then add them to your MetaMask on section NFTs -> Import NFTs. Cheers!`
          );
        }

        if (res.status === 0) {
          showMessage("Failed!");
        }
      })
      .catch((err) => {
        console.log(err);
        showMessage(err.message);
      });
  };

  function showMessage(message) {
    setMessage(message);
    setTimeout(() => {
      setMessage(null);
    }, 1000 * 30);
  }

  return (
    <>
      <div className="form-wrapper">
        <form className="send-form" onSubmit={handleSend}>
          <button type="submit">Send me a BeeR</button>
        </form>
        <form className="send-form" onSubmit={handleSend2}>
          <button type="submit">Send me a CoffeE</button>
        </form>
      </div>
      <div className="message">{message && <p>{message}</p>}</div>
    </>
  );
};

export default SendForm;
