use ethers::{
    prelude::*,
    solc::{Project, ProjectPathsConfig},
    utils::Anvil,
};
use eyre::Result;
use std::{convert::TryFrom, env, path::PathBuf, sync::Arc, time::Duration};

// Generate the type-safe contract bindings by providing the ABI
// definition in human readable format
abigen!(
    SimpleContract,
    r#"[
        function setValue(string)
        function getValue() external view returns (string)
        event ValueChanged(address indexed author, string oldValue, string newValue)
    ]"#,
    event_derives(serde::Deserialize, serde::Serialize)
);

#[tokio::main]
async fn main() -> Result<()> {
    let path = env::current_dir()?.join("contracts/");

    // // the directory we use is root-dir/examples
    let root = PathBuf::from(path.clone());
    let srcs = PathBuf::from(path.clone().join("src/"));
    // we use `root` for both the project root and for where to search for contracts since
    // everything is in the same directory
    let paths = ProjectPathsConfig::builder().root(&root).sources(&srcs).build().unwrap();

    // get the solc project instance using the paths above
    let project = Project::builder().paths(paths).ephemeral().no_artifacts().build().unwrap();
    // compile the project and get the artifacts
    let output = project.compile().unwrap();
    let contract = output.find_first("SimpleStorage").expect("could not find contract").clone();
    let (abi, bytecode, _) = contract.into_parts();

    // 2. instantiate our wallet & anvil
    let anvil = Anvil::new().spawn();
    let wallet: LocalWallet = anvil.keys()[0].clone().into();

    // Declare the message you want to sign.
    let message = "Some data";

    // sign message from your wallet and print out signature produced.
    let signature = wallet.sign_message(message).await?;
    println!("Produced signature {}", signature);
    // verify the signature produced from your wallet.
    signature.verify(message, wallet.address()).unwrap();
    println!("Verified signature produced by {:?}!", wallet.address());



    // 3. connect to the network
    let provider =
        Provider::<Http>::try_from(anvil.endpoint())?.interval(Duration::from_millis(10u64));

    // 4. instantiate the client with the wallet
    let client = SignerMiddleware::new(provider, wallet);
    let client = Arc::new(client);

    // 5. create a factory which will be used to deploy instances of the contract
    let factory = ContractFactory::new(abi.unwrap(), bytecode.unwrap(), client.clone());

    // 6. deploy it with the constructor arguments
    let contract = factory.deploy("initial value".to_string())?.send().await?;

    // 7. get the contract's address
    let addr = contract.address();

    // 8. instantiate the contract
    let contract = SimpleContract::new(addr, client.clone());

    // 9. call the `setValue` method
    // (first `await` returns a PendingTransaction, second one waits for it to be mined)
    let _receipt = contract.set_value("hi".to_owned()).send().await?.await?;

    // 10. get all events
    let logs = contract.value_changed_filter().from_block(0u64).query().await?;

    // 11. get the new value
    let value = contract.get_value().call().await?;

    println!("Value: {}. Logs: {}", value, serde_json::to_string(&logs)?);

    Ok(())
}

