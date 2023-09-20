require("dotenv").config()
const HDWalletProvider = require("@truffle/hdwallet-provider")
//
const fs = require("fs")
const mnemonic = fs.readFileSync(".secret").toString().trim()

module.exports = {
	plugins: ["truffle-plugin-verify"],
	api_keys: {
		bscscan: process.env.SCAN_API_KEY,
	},
	networks: {
		development: {
			host: "127.0.0.1",
			port: 8545,
			network_id: "*", // Match any network id
			gas: 5000000,
		},
		testnet: {
			provider() {
				return new HDWalletProvider(
					mnemonic,
					"https://data-seed-prebsc-1-s1.binance.org:8545/"
				)
			},
			network_id: 97,
		},
	},
	compilers: {
		solc: {
			version: "0.8.12",
			settings: {
				optimizer: {
					enabled: true, // Default: false
					runs: 200, // Default: 200
				},
			},
		},
	},
}
