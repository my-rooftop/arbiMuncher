import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.11",
  networks: {
    hardhat: {
      forking: {
        url: "https://rpc.ankr.com/arbitrum",
        blockNumber: 76600925,
      },
      blockGasLimit: 0x1fffffffffff,
      gasPrice: 0,
      initialBaseFeePerGas: 0,
      allowUnlimitedContractSize: true,
    },
    arbitrum: {
      url: `https://rpc.ankr.com/arbitrum`,
      accounts:
        process.env.privateKey !== undefined ? [process.env.privateKey] : [],
    },
  },
};

export default config;
