import { ethers, JsonRpcProvider } from 'ethers'
import contractABI from './contractABI.json'
import * as functions from 'firebase-functions';

export const scheduledMinting = async (): Promise<void> => {
  // Initialize Ethereum provider
  // const provider = new JsonRpcProvider('YOUR_PROVIDER_URL')
  const provider = new JsonRpcProvider('https://rpc-mumbai.maticvigil.com/')

  // Initialize wallet (for now using a private key, replace this later with a more secure method)
  const wallet = new ethers.Wallet('4363859ee8d14578ad38cb7950c5f32824063652667f309000ca1617d8b27910', provider)

  // Initialize contract interface
  // const contract = new ethers.Contract('YOUR_CONTRACT_ADDRESS', 'YOUR_CONTRACT_ABI', wallet)
  const contract = new ethers.Contract('0x3beed2e7551cf76d0012d686aacc291b324526f0', contractABI, wallet)

  try {
    // Mint tokens (replace 'TO_ADDRESS' and 'AMOUNT' with actual values)
    // const tx = await contract.mint('TO_ADDRESS', 'AMOUNT')
    const tx = await contract.mint('0x281D8424A948b5535F51B2BF033a95aD9EE991Fb', '1000000000000000000')

    // Wait for the transaction to be confirmed
    await tx.wait()

    console.log('Minting successful:', tx.hash)
  } catch (error) {
    console.error('Minting failed:', error)
  }
}

export const scheduledMintingFunction = functions.pubsub
  .schedule('every 5 minutes')
  .timeZone('America/Toronto')
  .onRun(async (context) => {
    return scheduledMinting();
  });

  export const triggerScheduledMinting = functions.https.onRequest(async (req, res) => {
    try {
      await scheduledMinting();
      res.send('Minting triggered successfully.');
    } catch (error) {
      console.error('Minting failed:', error);
      res.status(500).send('An error occurred while minting.');
    }
  });
