import { ethers } from "ethers";
import { ERC20_ABI_beer, ERC20_ADDRESS_beer, ERC20_ABI_coffee, ERC20_ADDRESS_coffee } from "../constants";

export function formatEthAddress(address) {
  if (!address || address.length < 8) {
    return "";
  }

  const firstFive = address.slice(0, 5);
  const lastFour = address.slice(-4);

  return `${firstFive}...${lastFour}`;
}

export function getBeerContract(connectedWallets) {
  const injectedProvider = connectedWallets[0].provider;
  const provider = new ethers.providers.Web3Provider(injectedProvider);
  const signer = provider.getSigner();
  return new ethers.Contract(ERC20_ADDRESS_beer, ERC20_ABI_beer, signer);
}

export function getCoffeeContract(connectedWallets) {
  const injectedProvider = connectedWallets[0].provider;
  const provider = new ethers.providers.Web3Provider(injectedProvider);
  const signer = provider.getSigner();
  return new ethers.Contract(ERC20_ADDRESS_coffee, ERC20_ABI_coffee, signer);
}
