module kari::kari {
    // Importing necessary modules and types
    use std::ascii;
    use std::option;
    use std::string;
    use sui::deny_list::DenyList;
    use sui::object::UID;
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin::{Self, Coin, TreasuryCap, DenyCap};
    use sui::url;
    use sui::coin::deny_list_remove;

    // Struct representing the KARI token
    struct KARI has drop {}

    // Struct representing a borrower of KARI tokens
    struct Borrower has copy, drop {
        amount: u64, // Amount of KARI tokens borrowed
        sender: address, // Address of the borrower
    }

    // Struct representing a minting event of KARI tokens
    struct Mint has copy, drop {
        amount: u64, // Amount of KARI tokens minted
        sender: address, // Address of the minter
    }

    // Function to initialize the KARI governance token
    fun init(witness: KARI, ctx: &mut TxContext) {
        // Create the KARI governance token with 9 decimals
        let (treasury, denycap, metadata) = coin::create_regulated_currency<KARI>(
            witness,
            9,
            b"KARI",
            b"Kanari Token",
            b"The governance token of Kanari Network",
            option::some(url::new_unsafe_from_bytes(b"https://magenta-able-pheasant-388.mypinata.cloud/ipfs/QmNVQ3LQSbLC8bJDnXrbuftf2dC7LWJp4oXVkXxVRrDRfk")),
            ctx
        );
        // Get the sender of the transaction
        let sender = tx_context::sender(ctx);

        // Transfer the treasury and denycap objects to the sender
        transfer::public_transfer(treasury, sender,);
        transfer::public_transfer(denycap, sender);

        // Freeze the metadata object
        transfer::public_freeze_object(metadata);
    }

    // Function to get the total supply of KARI tokens
    public fun total_supply(cap: &TreasuryCap<KARI>) : u64 {
        coin::total_supply(cap)
    }

    // Function to borrow KARI tokens
    entry public fun borrow(
        cap: &mut TreasuryCap<KARI>,
        amount: u64,
        sender: address,
        ctx: &mut TxContext,
    ) {
        let borrow = Borrower {
            amount,
            sender,
        };
        coin::mint_and_transfer(cap, borrow.amount, borrow.sender, ctx);
    }

    // Function to mint KARI tokens
    entry public fun mint(
        cap: &mut TreasuryCap<KARI>,
        amount: u64,
        sender: address,
        ctx: &mut TxContext,
    ) {
        let mint = Mint {
            amount,
            sender,
        };
        coin::mint_and_transfer(cap, mint.amount,mint.sender, ctx);
    }

    // Function to burn KARI tokens
    public entry fun burn(
        cap: &mut TreasuryCap<KARI>,
        coin: Coin<KARI>,
    ) {
        coin::burn(cap, coin);
    }

    // Function to add an address to the deny list
    public entry fun deny_list_add_admin(
        denylist: &mut DenyList,
        denycap: &mut DenyCap<KARI>,
        sender: address,
        ctx: &mut TxContext,
    ) {
        coin::deny_list_add(denylist, denycap, sender, ctx);
    }

    // Function to remove an address from the deny list
    public entry fun deny_list_remove_admin(
        denylist: &mut DenyList,
        denycap: &mut DenyCap<KARI>,
        sender: address,
        ctx: &mut tx_context::TxContext,
    ) {
        deny_list_remove(denylist, denycap, sender, ctx);
    }

    // Function to destroy zero KARI tokens
    public  entry fun destroy_zero(
        c: Coin<KARI>
    ) {
        destroy_zero(c);
    }

    // Function to transfer KARI tokens to a recipient
    public entry fun transfer(c: coin::Coin<KARI>, recipient: address) {
        transfer::public_transfer(c, recipient);
    }

    // Struct representing the metadata of the KARI token
    struct CoinMetadata has store, key {
        id: UID,
        decimals: u8, // Number of decimal places the coin uses
        name: string::String, // Name for the token
        symbol: ascii::String, // Symbol for the token
        description: string::String, // Description of the token
        icon_url: option::Option<url::Url>, // URL for the token logo
    }

    // Function to update the name of the KARI token
    public entry fun update_name(
        _treasury: &TreasuryCap<KARI>,
        metadata: &mut CoinMetadata,
        name: string::String
    ) {
        metadata.name = name;
    }

    // Function to update the symbol of the KARI token
    public entry fun update_symbol(
        _treasury: &TreasuryCap<KARI>,
        metadata: &mut CoinMetadata,
        symbol: ascii::String
    ) {
        metadata.symbol = symbol;
    }

    // Function to update the description of the KARI token
    public entry fun update_description(
        _treasury: &TreasuryCap<KARI>,
        metadata: &mut CoinMetadata,
        description: string::String
    ) {
        metadata.description = description;
    }

    // Function to update the icon URL of the KARI token
    public entry fun update_icon_url(
        _treasury: &TreasuryCap<KARI>,
        metadata: &mut CoinMetadata,
        url: ascii::String
    ) {
        metadata.icon_url = option::some(url::new_unsafe(url));
    }

    // Function to get the number of decimal places of the KARI token
    public fun get_decimals(metadata: &CoinMetadata): u8 {
        metadata.decimals
    }
}