import hardhat from "hardhat";

async function main() {
    console.log("deploy start")

    const PMIX = await hardhat.ethers.getContractFactory("PMIX")
    const pmix = await PMIX.deploy()
    console.log(`PMIX address: ${pmix.address}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
